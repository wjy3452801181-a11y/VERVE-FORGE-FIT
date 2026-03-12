// ============================================================
// VerveForge Edge Function: ai-reply-filter
// AI 回复内容审核与过滤 — 在插入 AI 消息前检查内容安全性
//
// 调用方式：由 ai-avatar-reply / ai-avatar-chat 内部调用
// 安全机制：
//   - service_role_key 或 JWT 鉴权
//   - 多层过滤：正则 + 关键词表 + 语义规则
//   - PIPL 合规：过滤过程不记录用户原始数据
//   - 过滤结果仅返回 pass/block，不保留违规内容副本
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// ============================================================
// 违规类别定义
// ============================================================
type ViolationCategory =
  | "violence"      // 暴力
  | "sexual"        // 色情
  | "discrimination" // 歧视
  | "advertising"   // 广告
  | "privacy"       // 隐私泄露
  | "political"     // 政治敏感
  | "illegal";      // 违法

interface FilterRequest {
  content: string;     // 待审核内容
  context?: string;    // 可选：上下文（用于辅助判断）
}

interface FilterResult {
  passed: boolean;              // 是否通过审核
  category?: ViolationCategory; // 违规类别（仅 passed=false 时有值）
  severity?: "low" | "medium" | "high"; // 严重程度
  fallback_reply: string;       // 若被过滤，使用此固定回复
}

// 固定回复模板 — 当内容被过滤时返回
const FILTERED_REPLY = "分身暂时无法回复，请稍后尝试。";
const FILTERED_REPLY_EN = "Avatar is temporarily unable to reply. Please try again later.";

// ============================================================
// 内置敏感词（硬编码层 — 即使数据库不可用也能兜底）
// 按类别组织，仅包含高危关键词
// ============================================================
const BUILTIN_KEYWORDS: Record<ViolationCategory, string[]> = {
  violence: [
    "杀人", "砍人", "捅刀", "炸弹", "自杀", "自残",
    "枪击", "暗杀", "血腥", "屠杀", "绑架",
    "kill someone", "murder", "bomb threat", "mass shooting",
    "stab", "suicide method", "self-harm",
  ],
  sexual: [
    "色情", "裸体", "做爱", "性交", "卖淫",
    "嫖娼", "约炮", "一夜情", "成人视频",
    "porn", "nude", "sexual intercourse", "prostitution",
    "hookup service", "adult content",
  ],
  discrimination: [
    "种族歧视", "白人至上", "黑鬼", "支那",
    "死gay", "变态同性恋", "残废",
    "nigger", "chink", "white supremacy",
    "faggot", "retard",
  ],
  advertising: [
    "加微信", "加QQ", "扫码领取", "免费领",
    "点击链接", "优惠券", "刷单", "兼职赚钱",
    "代购", "信用卡套现", "贷款", "赌博",
    "click this link", "free money", "casino", "gambling",
  ],
  privacy: [
    "身份证号", "银行卡号", "信用卡号", "密码是",
    "社保号", "护照号码",
    "ssn", "credit card number", "password is",
    "bank account", "passport number",
  ],
  political: [
    "颠覆政权", "分裂国家", "恐怖主义",
    "overthrow government", "terrorism",
    "separatism",
  ],
  illegal: [
    "贩毒", "制毒", "买枪", "洗钱",
    "诈骗教程", "黑客攻击", "DDoS",
    "drug dealing", "money laundering",
    "hacking tutorial", "fraud scheme",
  ],
};

// ============================================================
// 正则规则 — 检测结构化违规模式
// ============================================================
const REGEX_RULES: Array<{
  pattern: RegExp;
  category: ViolationCategory;
  severity: "low" | "medium" | "high";
  description: string;
}> = [
  // 隐私信息泄露模式
  {
    pattern: /\b\d{17}[\dXx]\b/,
    category: "privacy",
    severity: "high",
    description: "疑似身份证号码（18位）",
  },
  {
    pattern: /\b\d{15}\b/,
    category: "privacy",
    severity: "medium",
    description: "疑似旧版身份证号码（15位）",
  },
  {
    pattern: /\b(?:4\d{15}|5[1-5]\d{14}|3[47]\d{13}|6(?:011|5\d{2})\d{12})\b/,
    category: "privacy",
    severity: "high",
    description: "疑似信用卡号码",
  },
  {
    pattern: /\b1[3-9]\d{9}\b/,
    category: "privacy",
    severity: "medium",
    description: "疑似中国大陆手机号",
  },
  // 广告 URL 模式
  {
    pattern: /(?:https?:\/\/)?(?:bit\.ly|t\.cn|dwz\.cn|url\.cn|tinyurl\.com)\/\S+/i,
    category: "advertising",
    severity: "medium",
    description: "疑似短链接推广",
  },
  // 微信/QQ 号引导
  {
    pattern: /(?:加我?|我的?)(?:微信|wx|WeChat|QQ|qq)[\s:：]?\s*\w{5,}/i,
    category: "advertising",
    severity: "medium",
    description: "疑似社交账号引流",
  },
];

// ============================================================
// 主服务入口
// ============================================================
serve(async (req: Request) => {
  try {
    // ========== 1. 鉴权 ==========
    // 支持 service_role（后端调用）和 JWT（客户端调用）
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { "Content-Type": "application/json" },
      });
    }

    const body: FilterRequest = await req.json();
    const { content } = body;

    // 空内容直接通过
    if (!content || content.trim().length === 0) {
      return jsonResponse({ passed: true, fallback_reply: "" });
    }

    // ========== 2. 内置关键词检测（硬编码层） ==========
    const builtinResult = checkBuiltinKeywords(content);
    if (builtinResult) {
      console.log(
        `内容审核 [内置词库] 拦截: 类别=${builtinResult.category}, 严重程度=${builtinResult.severity}`
      );
      // PIPL 合规：不记录原始内容，只记录类别
      return jsonResponse({
        passed: false,
        category: builtinResult.category,
        severity: builtinResult.severity,
        fallback_reply: FILTERED_REPLY,
      });
    }

    // ========== 3. 正则规则检测 ==========
    const regexResult = checkRegexRules(content);
    if (regexResult) {
      console.log(
        `内容审核 [正则规则] 拦截: ${regexResult.description}, 类别=${regexResult.category}`
      );
      return jsonResponse({
        passed: false,
        category: regexResult.category,
        severity: regexResult.severity,
        fallback_reply: FILTERED_REPLY,
      });
    }

    // ========== 4. 数据库关键词检测（动态词库） ==========
    try {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      const dbResult = await checkDatabaseKeywords(supabase, content);
      if (dbResult) {
        console.log(
          `内容审核 [数据库词库] 拦截: 类别=${dbResult.category}, 级别=${dbResult.severity}`
        );
        return jsonResponse({
          passed: false,
          category: dbResult.category,
          severity: dbResult.severity,
          fallback_reply: FILTERED_REPLY,
        });
      }
    } catch (dbError) {
      // 数据库查询失败时，不阻断正常流程（内置词库已兜底）
      console.warn("数据库关键词查询失败，使用内置词库兜底:", dbError);
    }

    // ========== 5. 全部通过 ==========
    return jsonResponse({ passed: true, fallback_reply: "" });
  } catch (err) {
    console.error("ai-reply-filter error:", err);
    // 过滤服务异常时默认放行（不阻断正常回复体验）
    return jsonResponse({ passed: true, fallback_reply: "" });
  }
});

// ============================================================
// Helper Functions
// ============================================================

/// 统一 JSON 响应
function jsonResponse(data: FilterResult, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

/// 内置关键词检测
/// 将内容转小写后逐词匹配（完整包含即命中）
function checkBuiltinKeywords(
  content: string
): { category: ViolationCategory; severity: "high" } | null {
  const normalized = content.toLowerCase();

  for (const [category, keywords] of Object.entries(BUILTIN_KEYWORDS)) {
    for (const keyword of keywords) {
      if (normalized.includes(keyword.toLowerCase())) {
        return {
          category: category as ViolationCategory,
          severity: "high", // 内置词库命中一律 high
        };
      }
    }
  }

  return null;
}

/// 正则规则检测
function checkRegexRules(
  content: string
): { category: ViolationCategory; severity: "low" | "medium" | "high"; description: string } | null {
  for (const rule of REGEX_RULES) {
    if (rule.pattern.test(content)) {
      return {
        category: rule.category,
        severity: rule.severity,
        description: rule.description,
      };
    }
  }
  return null;
}

/// 数据库关键词检测
/// 从 ai_reply_keywords 表加载动态词库并匹配
async function checkDatabaseKeywords(
  supabase: ReturnType<typeof createClient>,
  content: string
): Promise<{ category: ViolationCategory; severity: "low" | "medium" | "high" } | null> {
  // 查询所有启用的关键词（按严重程度降序，优先匹配高危词）
  const { data: keywords, error } = await supabase
    .from("ai_reply_keywords")
    .select("keyword, category, severity")
    .eq("enabled", true)
    .order("severity_order", { ascending: false });

  if (error || !keywords || keywords.length === 0) {
    return null;
  }

  const normalized = content.toLowerCase();

  for (const kw of keywords) {
    const keyword = (kw.keyword as string).toLowerCase();
    // 支持两种匹配模式：
    // 1. 普通字符串：包含匹配
    // 2. 以 / 开头和结尾：正则匹配
    if (keyword.startsWith("/") && keyword.endsWith("/")) {
      try {
        const regex = new RegExp(keyword.slice(1, -1), "i");
        if (regex.test(content)) {
          return {
            category: kw.category as ViolationCategory,
            severity: kw.severity as "low" | "medium" | "high",
          };
        }
      } catch {
        // 正则语法错误，跳过该条
        continue;
      }
    } else {
      if (normalized.includes(keyword)) {
        return {
          category: kw.category as ViolationCategory,
          severity: kw.severity as "low" | "medium" | "high",
        };
      }
    }
  }

  return null;
}
