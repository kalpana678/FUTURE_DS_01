---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- This is my First Project as a Intern @ Future Interns --
-- I am  Analyze e-commerce data to identify best-selling products, sales trends, and high-revenue categories and many more insights using the SQL-- 
-- I am performed data analysis using SQL using the E-Commerce Dataset and Sloved 15+ questions --
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Create the database for import the E-Commerce dataset ---
create database Business_Analysis;

-- reterive the data from the tables one by one 
select * from dbo.Orders_new_table;
select * from dbo.People;
select * from dbo.Returns;

--- basic queries --
-- 1 select top 10 customers from orders table who buy the products most (in this question there is no clear mention of sales so in most sql queries Sales is
--- is used as a measure of buying most because in business, spending more=more valuable customer.)

select Top 10 
		Customer_ID,
		Sum(Sales) as TotalSales
from dbo.Orders_new_table
group by Customer_ID
order by TotalSales Desc;

------------------------------------------------------------------------------------
---(note : for find the trend use Sum for analysis not max, min, avg)
-------------------------------------------------------------------------------------
-- 2  select which category product sells the most 
select 
	Category, 
	Product_Name,
	Sum(Sales) as totalSales
from dbo.Orders_new_table
group by Category, Product_Name
order by totalSales desc;

-- 3 At what period of the year the sales has increased
select 
	Month( Order_Date) as month , 
	Year(Order_Date)  as year, 
	Sum(Sales) as Monthly_Sales 
from dbo.Orders_new_table
group by Year(Order_Date), Month(Order_Date)
Order by month, year;

-- 4 which product are most profitable?
select Top 10 max(Profit),Product_Name
from dbo.Orders_new_table
group by Product_Name;


-- 5 which regions or cities give the highest profit vs highest sales
select 
	Region, 
	Sum(Profit) as Total_Prft,
	Sum(Sales) as Total_Sales
from dbo.Orders_new_table
group by Region 
Order by Total_Prft desc;

-- 6 which category gives the highest revenue and profit contribution
select 
	Category, 
	sum(Profit) as Total_proft
from dbo.Orders_new_table
group by Category;


-- 7 what is the impact of dicounts on sales and profit (Recheking)
select  Top 10
	Product_Name,
	Sum(discount)as discount,
	Sum(Sales) as sales, 
	Sum(Profit) as profit
from dbo.Orders_new_table
group by Product_Name
Order by sales, profit desc;

 
--- Customer Analysis---
-- 8 Who are the top 5 customers by profit(not just sales)?
select Top 5 
	Customer_ID, 
	Sum(Profit) as Total_Profit
from dbo.Orders_new_table
group by Customer_ID
Order by Total_Profit desc;

-- 9 Which customers got the highest discounts and did they generated profit or loss?

with customer_discount as (
	select
		Customer_ID,
		max(Discount) as max_discount,
		sum(Sales) as total_Sales,
		Sum(Profit) as Total_Profit
	from dbo.Orders_new_table
	Group by Customer_ID
)
select Top 1 
	Customer_ID, 
	max_discount *100 as max_dis_percentage,
	Total_Profit,
	total_Sales,
	Case
		When Total_Profit > 0 then 'Profit'
		else 'Loss'
	end as Profit_Status
from customer_discount
order by max_discount desc;
 
 -- Customers retention. 
-- 10 How many customers bought in multiple years?
With cust_yr as ( 
	select Distinct 
		Customer_ID, 
		Year(Order_Date) as Order_Yr
	from dbo.Orders_new_table
)
select Customer_ID, 
	Count(Distinct Order_Yr) as Yr_Active
from cust_yr
group by Customer_ID
having count(Distinct Order_Yr) > 1 
order by Yr_Active desc;


--- Product and Category Analysis---
-- 11 Which subcategory has the highest sales vs lowest profit?
select   Sub_Category, max(Sales) as highest_Sales, min(Profit) as lowest_Profit
from dbo.Orders_new_table
group by Sub_Category;

-- 12 What are the most returned product?
select max(Returned), O.Product_Name, O.Order_ID
from dbo.Returns R
join dbo.Orders_new_table O
on R.Order_ID = O.Order_ID
group by O.Product_Name;



-- 13 which products have negative profit margins (loss-making items)?
select Product_ID, Product_Name, Profit
from dbo.Orders_new_table
where Profit =

--- regional Analysis --
-- 14 Which region contributes the highest sales and profit?
Select  Region, 
	sum(Sales) as Total_sales
from dbo.Orders_new_table
group by Region 
order by Total_Sales Desc;


-- 15 Which cities are high sales but low profit (discount issue)?
select 
	City, 
	Sum(Sales) as total_sales,
	Sum(Profit) as totalprofit
from dbo.Orders_new_table
group by City
Having Sum(Sales) > 10000.0 and Sum(Profit) < 2000.0
order by total_sales desc;

-- 16 Compare average order value by region
-- note : avg order value = Total sales divded by number of orders 
-- multipling by 1.0 to ensure decimal division (aviods integer rounding in SQL) 
select 
	Region,
	sum(Sales) * 1.0 / count(Distinct Order_ID) as Avg_Order_Value
from dbo.Orders_new_table
group by Region
order by Avg_Order_Value desc;

--- Discount impact---
-- 17 How does discount% affect profit?(eg is high discount = low profit)
select 
	Cast(Discount * 100 as decimal(5,0)) as discount_pert,
	sum(Sales) as Total_sales,
	Sum(Profit) as TotalProfit,
	avg(Profit) as avg_profitPerOrder
from dbo.Orders_new_table
group by Discount
Order by Discount;

-- 18  Which categories are most affected by discounts?
select Category,
	Sum(Sales) as Total_Sales,
	Sum(Profit) as Total_Profit,
	Sum(Discount) as Total_Discount
from dbo.Orders_new_table
group by Category;
  

--- Time Trends---
--  19 Sales by month/Quarter -identify seasonal patterns
select 
	Year(Order_Date) as OrderYr,
	Month(Order_Date) as OrderMonth,
	DATENAME( Month, Order_Date) as monthname,
	Sum(Sales) as Total_Sales
From dbo.Orders_new_table
group by Year (Order_Date), Month(Order_Date), DATENAME(Month, Order_Date) 
order by OrderYr, OrderMonth desc;

--  20 year over year growth(2011-2012)
select 
	Year(Order_Date) as Order_Yr,
	Sum(Sales) as total_sales
from dbo.Orders_new_table
where Year(Order_Date) in (2011, 2012)
group by Year(Order_Date)
order by Order_Yr ;

--- Returns---
-- 21 What % of orders are returned overall?
select 
	(count(Distinct r.Order_ID) * 100.0 / count(Distinct o.Order_ID)) as Return_Percentage
from dbo.Orders_new_table o
left join dbo.Returns r
on o.Order_ID = r.Order_ID;


-- 22 Which category has the highest return rate?
select 
	o.Category,
	count(Distinct r.Order_ID) * 100.0 / count(Distinct o.Order_ID) as Return_rate_percentage
from dbo.Orders_new_table o
left join dbo.Returns r
on o.Order_ID = r.Order_ID
group by o.Category
order by  Return_rate_percentage desc;
 
 -----------------------------------------------------------------END-------------------------------------------------------------------------------------------------------------
