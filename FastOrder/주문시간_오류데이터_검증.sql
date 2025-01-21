SELECT s.name '매장명'
        , o.table_name '테이블'
        , mg.name '카테고리'
        , m.name '메뉴'
        , DATE_FORMAT(o.created_at, '%Y-%m-%d %H:%i:%s') '주문시간'
FROM orders o
INNER JOIN stores s
ON o.store_id = s.id
INNER JOIN order_menus om
ON o.id = om.order_id
INNER JOIN menus m
ON om.menu_id = m.id
INNER JOIN menu_groups mg
ON m.menu_group_id = mg.id
WHERE 1=1
# AND o.store_id = 101171
AND (
    DATE_FORMAT(o.created_at, '%H:%i:%s') < mg.sales_start_at
        OR DATE_FORMAT(o.created_at, '%H:%i:%s') > mg.sales_end_at
    )
;

SELECT s.name '매장명'
        , o.table_name '테이블'
        , mg.name '카테고리'
        , m.name '메뉴'
        , DATE_FORMAT(o.created_at, '%Y-%m-%d %H:%i:%s') '주문시간'
FROM orders o
INNER JOIN stores s
ON o.store_id = s.id
INNER JOIN order_menus om
ON o.id = om.order_id
INNER JOIN menus m
ON om.menu_id = m.id
INNER JOIN menu_groups mg
ON m.menu_group_id = mg.id
INNER JOIN calendar cal
ON DATE_FORMAT(o.created_at, '%Y-%m-%d') = cal.date
WHERE 1=1
# AND o.store_id = 101171
AND mg.is_sales_hours_applied = true
AND IFNULL(mg.is_sale_weekdays, false) = true
AND IFNULL(mg.is_sale_weekends, false) = false
AND (cal.is_holiday = true OR cal.is_weekend = true)
;

SELECT s.name '매장명'
        , o.table_name '테이블'
        , mg.name '카테고리'
        , m.name '메뉴'
        , DATE_FORMAT(o.created_at, '%Y-%m-%d %H:%i:%s') '주문시간'
FROM orders o
INNER JOIN stores s
ON o.store_id = s.id
INNER JOIN order_menus om
ON o.id = om.order_id
INNER JOIN menus m
ON om.menu_id = m.id
INNER JOIN menu_groups mg
ON m.menu_group_id = mg.id
INNER JOIN calendar cal
ON DATE_FORMAT(o.created_at, '%Y-%m-%d') = cal.date
WHERE 1=1
# AND o.store_id = 101171
AND mg.is_sales_hours_applied = true
AND IFNULL(mg.is_sale_weekdays, false) = false
AND IFNULL(mg.is_sale_weekends, false) = true
AND (cal.is_holiday = false AND cal.is_weekend = false)
;