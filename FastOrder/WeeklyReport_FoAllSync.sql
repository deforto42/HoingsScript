-- 중개서버 연동 포스 비중
SELECT CASE POSType WHEN 0 THEN '오케이포스'
                    WHEN 1 THEN '매직포스'
                    WHEN 2 THEN '스마일포스'
                    WHEN 4 THEN '이지포스'
                    WHEN 6 THEN '아임유'
                    WHEN 7 THEN '푸드테크'
                    WHEN 8 THEN '포스마스터'
                    WHEN 9 THEN '유니온'
                    WHEN 10 THEN '야놀자'
                    WHEN 11 THEN '패스트포스'
                    END AS POSType
        , COUNT(1) COUNT
FROM Stores (NOLOCK) s
WHERE s.name NOT LIKE '%테스트%'
AND s.name NOT LIKE '%이관전%'
AND s.name NOT LIKE '%영업%'
AND s.name NOT LIKE '%사무실%'
AND s.name NOT LIKE '%폐업%'
AND s.name NOT LIKE '%쇼룸%'
AND s.name NOT LIKE '%쇼륨%'
AND s.name NOT LIKE '%본사%'
AND s.name NOT LIKE '%시안%'
AND s.name NOT LIKE '%시연%'
AND s.name NOT LIKE '%웹 연동%'
AND s.name NOT LIKE '%QA%'
AND s.ID COLLATE SQL_Latin1_General_CP1_CI_AS IN (
                SELECT DISTINCT fas_store_code
                FROM fastorder.fast..poses p
                WHERE type = 'FO_ALL_SYNC'
                AND fas_store_code IS NOT NULL
                AND EXISTS (SELECT 1
                              FROM fastorder.fast..orders
                              WHERE total_price != 0
                              AND store_id = p.store_id)
                AND EXISTS (SELECT 1
                            FROM fastorder.fast..tables
                            WHERE device_id IS NOT NULL
                            AND store_id = p.store_id)
    )
GROUP BY POSType
ORDER BY POSType;







-- 중개서버 연동 포스 비중
SELECT s.ID, s.Name, POSType, s.CurrentDemonVersion
FROM Stores (NOLOCK) s
WHERE s.name NOT LIKE '%테스트%'
AND s.name NOT LIKE '%이관전%'
AND s.name NOT LIKE '%영업%'
AND s.name NOT LIKE '%사무실%'
AND s.name NOT LIKE '%폐업%'
AND s.name NOT LIKE '%쇼룸%'
AND s.name NOT LIKE '%쇼륨%'
AND s.name NOT LIKE '%본사%'
AND s.name NOT LIKE '%시안%'
AND s.name NOT LIKE '%시연%'
AND s.name NOT LIKE '%웹 연동%'
AND s.name NOT LIKE '%QA%'
AND s.ID COLLATE SQL_Latin1_General_CP1_CI_AS IN (
                SELECT DISTINCT fas_store_code
                FROM fastorder.fast..poses p
                WHERE type = 'FO_ALL_SYNC'
                AND fas_store_code IS NOT NULL
                AND EXISTS (SELECT 1
                              FROM fastorder.fast..orders
                              WHERE total_price != 0
                              AND store_id = p.store_id)
                AND EXISTS (SELECT 1
                            FROM fastorder.fast..tables
                            WHERE device_id IS NOT NULL
                            AND store_id = p.store_id)
    )
ORDER BY s.[CurrentDemonVersion], s.POSType, s.ID;

