-- 1. Synthèse des commandes
-- Mettre en place une vue adaptée à ce besoin à partir des tables existantes.
CREATE OR REPLACE VIEW v_order_totals AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders       AS o
JOIN order_items  AS oi
    ON oi.order_id = o.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status;

-- Exploiter cette vue pour obtenir la liste des commandes complétées, avec leurs montants, 
-- classées par date puis par identifiant de commande.

SELECT
    order_id,
    customer_id,
    order_date,
    status,
    order_total
FROM v_order_totals
WHERE status = 'COMPLETED'
ORDER BY order_date, order_id;

-- 2. Statistiques de ventes par jour
-- Mettre en place une vue matérialisée qui fournit ces statistiques quotidiennes.

CREATE MATERIALIZED VIEW mv_daily_sales AS
SELECT
    order_date              AS sales_date,
    COUNT(*)                AS nb_orders,
    SUM(order_total)        AS total_revenue
FROM v_order_totals
WHERE status = 'COMPLETED'
GROUP BY order_date;

-- Interroger cette vue pour afficher la totalité des jours connus, classés par date.

SELECT *
FROM mv_daily_sales
ORDER BY sales_date;

-- Interroger cette même vue pour obtenir uniquement 
--les jours dont le chiffre d’affaires est supérieur ou égal à 200.

SELECT *
FROM mv_daily_sales
WHERE total_revenue >= 200
ORDER BY total_revenue DESC;

-- 3. Clients les plus rentables
-- Mettre en place une vue matérialisée qui regroupe ces informations par client.

CREATE MATERIALIZED VIEW mv_customer_revenue AS
SELECT
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(*)         AS nb_completed_orders,
    SUM(v.order_total) AS total_revenue
FROM customers      AS c
JOIN v_order_totals AS v
    ON v.customer_id = c.customer_id
WHERE v.status = 'COMPLETED'
GROUP BY
    c.customer_id,
    c.full_name,
    c.city;

-- Exploiter cette vue pour afficher la liste des clients, 
--classés du plus gros chiffre d’affaires au plus faible.
SELECT *
FROM mv_customer_revenue
ORDER BY total_revenue DESC;

-- Exploiter cette vue pour afficher uniquement 
--les clients ayant passé au moins deux commandes complétées.
SELECT *
FROM mv_customer_revenue
WHERE nb_completed_orders >= 2
ORDER BY total_revenue DESC;


-- 4. Optimisation via index
CREATE INDEX idx_mv_daily_sales_date
    ON mv_daily_sales (sales_date);

CREATE INDEX idx_mv_customer_revenue_total
    ON mv_customer_revenue (total_revenue);


-- 5. Données à jour vs vues matérialisées

SELECT *
FROM mv_daily_sales
WHERE sales_date = DATE '2024-05-04';


INSERT INTO orders (order_id, customer_id, order_date, status)
VALUES (7, 2, DATE '2024-05-04', 'COMPLETED');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
    (8, 7, 3, 1, 89.00),
    (9, 7, 4, 1, 19.90);

SELECT *
FROM mv_daily_sales
WHERE sales_date = DATE '2024-05-04';

REFRESH MATERIALIZED VIEW mv_daily_sales;

SELECT *
FROM mv_daily_sales
WHERE sales_date = DATE '2024-05-04';