--SQL Advance Case Study


--Q1--BEGIN 
SELECT DISTINCT(l1.State) FROM FACT_TRANSACTIONS as t1
inner join DIM_LOCATION as l1 on t1.IDLocation=l1.IDLocation
WHERE t1.Date BETWEEN '01-01-2005' AND Getdate()



--Q1--END

--Q2--BEGIN
SELECT State FROM (SELECT TOP 1 l.State, SUM(t.Quantity) as Total_Quantity FROM FACT_TRANSACTIONS as t	
inner join DIM_LOCATION as l on t.IDLocation=l.IDLocation
inner join DIM_MODEL as m on t.IDModel=m.IDModel
inner join DIM_MANUFACTURER as ma on m.IDManufacturer=ma.IDManufacturer
WHERE l.Country='US' AND ma.Manufacturer_Name='Samsung'
GROUP BY l.State
ORDER BY Total_Quantity desc) as f



--Q2--END

--Q3--BEGIN      
	
SELECT m.Model_Name, l.ZipCode, l.State, COUNT(t.IDCustomer) as Total_Transactions FROM DIM_LOCATION as l
inner join FACT_TRANSACTIONS as t
on t.IDLocation=l.IDLocation
inner join DIM_MODEL as m
on t.IDModel=m.IDModel
GROUP BY m.Model_Name, l.ZipCode, l.State




--Q3--END

--Q4--BEGIN

SELECT top 1 Model_Name, Unit_price FROM DIM_MODEL
ORDER BY Unit_price




--Q4--END

--Q5--BEGIN
SELECT mo1.Model_Name, ROUND(AVG(f1.TotalPrice), 3) as Average_Price FROM FACT_TRANSACTIONS as f1
inner join DIM_MODEL as mo1 on f1.IDModel=mo1.IDModel
inner join DIM_MANUFACTURER as ma1 on mo1.IDManufacturer=ma1.IDManufacturer
WHERE ma1.Manufacturer_Name IN (
SELECT Manufacturer_Name From (SELECT top 5 ma.Manufacturer_Name, SUM(t.TotalPrice) as Sales FROM FACT_TRANSACTIONS as t
inner join DIM_MODEL as mo
on t.IDModel=mo.IDModel
inner join DIM_MANUFACTURER as ma
on mo.IDManufacturer=ma.IDManufacturer
GROUP BY ma.Manufacturer_Name
ORDER BY Sales desc) t1)
GROUP BY mo1.Model_Name
ORDER BY Average_Price

--Q5--END

--Q6--BEGIN
SELECT c.Customer_Name, AVG(t.TotalPrice) as Average_Price FROM FACT_TRANSACTIONS as t
inner join DIM_CUSTOMER as c
on t.IDCustomer=c.IDCustomer
inner join DIM_DATE as d
on t.Date=d.DATE
WHERE d.YEAR='2009'
GROUP BY c.Customer_Name
Having AVG(t.TotalPrice)>500
ORDER BY Average_Price



--Q6--END
	
--Q7--BEGIN  
	
SELECT * FROM	
(SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(Date)='2008'
GROUP BY IDModel
ORDER BY SUM(Quantity) desc
intersect
SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(Date)='2009'
GROUP BY IDModel
ORDER BY SUM(Quantity) desc
intersect
SELECT top 5 IDModel FROM FACT_TRANSACTIONS
WHERE YEAR(Date)='2009'
GROUP BY IDModel
ORDER BY SUM(Quantity) desc) as T1


--Q7--END	
--Q8--BEGIN
SELECT * FROM (
SELECT top 1* FROM (SELECT top 2 ma1.Manufacturer_Name as [Manufacturer], SUM(t1.TotalPrice) as [Total Sales], YEAR(t1.Date) as [Year] FROM FACT_TRANSACTIONS as t1
inner join DIM_MODEL as mo1 on t1.IDModel=mo1.IDModel
inner join DIM_MANUFACTURER as ma1 on mo1.IDManufacturer=ma1.IDManufacturer
WHERE YEAR(t1.Date)='2009'
GROUP BY ma1.Manufacturer_Name, YEAR(t1.Date)
ORDER BY SUM(t1.TotalPrice) desc) as s1
ORDER BY s1.[Total Sales]
union all
SELECT top 1* FROM (SELECT top 2 ma2.Manufacturer_Name as [Manufacturer], SUM(t2.TotalPrice) as [Total Sales], YEAR(t2.Date) as [Year] FROM FACT_TRANSACTIONS as t2
inner join DIM_MODEL as mo2 on t2.IDModel=mo2.IDModel
inner join DIM_MANUFACTURER as ma2 on mo2.IDManufacturer=ma2.IDManufacturer
WHERE YEAR(t2.Date)='2010'
GROUP BY ma2.Manufacturer_Name, YEAR(t2.Date)
ORDER BY SUM(t2.TotalPrice) desc) as s2
ORDER BY s2.[Total Sales]
) as S


--Q8--END
--Q9--BEGIN
	
SELECT * FROM (SELECT DISTINCT(t3.Manufacturer_Name) FROM FACT_TRANSACTIONS as t1
inner join DIM_MODEL as t2 on t1.IDModel=t2.IDModel
inner join DIM_MANUFACTURER as t3 on t2.IDManufacturer=t3.IDManufacturer
WHERE YEAR(t1.Date)=2010
EXCEPT
SELECT DISTINCT(t3.Manufacturer_Name) FROM FACT_TRANSACTIONS as t1
inner join DIM_MODEL as t2 on t1.IDModel=t2.IDModel
inner join DIM_MANUFACTURER as t3 on t2.IDManufacturer=t3.IDManufacturer
WHERE YEAR(t1.Date)=2009) as S








--Q9--END

--Q10--BEGIN
SELECT C.Customer_Name, YEAR(T.Date) as [Year], AVG(T.TotalPrice) as [Average Spend], AVG(T.Quantity) as [Average Quantity],	
--SUM(T.TotalPrice) as Total, --(SUM(T.TotalPrice)-(LAG(SUM(T.TotalPrice), 1) OVER (PARTITION BY C.Customer_Name ORDER BY Year(T.Date)))),
case when (SUM(T.TotalPrice)-(LAG(SUM(T.TotalPrice), 1) OVER (PARTITION BY C.Customer_Name ORDER BY Year(T.Date)))) IS NULL then 'NULL'
ELSE CONCAT(((SUM(T.TotalPrice)-(LAG(SUM(T.TotalPrice), 1) OVER (PARTITION BY C.Customer_Name ORDER BY Year(T.Date))))/(SUM(T.TotalPrice))*100), ' %') end as [Percentage Change] 
FROM FACT_TRANSACTIONS as T
inner join DIM_CUSTOMER as C on t.IDCustomer=C.IDCustomer
WHERE c.IDCustomer IN 
(SELECT top 100 C1.IDCustomer FROM FACT_TRANSACTIONS as T1
inner join DIM_CUSTOMER as C1 on T1.IDCustomer=C1.IDCustomer
GROUP BY C1.IDCustomer
ORDER BY SUM(T1.TotalPrice) desc)
GROUP BY C.Customer_Name, YEAR(T.Date)
ORDER BY C.Customer_Name, YEAR(T.Date)






--Q10--END
	