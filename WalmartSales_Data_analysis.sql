SELECT * FROM walmart.walmartsalesdata;
alter table walmart.walmartsalesdata rename walmart ;
select* from walmart;
desc walmart;

/*
"alter table walmart add primary key (InvoiceID)" 	will give a error 
so create a new table for better name allocation of the columns
*/
create table walmart.sales (InvoiceID varchar(100) primary key,
Branch varchar(5) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(10) not null,
product_line varchar(101) not null,
unit_price Decimal(10,2)not null,
quantity int not null,
VAT Float(6,4) not null,
total Decimal(12,4)not null,
date datetime not null,
time time not null,
payment_method varchar(15) not null,
cogs decimal(10,2) not null,
gross_margin_pct float(11,9) not null,
gross_income decimal(12,4) not null,
rating float(4,1) not null);

insert into sales  select * from walmart;
desc sales;
select * from sales;

/* ANALYSIS LIST : */

/*Product Analysis :
			Conduct analysis on the data to understand the different product lines, the products lines
			performing best and the product lines that need to be improved.*/
 
 -- --------------------------------------------------------------------------------------------------------
 -- ---------------------------------------  Feature Engineering -------------------------------------------
 -- time of day
 
 select time,
( case 
		when  time between '00:00:00' and "12:00:00" then 'Morning'
        when  time between '12:00:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
   end             
 )  as time_of_date from sales;

# time_of_date (Morning,Afternoon,Evening)

alter table sales add column time_of_day varchar(20);

update sales 
set time_of_day =( 
case 
		when  time between '00:00:00' and "12:00:00" then 'Morning'
        when  time between '12:00:00' and '16:00:00' then 'Afternoon'
        else 'Evening'
	end
   );
   
select * from sales;
   
   # day_name
   
   select date,
   dayname(date) from sales;
   
   alter table sales add column day_name varchar(15);
   
   update sales 
   set day_name= dayname(date);
	
    select * from sales;
 
 # Month_name

select date,monthname(date) from sales;

alter table sales add column month_name varchar(20);

update sales
set month_name=monthname(date);

select * from sales;

-- -------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------


 -- --------------------------------------------------------------------------------------------------------
 -- --------------------------------------------  Generic --------------------------------------------------

-- How many unique cities does the data have ?
select distinct(city) from sales;

-- In which city is each branch ?
select distinct(city),branch from sales;

-- --------------------------------------------------------------------------------------------------------


 -- --------------------------------------------------------------------------------------------------------
 -- --------------------------------------------  Product  --------------------------------------------------

select * from sales;

-- How many unique product lines does the data have?
select Distinct(Product_line) from sales;
select count(Distinct(Product_line)) from sales;

-- What is the most common payment method ?
select distinct(payment_method),count(payment_method) over(partition by payment_method) as count 
from sales order by count desc;

-- what is the most selling product line?
select product_line,count(product_line) as count  from sales group by product_line  order by count desc;

-- what is the total revenue by month ?
select count(*), year(date)  from sales group by year(date);
# making sure that we have only sales of one year.

select distinct(month_name) as month_name ,
sum(total) over(partition by month_name) as Total_revenue
from sales order by total_revenue desc;

-- What month has the largest COGS ?
select distinct(month_name),
sum(cogs) over(partition by month_name) as total_COGS 
from sales order by total_cogs desc;


-- What product line has the largest revenue ?
select distinct(product_line),
sum(total) over(partition by product_line ) as total_revenue 
from sales order by total_revenue desc ;

select distinct(product_line),
sum(total) over(partition by product_line ) as total_revenue 
from sales order by total_revenue desc limit 1;

-- Which is the city,branch with the largest revenue ?
select * from sales;

select distinct(city),
sum(total) over(partition by city) as total_revenue 
from sales order by total_revenue desc;

select city,branch, sum(total) as total_revenue 
from sales 
group by city,branch 
order by total_revenue desc;

-- What product line has highest individual VAT per sale ?

select product_line,avg(VAT) as avg_tax
from sales 
group by product_line 
order by avg_tax desc;																

-- What product line has generates the most VAT overall ?
select product_line,sum(VAT) as total_VAT
from sales 
group by product_line 
order by Total_VAT desc;


-- which branch sold more product than the average product sold?
select avg(total) from sales;

select  branch,sum(quantity) from sales 
group by branch 
having sum(quantity) > (select avg(quantity) from sales);


/*-- Fetch each product line and add a column to those product line showing "Good","Bad".\
    Good if its greater than average sales*/

select distinct(product_line),avg(total) over(partition by product_line )as average
 from sales;

select *, case
			when t.avg_prod >  (select avg(total) from sales) then "Good"
            else "Bad"
          end as performance  
 from(
select distinct(product_line),avg(total) over(partition by product_line ) as avg_prod 
 from sales) as t ;

-- What is the most common product line by gender ?

select distinct(product_line),gender,
count(*)over(partition by product_line,gender )as count 
from sales ;

-- What is the average rating of each product line ?

select product_line,Avg(rating) as  avg_rating 
from sales 
group by product_line 
order by avg_rating desc;
 -- --------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------


 -- --------------------------------------------------------------------------------------------------------
 -- --------------------------------------------  Sales  ---------------------------------------------------
 
 -- Number of sales made in each time of the day per weekday
 select * from sales;
 select day_name,count(*) as 'no of sales' 
 from sales 
 group by day_name 
 order by 
	 CASE day_name
		WHEN 'Sunday' THEN 1
		WHEN 'Monday' THEN 2
		WHEN 'Tuesday' THEN 3
		WHEN 'Wednesday' THEN 4
		WHEN 'Thursday' THEN 5
		WHEN 'Friday' THEN 6
		WHEN 'Saturday' THEN 7
	  END; 

-- Which of the customer types brings the most revenue ?

select customer_type,sum(total) as Revenue 
from sales 
group by customer_type
order by Revenue desc ;

-- Which city has the largest tax percent / VAT(Value Added Tax) ?

select city,sum(VAT) as tax_percent 
from sales 
group by city 
order by tax_percent desc ;

-- Which Customer type pays the most in VAT ?

select customer_type,sum(VAT) as Total_VAT
 from sales 
 group by customer_type 
 order by  Total_VAT desc;

 -- --------------------------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------  Customer  ------------------------------------------------

-- 1. How Many unique customer types does the data have ?
select count(distinct(customer_type)) from sales;

-- 2. How many unique payment methods does the data have ?
 
 select distinct(payment_method) from sales;

 select count(distinct(payment_method)) from sales;
 
 -- 3.  What is the most common customer type ?
 
 select customer_type,count(*) as Frequency from sales
 group by customer_type
 order by Frequency desc;
 
 -- 4. which customer type buys the most ?
 
 select customer_type,sum(total) as Total_spent 
 from sales 
 group by  customer_type 
 order by Total_spent desc;


-- 5. What is the gender of most customers ?
select gender,count(*) from sales 
group by gender
order by count(*) desc ;
 
-- 6. What is the gender distribution per branch ?
select branch,gender,count(*) as Frequency 
from sales 
group by branch,gender  
order by Branch asc;

-- 7. Which time of the day do customer gives most ratings ?
select distinct(rating) from sales;

select time_of_day,avg(rating) 
from sales 
group by time_of_day 
order by avg(rating) desc;

-- 8. Which time of the day do customer gives most ratings  per branch ?

select branch,time_of_day,avg(rating) as rating
from sales 
group by time_of_day,branch 
order by rating desc;
 

select   first_value(branch)over(partition by branch order by rating desc) as branch,
		 first_value(time_of_day)over(partition by branch order by rating desc) as Time,
		 first_value(rating)over(partition by branch order by rating desc) as Rating 
         from (
				select branch,time_of_day,avg(rating) as rating
				from sales 
				group by time_of_day,branch
			  ) as t;
 
 select distinct(branch),time,rating from (
				  select first_value(branch)over(partition by branch order by rating desc) as branch,
				 first_value(time_of_day)over(partition by branch order by rating desc) as Time,
				 first_value(rating)over(partition by branch order by rating desc) as Rating from (
						 select branch,time_of_day,avg(rating) as rating
						from sales 
						group by time_of_day,branch
				 ) as t 
 ) as t2;
 
 
 -- 9.  Which day of the week  has the best avg ratings ?
 
 select day_name,avg(rating) as Rating 
 from sales 
 group by day_name 
 order by rating desc ;

-- 10.  Which day of the week  has the best avg ratings  per branch ?

select day_name,branch,avg(rating) as Rating 
 from sales 
 group by day_name,branch 
 order by branch asc ;
 
select first_value(day_name) over w as Day_name,
		first_value(branch) over w as branch,
        first_value(Rating) over w as rating from
        (
         select day_name,branch,avg(rating) as Rating 
		 from sales 
		 group by day_name,branch 
		 order by branch asc          
        ) as t
        window w as (partition by branch order by rating desc);
  
 select distinct(branch),day_name,Rating  from (
		select first_value(day_name) over w as Day_name,
		first_value(branch) over w as branch,
        first_value(Rating) over w as rating from
        (
         select day_name,branch,avg(rating) as Rating 
		 from sales 
		 group by day_name,branch 
		 order by branch asc          
        ) as t
        window w as (partition by branch order by rating desc)
 )  as t2;
 
       /*  --------------------------------------------------------------------------------*/
 with my_cte as ( select day_name,branch,avg(rating) as Rating 
		 from sales 
		 group by day_name,branch 
		 order by branch asc )
 select * from my_cte;
        
-- --------------------------------------------------------------------------------------------------------


