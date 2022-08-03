--***************************************************************************************************************************
--*********************************************** WELCOME TO MT SQL CASE STUDIES ********************************************
--***************************************************************************************************************************


-- ************************************************ CREATE A NEWTABLE: sale *************************************************
DROP TABLE sale;

CREATE TABLE sale (
	customer_id VARCHAR(1),
	order_date DATE,
	product_id INT
	);

-- INSERT VALUES INTO THE NEWLY CREATED sale TABLE
INSERT INTO sale (customer_id, order_date, product_id)
	VALUES  ('A', '2022-01-01', '1'),
		('A', '2022-01-01', '2'),
		('A', '2022-01-07', '2'),
		('A', '2022-01-10', '3'),
		('A', '2022-01-11', '3'),
		('A', '2022-01-11', '3'),
		('B', '2022-01-01', '2'),
		('B', '2022-01-02', '2'),
		('B', '2022-01-04', '1'),
		('B', '2022-01-11', '1'),
		('B', '2022-01-16', '3'),
		('B', '2022-02-01', '3'),
		('C', '2022-01-01', '3'),
		('C', '2022-01-01', '3'),
		('C', '2022-01-07', '3');

SELECT * FROM sale;

--**************************************************** CREATE A NEW TABLE: menu *********************************************
-- DROP menu TABLE IF IT ALREADY EXISTS IN THE DATABASE
DROP TABLE menu;

CREATE TABLE menu (
	product_id INT,
	product_name VARCHAR(5),
	price INT
	);

-- CHANGE THE product_name MINIMUM LENGHT FROM 5 TO 15
ALTER TABLE menu
ALTER COLUMN product_name VARCHAR(15);

-- INSERT VALUS INTO THE NEWLY CREATED menu TABLE
INSERT INTO menu (product_id, product_name, price)
	VALUES ('1', 'Jollof Rice', 1000),
		('2', 'Ofada Rice', 1500),
		('3', 'Pottage', 1200);

SELECT * FROM menu;
--**************************************************** CREATE A NEW TABLE: members *********************************************
-- DROP memebers TABLE IF IT ALREADY EXISTS IN THE DATABASE
DROP TABLE members;

CREATE TABLE members (
	customer_id VARCHAR(1),
	join_date DATE
);

-- INSERT VALUS INTO THE NEWLY CREATED members TABLE
INSERT INTO members (customer_id, join_date)
	VALUES
		('A', '2022-01-07'),
		('B', '2022-01-09');

SELECT * FROM members;

--*****************************************************************************************************************************
--***************************************************** RECONFIRM DATA TYPES **************************************************
--*****************************************************************************************************************************
-- CHECK FOR DATA TYPES IN ALL TABLES
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE 
FROM (SELECT * FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME IN ('sale', 'menu', 'members')) members_information;


--*****************************************************************************************************************************
--******************************************************* CASE STUDIES ********************************************************
--*****************************************************************************************************************************

-- merge the sale, menu, and members table together
GO
CREATE VIEW sale_menu_members 
AS 
(
	SELECT s.customer_id, mem.join_date, s.order_date, s.product_id, m.product_name, m.price
	FROM sale AS s 
	LEFT JOIN menu AS m
	ON s.product_id = m.product_id
	LEFT JOIN members AS mem
	ON s.customer_id = mem.customer_id
);
GO

--*********************************************************************
-- Q1: What is the total amount each customer spent at the restaurant?
--*********************************************************************

SELECT customer_id, SUM(price) total_amount 
FROM sale_menu_members
GROUP BY customer_id;



--*************************************************************
-- Q2: How many days has each customer visited the restaurant?
--*************************************************************

SELECT customer_id, COUNT(customer_id) no_of_viait 
FROM sale_menu_members
GROUP BY customer_id;


select * from sale_menu_members

--******************************************************************************************************
-- Q3: What is the most purchased item on the menu and how many times was it purchased by all customers?
--******************************************************************************************************

SELECT TOP 1 product_name, COUNT(product_name) no_of_purchase  FROM sale_menu_members
GROUP BY product_name
ORDER BY no_of_purchase DESC;



--*******************************************************************************************
-- Q4: What is the total items and amount spent for each member before they became a member?
--*******************************************************************************************

-- USING CTE FOR SUBQUERY
WITH before_joined_date (customer_id, join_ate, order_date, price) 
AS
(
	SELECT customer_id, join_date, order_date, price 
	FROM sale_menu_members
	WHERE order_date < join_date
)
SELECT customer_id, SUM(price) total_amount
FROM before_joined_date
GROUP BY customer_id;



--***********************************************************************
-- Q5: What was the first item from the menu purchased by each customer?
--***********************************************************************

WITH first_A_product (customer_id, product_name)
AS
(
	SELECT TOP 1 customer_id, product_name 
	FROM sale_menu_members
	WHERE customer_id = 'A'
),
first_B_product (customer_id, product_name)
AS
(
	SELECT TOP 1 customer_id, product_name 
	FROM sale_menu_members
	WHERE customer_id = 'B'
),
first_C_product (customer_id, product_name)
AS
(
	SELECT TOP 1 customer_id, product_name 
	FROM sale_menu_members
	WHERE customer_id = 'C'
)
SELECT * FROM first_A_product
UNION
SELECT * FROM first_B_product
UNION
SELECT * FROM first_C_product;

--******************* USING WINDOW FUNCTION ***********************
WITH baba (customer_id, product_name, ranked) 
AS
(
	SELECT customer_id, product_name, ROW_NUMBER() OVER (PARTITION BY  customer_id ORDER BY customer_id) ranked 
	FROM sale_menu_members
	)
SELECT * FROM baba;




--**********************************************************************************************************
-- Q6: Recreate the table with: customer_id, order_date, product_name, price, Is_member (Y/N) as thecolumns.
--**********************************************************************************************************

WITH is_customer_member (customer_id, order_date, product_name, price, is_customer_member) 
AS
(
	SELECT customer_id, order_date, product_name, price, 
		CASE
			WHEN join_date IS NULL
				THEN 'N'
			ELSE 'Y'
		END is_customer_member
	From sale_menu_members
)
SELECT * INTO new_sale
FROM is_customer_member;

-- test the new sale data
SELECT * FROM new_sale;

