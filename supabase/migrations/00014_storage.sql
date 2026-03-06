-- ============================================================
-- VerveForge Migration 00014: Storage Bucket 策略
-- ============================================================
-- 注意：Storage Bucket 需在 Supabase Dashboard 中手动创建
-- 以下为 RLS 策略参考（通过 Dashboard → Storage → Policies 配置）

-- Bucket 列表：
-- 1. avatars        — 用户头像
-- 2. workout-photos — 训练日志照片
-- 3. gym-photos     — 训练馆照片
-- 4. post-photos    — 动态照片
-- 5. chat-media     — 聊天媒体

-- 通用策略说明：
-- SELECT (读取): 公开可读（avatars, workout-photos, gym-photos, post-photos）
-- INSERT (上传): 仅认证用户，路径第一段为用户 ID
-- UPDATE (更新): 仅文件所有者
-- DELETE (删除): 仅文件所有者

-- 示例 SQL（需在 Dashboard 中执行）：
-- CREATE POLICY "avatars_public_read" ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
-- CREATE POLICY "avatars_auth_upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
