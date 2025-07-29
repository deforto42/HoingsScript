    # 운영중인 매장수, 테이블수
    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(t.id) AS 테이블수
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
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
    AND s.name NOT LIKE '%QA%';

    SELECT MAX(status) vStatus
            , storeId
            , storeName
    FROM (SELECT 'N' AS status
                , s.id AS storeId
                , s.name AS storeName
          FROM stores s
                   INNER JOIN tables t
                              ON s.id = t.store_id
                                  AND t.device_id IS NOT NULL
          WHERE EXISTS (SELECT 1
                        FROM orders
                        WHERE total_price != 0
                          AND store_id = s.id)
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
          GROUP BY s.id, s.name
          UNION ALL
          SELECT 'D' AS status
                , s.id AS storeId
                , s.name AS storeName
          FROM stores s
                   INNER JOIN tables t
                              ON s.id = t.store_id
                                  AND t.device_id IS NOT NULL
          WHERE EXISTS (SELECT 1
                        FROM orders_bak
                        WHERE total_price != 0
                          AND created_at BETWEEN ADDDATE(NOW(), -14) AND NOW()
                          AND store_id = s.id)
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
          GROUP BY s.id, s.name) t
    GROUP BY storeId, storeName
    HAVING COUNT(status) != 2
    ;

    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(rd.id) AS 기기수량
    FROM reserve_store rs
    INNER JOIN stores s
    ON rs.store_id = s.id
    INNER JOIN reserve_device rd
    ON rs.store_id = rd.store_id
    WHERE EXISTS(   SELECT 1
                    FROM reserve_history rh
                    WHERE rh.created_at BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()
                    AND rs.store_id = rh.store_id)
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
    AND s.name NOT LIKE '%QA%';

-- 패스트오더 선/후불 매장 비중 & 패스트오더 연동 포스 비중
SELECT  NOW() AS 기준일시
        , COUNT(DISTINCT s.id) AS 매장수
        , SUM(CASE WHEN s.pay_type = 'PREPAID' THEN 1 ELSE 0 END) 선불
        , SUM(CASE WHEN s.pay_type = 'POSTPAID' THEN 1 ELSE 0 END) 후불
        , SUM(CASE WHEN s.name NOT LIKE '%명륜%'
            AND s.name NOT LIKE '%샤브올데이%'
            AND s.name NOT LIKE '%생활맥주%'
            AND s.name NOT LIKE '%짬뽕관%'
            AND s.name NOT LIKE '%강창구%'
            AND s.name NOT LIKE '%미도인%'
            AND s.name NOT LIKE '%크라운호프%'
            AND s.name NOT LIKE '%고반식당%'
            AND s.name NOT LIKE '%경성%'
            AND s.name NOT LIKE '%니뽕내뽕%'
            AND s.name NOT LIKE '%고깃리%'
            AND s.name NOT LIKE '%제줏간%'
            AND s.name NOT LIKE '%오봉집%'
            THEN 1 ELSE 0 END) 기타
        , SUM(CASE WHEN s.name LIKE '%명륜%' THEN 1 ELSE 0 END) 명륜
        , SUM(CASE WHEN s.name LIKE '%샤브올데이%' THEN 1 ELSE 0 END) 샤브올데이
        , SUM(CASE WHEN s.name LIKE '%생활맥주%' THEN 1 ELSE 0 END) 생활맥주
        , SUM(CASE WHEN s.name LIKE '%짬뽕관%' THEN 1 ELSE 0 END) 짬뽕관
        , SUM(CASE WHEN s.name LIKE '%강창구%' THEN 1 ELSE 0 END) 강창구진순대
        , SUM(CASE WHEN s.name LIKE '%미도인%' THEN 1 ELSE 0 END) 미도인
        , SUM(CASE WHEN s.name LIKE '%크라운호프%' THEN 1 ELSE 0 END) 크라운호프
        , SUM(CASE WHEN s.name LIKE '%고반식당%' THEN 1 ELSE 0 END) 고반식당
        , SUM(CASE WHEN s.name LIKE '%경성%' THEN 1 ELSE 0 END) 경성
        , SUM(CASE WHEN s.name LIKE '%니뽕내뽕%' THEN 1 ELSE 0 END) 니뽕내뽕
        , SUM(CASE WHEN s.name LIKE '%고깃리%' THEN 1 ELSE 0 END) 고깃리
        , SUM(CASE WHEN s.name LIKE '%제줏간%' THEN 1 ELSE 0 END) 제줏간
        , SUM(CASE WHEN s.name LIKE '%오봉집%' THEN 1 ELSE 0 END) 오봉집
        , SUM(CASE WHEN p.type = 'OK_POS' THEN 1 ELSE 0 END) OK_POS
        , SUM(CASE WHEN p.type = 'EASY_POS' THEN 1 ELSE 0 END) EASY_POS
        , SUM(CASE WHEN p.type = 'POS_MASTER' THEN 1 ELSE 0 END) POS_MASTER
        , SUM(CASE WHEN p.type = 'UNION_POS' THEN 1 ELSE 0 END) UNION_POS
        , SUM(CASE WHEN p.type = 'FOOD_TECH' THEN 1 ELSE 0 END) FOOD_TECH
        , SUM(CASE WHEN p.type = 'IMU' THEN 1 ELSE 0 END) IMU
        , SUM(CASE WHEN p.type = 'SMARTRO' THEN 1 ELSE 0 END) SMARTRO
        , SUM(CASE WHEN p.type = 'MAGIC_POS' THEN 1 ELSE 0 END) MAGIC_POS
        , SUM(CASE WHEN p.type = 'FO_ALL_SYNC' THEN 1 ELSE 0 END) FO_ALL_SYNC
        , SUM(CASE WHEN p.type = 'NONE' THEN 1 ELSE 0 END) NONE
        , SUM(CASE WHEN p.type = 'YA_POS' THEN 1 ELSE 0 END) YA_POS
        , SUM(CASE WHEN p.type = 'FO_SYNC' THEN 1 ELSE 0 END) FO_SYNC
        , SUM(CASE WHEN p.type = 'MARKET_TECH' THEN 1 ELSE 0 END) MARKET_TECH
FROM stores s
INNER JOIN poses p
ON s.id = p.store_id
WHERE EXISTS (SELECT 1
              FROM orders
              WHERE total_price != 0
              AND store_id = s.id)
AND EXISTS (SELECT 1
            FROM tables
            WHERE device_id IS NOT NULL
            AND store_id = s.id)
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
AND s.name NOT LIKE '%QA%';

SELECT  COUNT(DISTINCT t.id) AS 테이블수
        , SUM(CASE WHEN s.name NOT LIKE '%명륜%'
            AND s.name NOT LIKE '%샤브올데이%'
            AND s.name NOT LIKE '%생활맥주%'
            AND s.name NOT LIKE '%짬뽕관%'
            AND s.name NOT LIKE '%강창구%'
            AND s.name NOT LIKE '%미도인%'
            AND s.name NOT LIKE '%크라운호프%'
            AND s.name NOT LIKE '%고반식당%'
            AND s.name NOT LIKE '%경성%'
            AND s.name NOT LIKE '%니뽕내뽕%'
            AND s.name NOT LIKE '%고깃리%'
            AND s.name NOT LIKE '%제줏간%'
            AND s.name NOT LIKE '%오봉집%'
            THEN 1 ELSE 0 END) 기타
        , SUM(CASE WHEN s.name LIKE '%명륜%' THEN 1 ELSE 0 END) 명륜
        , SUM(CASE WHEN s.name LIKE '%샤브올데이%' THEN 1 ELSE 0 END) 샤브올데이
        , SUM(CASE WHEN s.name LIKE '%생활맥주%' THEN 1 ELSE 0 END) 생활맥주
        , SUM(CASE WHEN s.name LIKE '%짬뽕관%' THEN 1 ELSE 0 END) 짬뽕관
        , SUM(CASE WHEN s.name LIKE '%강창구%' THEN 1 ELSE 0 END) 강창구진순대
        , SUM(CASE WHEN s.name LIKE '%미도인%' THEN 1 ELSE 0 END) 미도인
        , SUM(CASE WHEN s.name LIKE '%크라운호프%' THEN 1 ELSE 0 END) 크라운호프
        , SUM(CASE WHEN s.name LIKE '%고반식당%' THEN 1 ELSE 0 END) 고반식당
        , SUM(CASE WHEN s.name LIKE '%경성%' THEN 1 ELSE 0 END) 경성
        , SUM(CASE WHEN s.name LIKE '%니뽕내뽕%' THEN 1 ELSE 0 END) 니뽕내뽕
        , SUM(CASE WHEN s.name LIKE '%고깃리%' THEN 1 ELSE 0 END) 고깃리
        , SUM(CASE WHEN s.name LIKE '%제줏간%' THEN 1 ELSE 0 END) 제줏간
        , SUM(CASE WHEN s.name LIKE '%오봉집%' THEN 1 ELSE 0 END) 오봉집
FROM stores s
INNER JOIN poses p
ON s.id = p.store_id
INNER JOIN tables t
ON s.id = t.store_id
AND t.device_id IS NOT NULL
WHERE EXISTS (SELECT 1
              FROM orders
              WHERE total_price != 0
              AND store_id = s.id)
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
AND s.name NOT LIKE '%QA%';


SELECT p.fas_store_code
        , GROUP_CONCAT(DISTINCT s.name ORDER BY s.name SEPARATOR ', ') AS 매장명목록
FROM stores s
         INNER JOIN poses p
                    ON s.id = p.store_id
WHERE EXISTS (SELECT 1
              FROM orders
              WHERE total_price != 0
                AND store_id = s.id)
  AND EXISTS (SELECT 1
              FROM tables
              WHERE device_id IS NOT NULL
                AND store_id = s.id)
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
  AND p.type = 'FO_ALL_SYNC'
GROUP BY p.fas_store_code
HAVING COUNT(1) > 1;














SELECT  p.fas_store_code, s.name
FROM stores s
INNER JOIN poses p
ON s.id = p.store_id
WHERE p.type = 'FO_ALL_SYNC'
    AND EXISTS (SELECT 1
              FROM orders
              WHERE total_price != 0
              AND store_id = s.id)
AND EXISTS (SELECT 1
            FROM tables
            WHERE device_id IS NOT NULL
            AND store_id = s.id)
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
ORDER BY p.fas_store_code;


    # 운영중인 매장수, 테이블수
    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(t.id) AS 테이블수
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id);

    # 운영중인 매장수, 테이블수 상세내역
    SELECT  s.id AS 매장코드
            , s.name AS 매장명
            , t.table_count AS 테이블수
            , SUM(o.total_price) AS 매출금액
            , COUNT(o.id) AS 주문건수
    FROM orders o
    INNER JOIN stores s
    ON o.store_id = s.id
    INNER JOIN (
        SELECT store_id
                , COUNT(id) AS table_count
        FROM tables
        WHERE device_id IS NOT NULL
        GROUP BY store_id
    ) t
    ON s.id = t.store_id
    WHERE o.total_price != 0
    GROUP BY  s.id
            , s.name
            , t.table_count
    ORDER BY SUM(o.total_price) DESC;


    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(t.id) AS 테이블수
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE NOT EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
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
    AND s.name NOT LIKE '%QA%';

    SELECT  NOW() AS 기준일시
            , COUNT(t.id) AS 테이블수
            , s.id
            , s.name
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE NOT EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
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
    GROUP BY s.id, s.name
    ORDER BY s.name
    ;

    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(rd.id) AS 기기수량
    FROM reserve_store rs
    INNER JOIN stores s
    ON rs.store_id = s.id
    INNER JOIN reserve_device rd
    ON rs.store_id = rd.store_id
    WHERE EXISTS(   SELECT 1
                    FROM reserve_history rh
                    WHERE rh.created_at BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()
                    AND rs.store_id = rh.store_id);

    SELECT s.id AS 매장코드
            , s.name AS 매장명
            , COUNT(rh.id) AS 웨이팅사용량
    FROM reserve_store rs
    INNER JOIN stores s
    ON rs.store_id = s.id
    INNER JOIN reserve_history rh
    ON rh.created_at BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW()
    AND rs.store_id = rh.store_id
    GROUP BY s.id
           , s.name
    ORDER BY COUNT(rh.id) DESC;

    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(t.id) AS 테이블수
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
    AND pay_type = 'PREPAID';

    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , COUNT(t.id) AS 테이블수
    FROM stores s
    INNER JOIN tables t
    ON s.id = t.store_id
    AND t.device_id IS NOT NULL
    WHERE EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
    AND pay_type = 'POSTPAID';



    SELECT  NOW() AS 기준일시
            , COUNT(DISTINCT s.id) AS 매장수
            , SUM(CASE WHEN p.type = 'OK_POS' THEN 1 ELSE 0 END) OK_POS
            , SUM(CASE WHEN p.type = 'EASY_POS' THEN 1 ELSE 0 END) EASY_POS
            , SUM(CASE WHEN p.type = 'POS_MASTER' THEN 1 ELSE 0 END) POS_MASTER
            , SUM(CASE WHEN p.type = 'UNION_POS' THEN 1 ELSE 0 END) UNION_POS
            , SUM(CASE WHEN p.type = 'FOOD_TECH' THEN 1 ELSE 0 END) FOOD_TECH
            , SUM(CASE WHEN p.type = 'IMU' THEN 1 ELSE 0 END) IMU
            , SUM(CASE WHEN p.type = 'SMARTRO' THEN 1 ELSE 0 END) SMARTRO
            , SUM(CASE WHEN p.type = 'MAGIC_POS' THEN 1 ELSE 0 END) MAGIC_POS
            , SUM(CASE WHEN p.type = 'FO_ALL_SYNC' THEN 1 ELSE 0 END) FO_ALL_SYNC
            , SUM(CASE WHEN p.type = 'NONE' THEN 1 ELSE 0 END) NONE
            , SUM(CASE WHEN p.type = 'YA_POS' THEN 1 ELSE 0 END) YA_POS
            , SUM(CASE WHEN p.type = 'FO_SYNC' THEN 1 ELSE 0 END) FO_SYNC
            , SUM(CASE WHEN p.type = 'MARKET_TECH' THEN 1 ELSE 0 END) MARKET_TECH
    FROM stores s
    INNER JOIN poses p
    ON s.id = p.store_id
    WHERE EXISTS (SELECT 1
                  FROM orders
                  WHERE total_price != 0
                  AND store_id = s.id)
    AND EXISTS (SELECT 1
                FROM tables
                WHERE device_id IS NOT NULL
                AND store_id = s.id);