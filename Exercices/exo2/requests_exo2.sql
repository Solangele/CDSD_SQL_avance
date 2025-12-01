-- 1
CREATE OR REPLACE VIEW sql_avance2.info_commandes AS
SELECT orders.order_id,
	   customers.customer_id,  
	   orders.order_date, 
	   orders.status,
	   SUM(quantity*unit_price) AS total_order
FROM sql_avance2.customers
INNER JOIN sql_avance2.orders ON customers.customer_id = orders.customer_id
INNER JOIN sql_avance2.order_items ON orders.order_id = order_items.order_id
GROUP BY orders.order_id,
		 customers.customer_id, 
	     order_date, 
	     status;

SELECT * FROM sql_avance2.info_commandes
WHERE status = 'COMPLETED'
ORDER BY order_date;


-- 2
CREATE MATERIALIZED VIEW sql_avance2.tableau_de_bord AS
SELECT 
	orders.order_id,
	order_date,
	SUM(quantity*unit_price) AS total_order
FROM sql_avance2.orders
INNER JOIN sql_avance2.order_items ON orders.order_id = order_items.order_id
WHERE status = 'COMPLETED'
GROUP BY orders.order_id,order_date;

SELECT * FROM sql_avance2.tableau_de_bord WHERE total_order > 200;



-- 3
CREATE MATERIALIZED VIEW sql_avance2.clients_interessants AS
SELECT 
	customers.customer_id,
	COUNT(orders.order_id) AS nb_commandes,
	SUM(quantity*unit_price) AS total_order
FROM sql_avance2.customers
INNER JOIN sql_avance2.orders ON customers.customer_id = orders.customer_id
INNER JOIN sql_avance2.order_items ON orders.order_id = order_items.order_id
WHERE status = 'COMPLETED'
GROUP BY customers.customer_id;

SELECT * FROM sql_avance2.clients_interessants
ORDER BY total_order DESC;

SELECT * FROM sql_avance2.clients_interessants
where nb_commandes >= 2;


-- 4
CREATE INDEX idx_date_order
	ON sql_avance2.tableau_de_bord (order_date);

-- 5
INSERT INTO sql_avance2.orders (order_id, customer_id, order_date, status)
VALUES (7, 2, DATE '2024-05-04', 'COMPLETED');

INSERT INTO sql_avance2.order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
    (8, 7, 3, 1, 89.00),
    (9, 7, 4, 1, 19.90);

SELECT * FROM sql_avance2.info_commandes
WHERE status = 'COMPLETED'
ORDER BY order_date;

SELECT * FROM sql_avance2.tableau_de_bord ;

REFRESH MATERIALIZED VIEW sql_avance2.tableau_de_bord ;

SELECT * FROM sql_avance2.tableau_de_bord ;
 -- il a fallu faire un refresh de la vue matérialisée pour mettre à jour les données
 -- ce qui n'a pas été le cas pour la vue simple de la question 1