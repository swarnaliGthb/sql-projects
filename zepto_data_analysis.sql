create table zepto(
	sku_id serial primary key,
	category varchar(50),
	name varchar(50) not null,
	mrp nume	
)

-- Q: Which rows have missing (null) values in any key column? (data quality check)
select * from zepto where name is null or category is null or discountPercentage is null or discountedSellingPrice is null or weightInGms is null or availableQuantity is null or outofstock is null or quantity is null;

-- Q: Which rows have missing (null) values in any key column? (earlier attempt, column name typo)
select * from zepto where name is null or category is null or discountPercent is null or discountedSellingPrice is null or weightInGms is null or availableQuantity is null or outofstock is null or quantity is null;

-- Q: What are all the unique product categories?
select distinct category from zepto order by category;

-- Q: How many products are in stock vs out of stock?
select outofstock, count(sku_id) from zepto group by outofstock;

-- Q: Which product names have duplicate SKUs (appear more than once)?
select name, count(sku_id) as "Number of SKUs" from zepto group by name having count(sku_id) > 1 order by count(sku_id) desc;

-- Q: Which products have a price of zero? (data quality check)
select * from zepto where mrp = 0 or discountedsellingprice = 0;

-- Q: Remove rows where MRP is zero (data cleaning).
delete from zepto where mrp = 0;

-- Q: Convert the mrp and discountedSellingPrice columns from paise to rupees.
update zepto set mrp = mrp / 100.0, discountedsellingprice = discountedSellingprice / 100.0;

-- Q: View MRP and discounted selling price for all products. (earlier attempt, column name typo)
select mrp, descountedsellingprice from zepto;

-- Q: View MRP and discounted selling price for all products.
select mrp, discountedsellingprice from zepto;

-- Q1. Find the top 10 best-value products based on the discount percentage. (earlier attempt, "distinct" typo)
select distinctname, mrp, discountpercent from zepto order by discountpercent desc limit 10;

-- Q1. Find the top 10 best-value products based on the discount percentage.
select distinct name, mrp, discountpercent from zepto order by discountpercent desc limit 10;

-- Q2. What are the Products with High MRP but Out of Stock?
select distinct name, mrp from zepto where outofstock = true and mrp > 300 order by mrp desc;

-- Q3. Calculate Estimated Revenue for each category.
select category, sum(discountedsellingprice * availablequantity) as total_revenue from zepto group by category order by total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%. (earlier attempt, column name typo)
select distinct name, mrp, discountpercent from zepto where mrp > 500 and discountpercent < 10 order by mrp desc, discountpercentage desc;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
select distinct name, mrp, discountpercent from zepto where mrp > 500 and discountpercent < 10 order by mrp desc, discountpercent desc;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
select category, round(avg(discountpercent), 2) as avg_discount from zepto group by category order by avg_discount desc limit 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
select distinct name, weightingms, discountedsellingprice, round(discountedsellingprice / weightingms) as price_per_gram from zepto where weightingms >= 100 order by price_per_gram;

-- Q7. Group the products into categories like Low, Medium, Bulk.
select distinct name, weightingms, case when weightingms < 1000 then 'Low' when weightingms < 5000 then 'Medium' else 'Bulk' end as weight_category from zepto;

-- Q8. What is the Total Inventory Weight Per Category?
select category, sum(weightingms * availablequantity) as total_weight from zepto group by category order by total_weight;