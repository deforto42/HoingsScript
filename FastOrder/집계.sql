CREATE TABLE report_monthly_order (
                                      id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                      store_id      BIGINT         NOT NULL,
                                      ym            CHAR(7)        NOT NULL COMMENT 'YYYY-MM',
                                      order_cnt     INT            NOT NULL DEFAULT 0,
                                      order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                      month_start   DATETIME       NOT NULL,
                                      month_end     DATETIME       NOT NULL,
                                      created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                      updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                          ON UPDATE CURRENT_TIMESTAMP,
                                      PRIMARY KEY (id),
                                      UNIQUE KEY ux_monthly_store_ym (store_id, ym),
                                      KEY idx_ym (ym)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE report_monthly_menu (
                                     id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                     store_id      BIGINT         NOT NULL,
                                     ym            CHAR(7)        NOT NULL COMMENT 'YYYY-MM',
                                     menu_code     VARCHAR(100)   NOT NULL,
                                     menu_name     VARCHAR(255)   NOT NULL,
                                     order_cnt     INT            NOT NULL DEFAULT 0,
                                     order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                     rank_cnt      INT            NOT NULL DEFAULT 0,
                                     rank_amount   INT            NOT NULL DEFAULT 0,
                                     month_start   DATETIME       NOT NULL,
                                     month_end     DATETIME       NOT NULL,
                                     created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                     updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
                                     PRIMARY KEY (id),
                                     UNIQUE KEY ux_monthly_store_menu_ym (store_id, ym, menu_code),
                                     KEY idx_ym (ym),
                                     KEY idx_store_ym (store_id, ym)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE report_monthly_option (
                                       id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                       store_id      BIGINT         NOT NULL,
                                       ym            CHAR(7)        NOT NULL COMMENT 'YYYY-MM',
                                       menu_code     VARCHAR(100)   NOT NULL,
                                       menu_name     VARCHAR(255)   NOT NULL,
                                       option_code   VARCHAR(100)   NOT NULL,
                                       option_name   VARCHAR(255)   NOT NULL,
                                       order_cnt     INT            NOT NULL DEFAULT 0,
                                       order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                       rank_cnt      INT            NOT NULL DEFAULT 0,
                                       rank_amount   INT            NOT NULL DEFAULT 0,
                                       month_start   DATETIME       NOT NULL,
                                       month_end     DATETIME       NOT NULL,
                                       created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                       updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                           ON UPDATE CURRENT_TIMESTAMP,
                                       PRIMARY KEY (id),
                                       UNIQUE KEY ux_monthly_store_menu_opt_ym (
                                           store_id, ym, menu_code, option_code
                                           ),
                                       KEY idx_ym (ym),
                                       KEY idx_store_ym (store_id, ym),
                                       KEY idx_menu (menu_code),
                                       KEY idx_option (option_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_monthly_order $$
CREATE PROCEDURE sp_upsert_monthly_order (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_month_start DATETIME;
    DECLARE v_month_end   DATETIME;

    -- 이번 달의 시작일과 말일
    SET v_month_start = DATE_FORMAT(p_target_date, '%Y-%m-01 00:00:00');
    SET v_month_end   = CONCAT(LAST_DAY(p_target_date), ' 23:59:59');

    -- 데이터 upsert
INSERT INTO report_monthly_order (
    store_id,
    ym,
    order_cnt,
    order_amount,
    month_start,
    month_end
)
SELECT
    t.store_id,
    t.ym,
    SUM(t.cnt)   AS order_cnt,
    SUM(t.price) AS order_amount,
    v_month_start,
    v_month_end
FROM (
         -- orders
         SELECT
             o.store_id,
             DATE_FORMAT(o.created_at, '%Y-%m') AS ym,
             COUNT(o.id)                        AS cnt,
             SUM(o.total_price)                 AS price
         FROM orders o
         WHERE o.created_at BETWEEN v_month_start AND v_month_end
           AND o.status = 'SUCCESS'
         GROUP BY o.store_id, DATE_FORMAT(o.created_at, '%Y-%m')

         UNION ALL

         -- orders_bak
         SELECT
             o.store_id,
             DATE_FORMAT(o.created_at, '%Y-%m') AS ym,
             COUNT(o.id)                        AS cnt,
             SUM(o.total_price)                 AS price
         FROM orders_bak o
         WHERE o.created_at BETWEEN v_month_start AND v_month_end
           AND o.status = 'SUCCESS'
         GROUP BY o.store_id, DATE_FORMAT(o.created_at, '%Y-%m')
     ) t
WHERE t.ym IS NOT NULL
GROUP BY t.store_id, t.ym
    ON DUPLICATE KEY UPDATE
                         order_cnt    = VALUES(order_cnt),
                         order_amount = VALUES(order_amount),
                         month_start  = VALUES(month_start),
                         month_end    = VALUES(month_end);
END $$

DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_monthly_menu $$
CREATE PROCEDURE sp_upsert_monthly_menu (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_month_start DATETIME;
    DECLARE v_month_end   DATETIME;

    -- 기준 날짜의 월 시작/끝 계산
    SET v_month_start = DATE_FORMAT(p_target_date, '%Y-%m-01 00:00:00');
    SET v_month_end   = CONCAT(LAST_DAY(p_target_date), ' 23:59:59');

INSERT INTO report_monthly_menu (
    store_id,
    ym,
    menu_code,
    menu_name,
    order_cnt,
    order_amount,
    rank_cnt,
    rank_amount,
    month_start,
    month_end
)
SELECT
    base.store_id,
    base.ym,
    base.menu_code,
    base.menu_name,
    base.cnt,
    base.amount,
    -- 수량 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ym
            ORDER BY base.cnt DESC
        ) AS rank_cnt,
        -- 금액 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ym
            ORDER BY base.amount DESC
        ) AS rank_amount,
    v_month_start,
    v_month_end
FROM (
         SELECT
             store_id,
             ym,
             menu_code,
             menu_name,
             SUM(cnt)   AS cnt,
             SUM(price) AS amount
         FROM (
                  -- ORDERS
                  SELECT
                      o.store_id                           AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m')   AS ym,
                      om.menu_code,
                      om.menu_name,
                      SUM(om.menu_quantity)                AS cnt,
                      SUM(om.menu_total_price)             AS price
                  FROM orders o
                           INNER JOIN order_menus om
                                      ON o.id = om.order_id
                  WHERE o.created_at BETWEEN v_month_start AND v_month_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m'),
                      om.menu_code,
                      om.menu_name

                  UNION ALL

                  -- ORDERS_BAK
                  SELECT
                      o.store_id                           AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m')   AS ym,
                      om.menu_code,
                      om.menu_name,
                      SUM(om.menu_quantity)                AS cnt,
                      SUM(om.menu_total_price)             AS price
                  FROM orders_bak o
                           INNER JOIN order_menus_bak om
                                      ON o.id = om.order_id
                  WHERE o.created_at BETWEEN v_month_start AND v_month_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m'),
                      om.menu_code,
                      om.menu_name
              ) t
         WHERE ym IS NOT NULL
         GROUP BY
             store_id,
             ym,
             menu_code,
             menu_name
     ) AS base
ORDER BY
    base.ym,
    base.store_id,
    base.cnt DESC
    ON DUPLICATE KEY UPDATE
                         menu_name     = VALUES(menu_name),
                         order_cnt     = VALUES(order_cnt),
                         order_amount  = VALUES(order_amount),
                         rank_cnt      = VALUES(rank_cnt),
                         rank_amount   = VALUES(rank_amount),
                         month_start   = VALUES(month_start),
                         month_end     = VALUES(month_end);
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_monthly_option $$
CREATE PROCEDURE sp_upsert_monthly_option (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_month_start DATETIME;
    DECLARE v_month_end   DATETIME;

    -- 기준 날짜가 속한 월의 시작/끝 계산
    SET v_month_start = DATE_FORMAT(p_target_date, '%Y-%m-01 00:00:00');
    SET v_month_end   = CONCAT(LAST_DAY(p_target_date), ' 23:59:59');

INSERT INTO report_monthly_option (
    store_id,
    ym,
    menu_code,
    menu_name,
    option_code,
    option_name,
    order_cnt,
    order_amount,
    rank_cnt,
    rank_amount,
    month_start,
    month_end
)
SELECT
    base.store_id,
    base.ym,
    base.menu_code,
    base.menu_name,
    base.option_code,
    base.option_name,
    base.cnt,
    base.amount,

    -- 수량 기준 랭킹 (같은 매장, 같은 월, 같은 메뉴 안에서 옵션 랭킹)
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ym, base.menu_code
            ORDER BY base.cnt DESC
        ) AS rank_cnt,

        -- 금액 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ym, base.menu_code
            ORDER BY base.amount DESC
        ) AS rank_amount,

    v_month_start,
    v_month_end
FROM (
         SELECT
             store_id,
             ym,
             menu_code,
             menu_name,
             option_code,
             option_name,
             SUM(cnt)   AS cnt,
             SUM(price) AS amount
         FROM (
                  -- ORDERS + ORDER_MENUS + ORDER_OPTIONS
                  SELECT
                      o.store_id                         AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m') AS ym,
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name,
                      SUM(oo.option_quantity)                   AS cnt,
                      SUM(oo.option_quantity * oo.option_price) AS price
                  FROM orders o
                           INNER JOIN order_menus om
                                      ON o.id = om.order_id
                           INNER JOIN order_options oo
                                      ON om.id = oo.order_menu_id
                  WHERE o.created_at BETWEEN v_month_start AND v_month_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m'),
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name

                  UNION ALL

                  -- ORDERS_BAK + ORDER_MENUS_BAK + ORDER_OPTIONS_BAK
                  SELECT
                      o.store_id                         AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m') AS ym,
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name,
                      SUM(oo.option_quantity)                   AS cnt,
                      SUM(oo.option_quantity * oo.option_price) AS price
                  FROM orders_bak o
                           INNER JOIN order_menus_bak om
                                      ON o.id = om.order_id
                           INNER JOIN order_options_bak oo
                                      ON om.id = oo.order_menu_id
                  WHERE o.created_at BETWEEN v_month_start AND v_month_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m'),
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name
              ) t
         WHERE ym IS NOT NULL
         GROUP BY
             store_id,
             ym,
             menu_code,
             menu_name,
             option_code,
             option_name
     ) AS base
ORDER BY
    base.ym,
    base.store_id,
    base.menu_code,
    base.cnt DESC
    ON DUPLICATE KEY UPDATE
                         menu_name     = VALUES(menu_name),
                         option_name   = VALUES(option_name),
                         order_cnt     = VALUES(order_cnt),
                         order_amount  = VALUES(order_amount),
                         rank_cnt      = VALUES(rank_cnt),
                         rank_amount   = VALUES(rank_amount),
                         month_start   = VALUES(month_start),
                         month_end     = VALUES(month_end);
END $$

DELIMITER ;

CREATE TABLE report_daily_order (
                                    id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                    store_id      BIGINT         NOT NULL,
                                    ymd           CHAR(10)       NOT NULL COMMENT 'YYYY-MM-DD',
                                    order_cnt     INT            NOT NULL DEFAULT 0,
                                    order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                    day_start     DATETIME       NOT NULL,
                                    day_end       DATETIME       NOT NULL,
                                    created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                    updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                        ON UPDATE CURRENT_TIMESTAMP,
                                    PRIMARY KEY (id),
                                    UNIQUE KEY ux_daily_store_ymd (store_id, ymd),
                                    KEY idx_ymd (ymd)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE report_daily_menu (
                                   id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                   store_id      BIGINT         NOT NULL,
                                   ymd           CHAR(10)       NOT NULL COMMENT 'YYYY-MM-DD',
                                   menu_code     VARCHAR(100)   NOT NULL,
                                   menu_name     VARCHAR(255)   NOT NULL,
                                   order_cnt     INT            NOT NULL DEFAULT 0,
                                   order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                   rank_cnt      INT            NOT NULL DEFAULT 0,
                                   rank_amount   INT            NOT NULL DEFAULT 0,
                                   day_start     DATETIME       NOT NULL,
                                   day_end       DATETIME       NOT NULL,
                                   created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                       ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (id),
                                   UNIQUE KEY ux_daily_store_menu_ymd (store_id, ymd, menu_code),
                                   KEY idx_ymd (ymd),
                                   KEY idx_store_ymd (store_id, ymd)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE report_daily_option (
                                     id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
                                     store_id      BIGINT         NOT NULL,
                                     ymd           CHAR(10)       NOT NULL COMMENT 'YYYY-MM-DD',
                                     menu_code     VARCHAR(100)   NOT NULL,
                                     menu_name     VARCHAR(255)   NOT NULL,
                                     option_code   VARCHAR(100)   NOT NULL,
                                     option_name   VARCHAR(255)   NOT NULL,
                                     order_cnt     INT            NOT NULL DEFAULT 0,
                                     order_amount  DECIMAL(15,2)  NOT NULL DEFAULT 0,
                                     rank_cnt      INT            NOT NULL DEFAULT 0,
                                     rank_amount   INT            NOT NULL DEFAULT 0,
                                     day_start     DATETIME       NOT NULL,
                                     day_end       DATETIME       NOT NULL,
                                     created_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                     updated_at    DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,
                                     PRIMARY KEY (id),
                                     UNIQUE KEY ux_daily_store_menu_opt_ymd (store_id, ymd, menu_code, option_code),
                                     KEY idx_ymd (ymd),
                                     KEY idx_store_ymd (store_id, ymd),
                                     KEY idx_menu (menu_code),
                                     KEY idx_option (option_code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_daily_order $$
CREATE PROCEDURE sp_upsert_daily_order (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_day       DATE;
    DECLARE v_day_start DATETIME;
    DECLARE v_day_end   DATETIME;

    -- 기준 날짜의 일 단위 시작/끝
    SET v_day       = DATE(p_target_date);
    SET v_day_start = CONCAT(v_day, ' 00:00:00');
    SET v_day_end   = CONCAT(v_day, ' 23:59:59');

INSERT INTO report_daily_order (
    store_id,
    ymd,
    order_cnt,
    order_amount,
    day_start,
    day_end
)
SELECT
    t.store_id,
    t.ymd,
    SUM(t.cnt)   AS order_cnt,
    SUM(t.price) AS order_amount,
    v_day_start,
    v_day_end
FROM (
         -- orders
         SELECT
             o.store_id,
             DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
             COUNT(o.id)                           AS cnt,
             SUM(o.total_price)                    AS price
         FROM orders o
         WHERE o.created_at BETWEEN v_day_start AND v_day_end
           AND o.status = 'SUCCESS'
         GROUP BY o.store_id, DATE_FORMAT(o.created_at, '%Y-%m-%d')

         UNION ALL

         -- orders_bak
         SELECT
             o.store_id,
             DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
             COUNT(o.id)                           AS cnt,
             SUM(o.total_price)                    AS price
         FROM orders_bak o
         WHERE o.created_at BETWEEN v_day_start AND v_day_end
           AND o.status = 'SUCCESS'
         GROUP BY o.store_id, DATE_FORMAT(o.created_at, '%Y-%m-%d')
     ) t
WHERE t.ymd IS NOT NULL
GROUP BY t.store_id, t.ymd
    ON DUPLICATE KEY UPDATE
                         order_cnt    = VALUES(order_cnt),
                         order_amount = VALUES(order_amount),
                         day_start    = VALUES(day_start),
                         day_end      = VALUES(day_end);
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_daily_menu $$
CREATE PROCEDURE sp_upsert_daily_menu (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_day       DATE;
    DECLARE v_day_start DATETIME;
    DECLARE v_day_end   DATETIME;

    -- 기준 날짜의 일 단위 시작/끝
    SET v_day       = DATE(p_target_date);
    SET v_day_start = CONCAT(v_day, ' 00:00:00');
    SET v_day_end   = CONCAT(v_day, ' 23:59:59');

INSERT INTO report_daily_menu (
    store_id,
    ymd,
    menu_code,
    menu_name,
    order_cnt,
    order_amount,
    rank_cnt,
    rank_amount,
    day_start,
    day_end
)
SELECT
    base.store_id,
    base.ymd,
    base.menu_code,
    base.menu_name,
    base.cnt,
    base.amount,
    -- 수량 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ymd
            ORDER BY base.cnt DESC
        ) AS rank_cnt,
        -- 금액 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ymd
            ORDER BY base.amount DESC
        ) AS rank_amount,
    v_day_start,
    v_day_end
FROM (
         SELECT
             store_id,
             ymd,
             menu_code,
             menu_name,
             SUM(cnt)   AS cnt,
             SUM(price) AS amount
         FROM (
                  -- ORDERS
                  SELECT
                      o.store_id                           AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
                      om.menu_code,
                      om.menu_name,
                      SUM(om.menu_quantity)                AS cnt,
                      SUM(om.menu_total_price)             AS price
                  FROM orders o
                           INNER JOIN order_menus om
                                      ON o.id = om.order_id
                  WHERE o.created_at BETWEEN v_day_start AND v_day_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d'),
                      om.menu_code,
                      om.menu_name

                  UNION ALL

                  -- ORDERS_BAK
                  SELECT
                      o.store_id                           AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
                      om.menu_code,
                      om.menu_name,
                      SUM(om.menu_quantity)                AS cnt,
                      SUM(om.menu_total_price)             AS price
                  FROM orders_bak o
                           INNER JOIN order_menus_bak om
                                      ON o.id = om.order_id
                  WHERE o.created_at BETWEEN v_day_start AND v_day_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d'),
                      om.menu_code,
                      om.menu_name
              ) t
         WHERE ymd IS NOT NULL
         GROUP BY
             store_id,
             ymd,
             menu_code,
             menu_name
     ) AS base
ORDER BY
    base.ymd,
    base.store_id,
    base.cnt DESC
    ON DUPLICATE KEY UPDATE
                         menu_name    = VALUES(menu_name),
                         order_cnt    = VALUES(order_cnt),
                         order_amount = VALUES(order_amount),
                         rank_cnt     = VALUES(rank_cnt),
                         rank_amount  = VALUES(rank_amount),
                         day_start    = VALUES(day_start),
                         day_end      = VALUES(day_end);
END $$

DELIMITER ;

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_daily_option $$
CREATE PROCEDURE sp_upsert_daily_option (
    IN p_target_date DATETIME
)
BEGIN
    DECLARE v_day       DATE;
    DECLARE v_day_start DATETIME;
    DECLARE v_day_end   DATETIME;

    -- 기준 날짜의 일 단위 시작/끝
    SET v_day       = DATE(p_target_date);
    SET v_day_start = CONCAT(v_day, ' 00:00:00');
    SET v_day_end   = CONCAT(v_day, ' 23:59:59');

INSERT INTO report_daily_option (
    store_id,
    ymd,
    menu_code,
    menu_name,
    option_code,
    option_name,
    order_cnt,
    order_amount,
    rank_cnt,
    rank_amount,
    day_start,
    day_end
)
SELECT
    base.store_id,
    base.ymd,
    base.menu_code,
    base.menu_name,
    base.option_code,
    base.option_name,
    base.cnt,
    base.amount,

    -- 수량 기준 랭킹 (같은 매장, 같은 일, 같은 메뉴 안에서 옵션 랭킹)
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ymd, base.menu_code
            ORDER BY base.cnt DESC
        ) AS rank_cnt,

        -- 금액 기준 랭킹
    DENSE_RANK() OVER (
            PARTITION BY base.store_id, base.ymd, base.menu_code
            ORDER BY base.amount DESC
        ) AS rank_amount,

    v_day_start,
    v_day_end
FROM (
         SELECT
             store_id,
             ymd,
             menu_code,
             menu_name,
             option_code,
             option_name,
             SUM(cnt)   AS cnt,
             SUM(price) AS amount
         FROM (
                  -- ORDERS + ORDER_MENUS + ORDER_OPTIONS
                  SELECT
                      o.store_id                          AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name,
                      SUM(oo.option_quantity)                   AS cnt,
                      SUM(oo.option_quantity * oo.option_price) AS price
                  FROM orders o
                           INNER JOIN order_menus om
                                      ON o.id = om.order_id
                           INNER JOIN order_options oo
                                      ON om.id = oo.order_menu_id
                  WHERE o.created_at BETWEEN v_day_start AND v_day_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d'),
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name

                  UNION ALL

                  -- ORDERS_BAK + ORDER_MENUS_BAK + ORDER_OPTIONS_BAK
                  SELECT
                      o.store_id                          AS store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d') AS ymd,
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name,
                      SUM(oo.option_quantity)                   AS cnt,
                      SUM(oo.option_quantity * oo.option_price) AS price
                  FROM orders_bak o
                           INNER JOIN order_menus_bak om
                                      ON o.id = om.order_id
                           INNER JOIN order_options_bak oo
                                      ON om.id = oo.order_menu_id
                  WHERE o.created_at BETWEEN v_day_start AND v_day_end
                    AND o.status = 'SUCCESS'
                  GROUP BY
                      o.store_id,
                      DATE_FORMAT(o.created_at, '%Y-%m-%d'),
                      om.menu_code,
                      om.menu_name,
                      oo.option_code,
                      oo.option_name
              ) t
         WHERE ymd IS NOT NULL
         GROUP BY
             store_id,
             ymd,
             menu_code,
             menu_name,
             option_code,
             option_name
     ) AS base
ORDER BY
    base.ymd,
    base.store_id,
    base.menu_code,
    base.cnt DESC
    ON DUPLICATE KEY UPDATE
                         menu_name    = VALUES(menu_name),
                         option_name  = VALUES(option_name),
                         order_cnt    = VALUES(order_cnt),
                         order_amount = VALUES(order_amount),
                         rank_cnt     = VALUES(rank_cnt),
                         rank_amount  = VALUES(rank_amount),
                         day_start    = VALUES(day_start),
                         day_end      = VALUES(day_end);
END $$

DELIMITER ;



DELIMITER $$

DROP PROCEDURE IF EXISTS sp_upsert_reports $$
CREATE PROCEDURE sp_upsert_reports (
    IN p_target_date DATETIME
)
BEGIN
    /*
      공통 기준일(p_target_date)을 기준으로
      - 매장 월별 주문 집계(report_monthly_order)
      - 메뉴 월별 집계(report_monthly_menu)
      - 옵션 월별 집계(report_monthly_option)
      - 매장 일별 주문 집계(report_daily_order)
      - 메뉴 일별 집계(report_daily_menu)
      - 옵션 일별 집계(report_daily_option)
      를 한 번에 적재/업데이트한다.
    */

    -- 1) 매장 단위 월별 주문 집계
CALL sp_upsert_monthly_order(p_target_date);

-- 2) 메뉴 단위 월별 집계 + 랭킹
CALL sp_upsert_monthly_menu(p_target_date);

-- 3) 옵션 단위 월별 집계 + 랭킹
CALL sp_upsert_monthly_option(p_target_date);

-- 4) 매장 단위 일별 주문 집계
CALL sp_upsert_daily_order(p_target_date);

-- 5) 메뉴 단위 일별 집계 + 랭킹
CALL sp_upsert_daily_menu(p_target_date);

-- 6) 옵션 단위 일별 집계 + 랭킹
CALL sp_upsert_daily_option(p_target_date);

END $$

DELIMITER ;
