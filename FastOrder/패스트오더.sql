-- 관리자 계정 생성
INSERT INTO fast.users (created_at, updated_at, created_by, updated_by, description, is_deleted, level, login_id, login_password, name, store_group_id)
VALUES (NOW(), null, 10000000, null, null, false, 'MASTER'
        , 'hyun', '$2a$10$nW3zeVCeXWBwEJ9OmQLey.q9Zp82Oe9YrAQuwDbPGCdDxQfyuQPnK'
        , '현성규', null);

SELECT * FROM users WHERE level = 'MASTER' AND login_password = '$2a$10$nW3zeVCeXWBwEJ9OmQLey.q9Zp82Oe9YrAQuwDbPGCdDxQfyuQPnK';