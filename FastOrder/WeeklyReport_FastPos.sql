-- 패스트포스 매장 리스트
SELECT name
FROM company c
WHERE EXISTS (SELECT *
              FROM order_list
              WHERE company_serial = c.serial
              AND registered_date BETWEEN DATE_SUB(NOW(), INTERVAL 7 DAY) AND NOW())
    AND c.name NOT LIKE '%테스트%'
    AND c.name NOT LIKE '%이관전%'
    AND c.name NOT LIKE '%영업%'
    AND c.name NOT LIKE '%사무실%'
    AND c.name NOT LIKE '%폐업%'
    AND c.name NOT LIKE '%쇼룸%'
    AND c.name NOT LIKE '%쇼륨%'
    AND c.name NOT LIKE '%본사%'
    AND c.name NOT LIKE '%시안%'
    AND c.name NOT LIKE '%시연%'
    AND c.name NOT LIKE '%웹 연동%'
    AND c.name NOT LIKE '%QA%'
    AND c.name NOT LIKE '%타키%'
ORDER BY registered_date DESC;

