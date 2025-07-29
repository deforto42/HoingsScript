# 101114 : 화화돈_판교점
# 100129 : 보들설곰탕

SET @store_id = 100129;
SET @start_dt = '2025-06-01 00:00:00';
SET @end_dt = '2025-06-30 23:59:59';

    SELECT      CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.id ELSE '' END '주문ID'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN s.id ELSE '' END '매장코드'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN s.name ELSE '' END '매장명'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.table_code ELSE '' END '테이블코드'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.table_name ELSE '' END '테이블명'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.no ELSE '' END '주문번호'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.created_at ELSE '' END '주문일시'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.paid_price ELSE '' END '선불주문금액'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.total_price ELSE '' END '총 주문금액'
                , ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) 'NO'
                , om.menu_code '메뉴코드'
                , om.menu_name '메뉴명'
                , om.menu_price '메뉴 단가'
                , om.menu_quantity '메뉴 수량'
                , om.menu_total_price '메뉴 합산금액'
                , oo.option_code '옵션코드'
                , oo.option_name '옵션명'
                , oo.option_price '옵션 단가'
                , oo.option_quantity '옵션 수량'
                , o.id orderId
                , om.id orderMenuId
                , oo.id orderOptionId
    FROM        orders o
    INNER JOIN  order_menus om
    ON          o.id = om.order_id
    LEFT OUTER JOIN order_options oo
    ON          om.id = oo.order_menu_id
    INNER JOIN  stores s
    ON          o.store_id = s.id
    WHERE       o.store_id = @store_id
    AND         o.created_at BETWEEN @start_dt AND @end_dt
    AND         o.status = 'SUCCESS'
    UNION ALL
    SELECT      CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.id ELSE '' END '주문ID'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN s.id ELSE '' END '매장코드'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN s.name ELSE '' END '매장명'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.table_code ELSE '' END '테이블코드'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.table_name ELSE '' END '테이블명'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.no ELSE '' END '주문번호'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.created_at ELSE '' END '주문일시'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.paid_price ELSE '' END '선불주문금액'
                , CASE ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) WHEN 1 THEN o.total_price ELSE '' END '총 주문금액'
                , ROW_NUMBER() OVER (PARTITION BY o.id ORDER BY om.id) 'NO'
                , om.menu_code '메뉴코드'
                , om.menu_name '메뉴명'
                , om.menu_price '메뉴 단가'
                , om.menu_quantity '메뉴 수량'
                , om.menu_total_price '메뉴 합산금액'
                , oo.option_code '옵션코드'
                , oo.option_name '옵션명'
                , oo.option_price '옵션 단가'
                , oo.option_quantity '옵션 수량'
                , o.id orderId
                , om.id orderMenuId
                , oo.id orderOptionId
    FROM        orders_bak o
    INNER JOIN  order_menus_bak om
    ON          o.id = om.order_id
    LEFT OUTER JOIN order_options_bak oo
    ON          om.id = oo.order_menu_id
    INNER JOIN  stores s
    ON          o.store_id = s.id
    WHERE       o.store_id = @store_id
    AND         o.created_at BETWEEN @start_dt AND @end_dt
    AND         o.status = 'SUCCESS'
    ORDER BY    orderId
                , orderMenuId
                , orderOptionId;

    SELECT      order_id '주문ID'
                , approve_no '승인번호'
                , approve_dt '승인일시'
                , card_name '카드명'
                , card_num '카드번호'
                , total_amount '결제금액'
                , cancel_dt '취소일시'
    FROM        payments p
    WHERE       p.store_id IS NULL
    AND         p.order_id IN ( SELECT id
                                FROM v_orders
                                WHERE store_id = @store_id
                                AND created_at BETWEEN @start_dt AND @end_dt)
    AND         p.created_at BETWEEN @start_dt AND @end_dt
    UNION ALL
    SELECT      order_id '주문ID'
                , approve_no '승인번호'
                , approve_dt '승인일시'
                , card_name '카드명'
                , card_num '카드번호'
                , total_amount '결제금액'
                , cancel_dt '취소일시'
    FROM        payments p
    WHERE       p.store_id = @store_id
    AND         p.created_at BETWEEN @start_dt AND @end_dt
    ORDER BY    '주문ID';
