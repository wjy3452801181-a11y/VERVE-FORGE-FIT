-- ============================================================
-- Migration: 00021_ai_reply_filter_keywords.sql
-- AI 回复内容审核关键词表
--
-- 用途：存储动态管理的敏感词列表，支持运营后台热更新
-- 设计：
--   - keyword: 关键词（支持普通字符串和正则表达式）
--   - category: 违规类别（violence/sexual/discrimination/advertising/privacy/political/illegal）
--   - severity: 严重程度（low/medium/high）
--   - severity_order: 排序权重（high=3, medium=2, low=1），用于查询优先级
--   - enabled: 启停控制，允许临时禁用某个词而不删除
--   - 正则模式：以 / 开头和结尾的 keyword 会被作为正则处理
-- PIPL 合规：仅存储关键词本身，不存储任何用户数据
-- ============================================================

-- 1. 创建关键词表
CREATE TABLE IF NOT EXISTS ai_reply_keywords (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  keyword TEXT NOT NULL,                    -- 关键词或正则表达式（/pattern/）
  category TEXT NOT NULL DEFAULT 'illegal', -- 违规类别
  severity TEXT NOT NULL DEFAULT 'medium',  -- 严重程度: low/medium/high
  severity_order INT NOT NULL DEFAULT 2,    -- 排序权重: high=3, medium=2, low=1
  enabled BOOLEAN NOT NULL DEFAULT true,    -- 是否启用
  note TEXT,                                -- 备注（运营标记用途）
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- 约束：类别和严重程度枚举
  CONSTRAINT chk_category CHECK (
    category IN ('violence', 'sexual', 'discrimination', 'advertising', 'privacy', 'political', 'illegal')
  ),
  CONSTRAINT chk_severity CHECK (
    severity IN ('low', 'medium', 'high')
  ),
  -- 防止重复关键词
  CONSTRAINT uq_keyword_category UNIQUE (keyword, category)
);

-- 2. 索引：按启用状态和严重程度查询
CREATE INDEX IF NOT EXISTS idx_ai_reply_keywords_enabled
  ON ai_reply_keywords (enabled, severity_order DESC);

CREATE INDEX IF NOT EXISTS idx_ai_reply_keywords_category
  ON ai_reply_keywords (category) WHERE enabled = true;

-- 3. 自动更新 updated_at
CREATE OR REPLACE FUNCTION update_ai_reply_keywords_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ai_reply_keywords_updated_at
  BEFORE UPDATE ON ai_reply_keywords
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_reply_keywords_updated_at();

-- 4. RLS 策略
ALTER TABLE ai_reply_keywords ENABLE ROW LEVEL SECURITY;

-- 仅 service_role 可读写（Edge Function 使用 service_role_key 访问）
-- 普通用户不可见此表
CREATE POLICY "service_role_full_access" ON ai_reply_keywords
  FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- 5. 表注释
COMMENT ON TABLE ai_reply_keywords IS 'AI 回复内容审核关键词表（动态词库），由 ai-reply-filter Edge Function 使用';
COMMENT ON COLUMN ai_reply_keywords.keyword IS '关键词或正则（以 / 包裹为正则模式，如 /pattern/）';
COMMENT ON COLUMN ai_reply_keywords.category IS '违规类别: violence/sexual/discrimination/advertising/privacy/political/illegal';
COMMENT ON COLUMN ai_reply_keywords.severity IS '严重程度: low（提醒）/ medium（过滤）/ high（严格过滤）';
COMMENT ON COLUMN ai_reply_keywords.severity_order IS '排序权重: high=3, medium=2, low=1，查询时优先匹配高危词';
COMMENT ON COLUMN ai_reply_keywords.enabled IS '是否启用，支持运营临时禁用';

-- ============================================================
-- 6. 初始敏感词数据（50+ 条）
-- 覆盖：暴力、色情、歧视、广告、隐私、政治、违法
-- ============================================================

-- === 暴力 (violence) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('杀人方法', 'violence', 'high', 3, '暴力行为指导'),
  ('自杀方法', 'violence', 'high', 3, '自伤指导'),
  ('自残教程', 'violence', 'high', 3, '自伤指导'),
  ('怎么打人', 'violence', 'high', 3, '暴力引导'),
  ('投毒', 'violence', 'high', 3, '危害公共安全'),
  ('纵火', 'violence', 'high', 3, '危害公共安全'),
  ('制造武器', 'violence', 'high', 3, '武器制造'),
  ('how to kill', 'violence', 'high', 3, '暴力行为指导（英文）'),
  ('how to hurt', 'violence', 'medium', 2, '伤害引导（英文）'),
  ('make a weapon', 'violence', 'high', 3, '武器制造（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 色情 (sexual) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('性服务', 'sexual', 'high', 3, '色情交易'),
  ('援交', 'sexual', 'high', 3, '色情交易'),
  ('裸聊', 'sexual', 'high', 3, '色情内容'),
  ('黄色视频', 'sexual', 'high', 3, '色情内容'),
  ('情色小说', 'sexual', 'medium', 2, '色情内容'),
  ('开房', 'sexual', 'medium', 2, '性暗示'),
  ('sexual service', 'sexual', 'high', 3, '色情交易（英文）'),
  ('send nudes', 'sexual', 'high', 3, '色情内容（英文）'),
  ('onlyfans', 'sexual', 'medium', 2, '色情平台（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 歧视 (discrimination) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('地域黑', 'discrimination', 'medium', 2, '地域歧视'),
  ('低端人口', 'discrimination', 'high', 3, '社会歧视'),
  ('穷鬼', 'discrimination', 'low', 1, '经济歧视'),
  ('你们这种人', 'discrimination', 'medium', 2, '群体歧视'),
  ('go back to your country', 'discrimination', 'high', 3, '种族歧视（英文）'),
  ('you people', 'discrimination', 'low', 1, '群体歧视（英文）'),
  ('inferior race', 'discrimination', 'high', 3, '种族歧视（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 广告 (advertising) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('低价代购', 'advertising', 'medium', 2, '商业推广'),
  ('免费试用', 'advertising', 'low', 1, '营销引流'),
  ('日入过万', 'advertising', 'high', 3, '虚假宣传'),
  ('月入百万', 'advertising', 'high', 3, '虚假宣传'),
  ('刷单兼职', 'advertising', 'high', 3, '诈骗相关'),
  ('扫码加群', 'advertising', 'medium', 2, '社群引流'),
  ('V信', 'advertising', 'medium', 2, '微信变体引流'),
  ('薇信', 'advertising', 'medium', 2, '微信变体引流'),
  ('make money fast', 'advertising', 'high', 3, '虚假宣传（英文）'),
  ('work from home easy', 'advertising', 'medium', 2, '营销引流（英文）'),
  ('buy followers', 'advertising', 'medium', 2, '刷量推广（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 隐私 (privacy) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('告诉我你的密码', 'privacy', 'high', 3, '套取密码'),
  ('发你的身份证', 'privacy', 'high', 3, '套取证件'),
  ('银行卡照片', 'privacy', 'high', 3, '套取金融信息'),
  ('家庭住址是', 'privacy', 'medium', 2, '住址泄露'),
  ('/我?的?密码是.{4,}/', 'privacy', 'high', 3, '密码泄露正则'),
  ('send me your id', 'privacy', 'high', 3, '套取证件（英文）'),
  ('whats your password', 'privacy', 'high', 3, '套取密码（英文）'),
  ('social security number', 'privacy', 'high', 3, '套取SSN（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 政治敏感 (political) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('推翻政府', 'political', 'high', 3, '煽动颠覆'),
  ('独立建国', 'political', 'high', 3, '分裂国家'),
  ('政治避难', 'political', 'medium', 2, '敏感话题'),
  ('regime change', 'political', 'high', 3, '煽动颠覆（英文）')
ON CONFLICT (keyword, category) DO NOTHING;

-- === 违法 (illegal) ===
INSERT INTO ai_reply_keywords (keyword, category, severity, severity_order, note) VALUES
  ('购买毒品', 'illegal', 'high', 3, '毒品交易'),
  ('冰毒', 'illegal', 'high', 3, '毒品名称'),
  ('大麻购买', 'illegal', 'high', 3, '毒品交易'),
  ('假证', 'illegal', 'high', 3, '伪造证件'),
  ('办假证', 'illegal', 'high', 3, '伪造证件'),
  ('偷税漏税', 'illegal', 'medium', 2, '逃税指导'),
  ('黑客服务', 'illegal', 'high', 3, '网络犯罪'),
  ('代考', 'illegal', 'medium', 2, '考试作弊'),
  ('buy drugs', 'illegal', 'high', 3, '毒品交易（英文）'),
  ('fake id', 'illegal', 'high', 3, '伪造证件（英文）'),
  ('hack account', 'illegal', 'high', 3, '网络犯罪（英文）'),
  ('counterfeit money', 'illegal', 'high', 3, '假币（英文）')
ON CONFLICT (keyword, category) DO NOTHING;
