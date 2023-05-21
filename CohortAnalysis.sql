-- cleaning data 

with online_retail as 
(	select InvoiceNo,
		   StockCode,
		   Description,
		   Quantity,
		   InvoiceDate,
		   UnitPrice,
		   CustomerID,
		   Country

	from PortfofolProject..Online_retail
	where CustomerID is not null
), quantity_unit_price as 
(

	select *
	from online_retail
	where Quantity>0 and UnitPrice>0
), dup_check as
(-- duplicate check 
select *,ROW_NUMBER() over(partition by InvoiceNo,StockCode,Quantity,UnitPrice order by InvoiceDate )dup_flag  from quantity_unit_price
)

select * 
into #online_retail_main -- temporary table
from dup_check
where dup_flag =1
 --clean data
 -- Begin 
select * from #online_retail_main
--Unique Indentifier(CusomerID)
-- Inital Start Date ( First Invoice Date)
--Revenue Data 

select CustomerID,
	   min(InvoiceDate) as first_purchase_date,
	   DATEFROMPARTS( year(min(InvoiceDate)),MONTH( min(InvoiceDate)),1) as Cohort_Date
into #cohort
from #online_retail_main
group by CustomerID

select *
from #cohort
-- Create cohort index

select
	mmm.*,
	cohort_index= year_diff*12 +month_diff+1
into #cohort_retention
from 
	(
		select
			mm.*,
			year_diff = invoice_year-cohort_year,
			month_diff =invoice_month-cohort_month
		from
				(	select
						m.*,
						c.Cohort_Date,
						year(m.InvoiceDate) invoice_year,
						month(m.InvoiceDate) invoice_month,
						year(c.Cohort_Date) cohort_year,
						month(c.Cohort_Date) cohort_month
					from #online_retail_main m
						left join #cohort c
							on c.CustomerID= m.CustomerID
				)mm
		)mmm
-- grouping customers by cohort index
select * from #cohort_retention
select distinct
		CustomerID,
		Cohort_Date,
		cohort_index
from #cohort_retention
order by 1,3

select distinct 
		cohort_index
from #cohort_retention 
order by cohort_index 
select * from #cohort_retention
--pivot data to see the cohort table	
select *
into #cohort_pivot
from(
	select distinct
		 CustomerID,
		 Cohort_Date,
		 cohort_index
	from #cohort_retention
)tbl
pivot(
	Count(CustomerID)
	for Cohort_Index in 
		(	[1],
			[2],
			[3],
			[4],
			[5],
			[6],
			[7],
			[8],
			[9],
			[10],
			[11],
			[12],
			[13])
) as pivot_table
select 
	1.0*[1]/[1]*100 as [1],
	1.0*[2]/[1]*100 as [2],
	1.0*[3]/[1]*100 as [3],
	1.0*[4]/[1]*100 as [4],
	1.0*[5]/[1]*100 as [5],
	1.0*[6]/[1]*100 as [6],
	1.0*[7]/[1]*100 as [7],
	1.0*[8]/[1]*100 as [8],
	1.0*[9]/[1]*100 as [9],
	1.0*[10]/[1]*100 as [10],
	1.0*[11]/[1]*100 as [11],
	1.0*[12]/[1]*100 as [12],
	1.0*[13]/[1]*100 as [13]
	
from #cohort_pivot
order by Cohort_Date

	
