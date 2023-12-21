USE company_marketing
-- Create View to view all campaign_num for place = website
CREATE OR ALTER VIEW V_website(campaign_num)
AS
	SELECT campaign_num
	FROM target_place_prom 
	WHERE place_id=100

SELECT * FROM V_website

-----
-- Create View to view customer who buy prouduct 125
CREATE OR ALTER VIEW  cut_view(c_id,education,income)

AS
	SELECT c.c_id,c.education,c.income
	from cust_prod cp INNER JOIN customer c
	ON cp.prod_id=125 AND c.c_id= cp.c_id

SELECT * FROM cut_view

sp_helptext cut_view

--------------------------------------------------------------------------------

-- Functions

-- Create Scaler function to get result of Campaign 

SELECT * FROM target_place_prom

CREATE FUNCTION Getresult_of_year(@target_date INT)
returns int
  BEGIN 
    DECLARE @campaign INT
       SELECT @campaign = result_of_cam 
	   FROM target_place_prom
	   WHERE target_date = @target_date
	   RETURN @campaign  
  END 
  SELECT dbo.Getresult_of_year  (2016) AS result_of_cam


------------------------------------------------------------------------------------

-- Creat multi_function to get amount of product where write a spesific
CREATE FUNCTION Getamount(@format varchar(10))
RETURN @t table (c_id INT , prod_id INT , date DATE)
AS
 BEGIN
     IF @format = 'few'
	 BEGIN 
		 INSERT into @t 
		 SELECT c_id , prod_id, date
		 FROM cust_prod
		 WHERE Amount between 0 and 200
      END
    ELSE IF @format = 'many'
	 BEGIN 
		 INSERT into @t 
		 SELECT c_id , prod_id, date
		 FROM cust_prod
		 where Amount between 201 and 500
      END
	  ELSE IF  @format = 'extra'
      BEGIN 
		 INSERT into @t 
		 SELECT c_id , prod_id, date
		 FROM cust_prod
		 where Amount > 500
      END

	 RETURN
 END 

SELECT * FROM Getamount('few')

 --------------------------------------------------------------------------------------------

-- Create PROC that take campaign_num and return result, target of a year and if it achieved or not
CREATE or alter PROCEDURE getcam_statues @campaign_num INT
AS
BEGIN
    DECLARE @Target_date INT, @target_camp int, @Result INT, @StatusMessage VARCHAR(100)
--BEGIN TRY
    SELECT @Target_date = t.target_date, @target_camp=target_of_promotion, @Result = result_of_cam
    FROM target_place_prom p,target t
    WHERE p.target_date = t.target_date 

    IF @Result >= @target_camp
        SET @StatusMessage = 'Achieved'
    ELSE
        SET @StatusMessage = 'Not Achieved'

    SELECT @target_camp AS TargetValue, @Result AS ResultValue, @StatusMessage AS CampaignStatus
--END TRY
--BEGIN CATCH
--SELECT
--ERROR_LINE() as error_line
--, ERROR_PROCEDURE() as error_proc;
--end catch
END;
--go 

EXec getcampaignstatues @campaign_num =9;


----------------------------------------------------------------------------------------------

CREATE OR ALTER TRIGGER addcustomer
ON customer
AFTER insert
AS
  SELECT 'new customer'
  SELECT c_id,year_birth,dt_of_enroll,income FROM inserted

 INSERT INTO customer
	(
		c_id,year_birth,education,marital_statues,income,kidhome,
		teenhome,dt_of_enroll,recnency,complain
	)
 VALUES 
	(
	53,1979,'Graduation','Married',13000,1,2,'2020-12-02 00:00:00',33,0
	),
	(
	54,1979,'Graduation','Married',13000,1,2,'2020-12-02 00:00:00',33,0
	)


-- Create CURSOR that incrase  price 5% if product price < 100 and if price > 100 increse it 10%
 DECLARE c2 CURSOR
FOR 
  SELECT price
  FROM product
FOR UPDATE
DECLARE @price decimal
OPEN c2
FETCH c2 INTO @price
WHILE @@fetch_status = 0 
BEGIN
	IF(@price < 100)
		BEGIN 
		   UPDATE product
		   SET price= 1.05 * price 
		   WHERE CURRENT OF c2 
		END
    ELSE
	BEGIN
	  UPDATE product 
		SET price = 1.1 * price 
		 WHERE CURRENT OF c2 
     end
	 FETCH c2 INTO @price
END
CLOSE c2
DEALLOCATE c2

----------------------------------------------------------------------------------------------

-- Test to Create an index on column (c_id) that allow to cluster
-- the data in the table customer. What will happen?
CREATE CLUSTERED INDEX cust_cluster
	ON customer([c_id])

	SELECT * FROM customer

CREATE NONCLUSTERED INDEX noncust_cluster
	ON product([price])
	
	SELECT * FROM product

--------------------------------------------------------------------------------------------------

-- Average income and education level of customers:
SELECT education, AVG(income) AS Average_income
FROM customer
GROUP BY education;

-------------------------------------------------------------------------------------------------

-- Customers with complaints and their recency of purchase:
SELECT c_id, recnency, complain
FROM customer
WHERE complain <> 0;

-------------------------------------------------------------------------------------------------

-- Product with highest Sales and Revenue
SELECT TOP 5 pr.id, pr.name, SUM(cp.Amount) AS Total_Sales, SUM(cp.Amount * pr.price) AS Total_Revenue
FROM cust_prod cp
JOIN product pr ON cp.prod_id = pr.id
GROUP BY pr.id, pr.name
ORDER BY total_sales DESC, total_revenue DESC;

-------------------------------------------------------------------------------------------------

-- Places with the most customer interest:
SELECT name, num_of_interest
FROM place
ORDER BY num_of_interest DESC;