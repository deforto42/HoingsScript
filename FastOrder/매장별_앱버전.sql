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
        GROUP BY s.id
                , s.name
                , t.app_version
     ) z
GROUP BY z.id
       , z.name;