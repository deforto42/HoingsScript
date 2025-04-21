SELECT COUNT(*) FROM reserve_history;

SELECT COUNT(*) FROM reserve;

SELECT COUNT(*) FROM reserve_history WHERE created_at < '2025-04-01 00:00:00';

SELECT COUNT(*) FROM reserve_history_bak WHERE created_at < '2025-04-01 00:00:00';

SELECT COUNT(*) FROM reserve WHERE created_at < '2025-04-01 00:00:00';

SELECT COUNT(*) FROM reserve_bak WHERE created_at < '2025-04-01 00:00:00';


insert into reserve_history_bak (id, created_at, updated_at, created_by, updated_by, device_div, resv_status,
                                 snd_status, store_id, resv_no, msg_div)
SELECT id, created_at, updated_at, created_by, updated_by, device_div, resv_status,
                                 snd_status, store_id, resv_no, msg_div
FROM reserve_history WHERE created_at < '2025-04-01 00:00:00';

DELETE FROM reserve_history WHERE created_at < '2025-04-01 00:00:00';


insert into reserve_bak (id, created_at, updated_at, created_by, updated_by, description, resv_status, resv_tel,
                         store_id, resv_per_cnt, resv_no, resv_kid_cnt, device_id, resv_guide_time, resv_finish_time,
                         resv_finish_status, call_cnt)
SELECT id, created_at, updated_at, created_by, updated_by, description, resv_status, resv_tel,
                         store_id, resv_per_cnt, resv_no, resv_kid_cnt, device_id, resv_guide_time, resv_finish_time,
                         resv_finish_status, call_cnt
FROM reserve WHERE created_at < '2025-04-01 00:00:00';

DELETE FROM reserve WHERE created_at < '2025-04-01 00:00:00';