SELECT z.id
     , z.name
     , GROUP_CONCAT(z.appVersion ORDER BY z.appVersion) appVersion
FROM (
        SELECT s.id
             , s.name
             , CONCAT(t.app_version,'(',COUNT(1),')') appVersion
        FROM stores s
        INNER JOIN tables t
        ON s.id = t.store_id
        WHERE t.app_version IS NOT NULL
        AND t.device_id IS NOT NULL
        AND t.device_push_token IS NOT NULL
        AND s.name NOT LIKE '%테스트%'
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
        AND EXISTS (SELECT 1
                      FROM orders
                      WHERE total_price != 0
                      AND store_id = s.id)
        GROUP BY s.id
                , s.name
                , t.app_version
     ) z
GROUP BY z.id
       , z.name
ORDER BY appVersion;