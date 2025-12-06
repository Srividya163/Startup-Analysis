Select * from playstore_reviews;

update playstore_reviews2
set userName = CONCAT( 
upper(left(userName,1)),
lower(substring(userName,2))
);

update playstore_reviews3
set userName = CONCAT(
upper(left(userName,1)),
lower(substring(userName,2))
);

CREATE TABLE playstore_reviews as
select * from playstore_reviews2
union all
select * from playstore_reviews3;

-- sentiment Analysis
select company,
round(sum(case when score>=4 then 1 else 0 end)*100.0/count(*),2) as positive,
round(sum(case when score=3 then 1 else 0 end)*100.0/count(*),2) as neutral,
round(sum(case when score<=2 then 1 else 0 end)*100.0/count(*),2) as negetive
from playstore_reviews
group by company;

-- Average rating trend over time(Monthly)
select company,
date_format(review_date,'%Y-%m') as review_month,
round(avg(score)) as avg_rating
from playstore_reviews
group by company,date_format(review_date,'%Y-%m')
order by company, review_month;

-- count reviews per month
select company,
date_format(review_date,'%Y-%m') as review_month,
count(*) as Total
from playstore_reviews
group by company,date_format(review_date,'%Y-%m') 
order by company,review_month;

-- correlated with major events within time intrval
select company,max(avg_rating) as highest from(	
    select p.company,
	f.Date,
	date_format(p.review_date,'%Y-%m') as review_month,
	round(avg(p.score),2) as avg_rating
	from playstore_reviews p 
	join fundlist f on p.company=f.Company_name
	group by p.company,f.Date,date_format(p.review_date,'%Y-%m')
	order by f.Date,p.company)t 
group by company;

-- total count of reviews for each company
select company,count(*) as n_rating from playstore_reviews
group by company
order by n_rating desc;

-- total funds raised,number of rounds and avg gap between rounds
select company_name,count(*) as total_rounds,
sum(amount_usd) as total_raised_amount
from fundlist
group by Company_name
order by total_rounds desc;

select Company_name,
round(avg(datediff(next_day,Date)),2) as avg_gap_days
from (
	select company_name,Date,
	lead(Date) over(partition by company_name order by Date) as next_day
	from fundlist)t
where next_day is not null
group by Company_name;

-- Stage wise funding Analysis
select Company_name,Funding_round,(total_fund) as highestfund from
(select company_name,
funding_round,
count(*) as total_rounds,
sum(Amount_usd) as total_fund
from fundlist
group by Company_name,Funding_round
order by Company_name,field(funding_round,'Series A','Series B','Series C','Series D','Series E','Series F','Series G','Undisclosed')
)t group by company_name,Funding_round
order by highestfund desc;

-- compare investment growth rate between startups
select Company_name,
date_format(Date,'%Y-%m') as Month,
sum(Amount_usd) as raised_per_month,
sum(sum(Amount_usd)) over(partition by Company_name order by date_format(Date,'%Y-%m')) as cumulative_raise
from fundlist
group by Company_name,date_format(Date,'%Y-%m')
order by Company_name,Month;

-- Evaluating first funding year
select Company_name,Investor,
min(Date) as start_of_funding
from fundlist
group by Company_name,Investor
order by start_of_funding;

-- checking relation betweeen funding spikes and performance
select f.company_name,
Year(f.date) as funding_year,
sum(f.Amount_usd) as funding_amount,
t.year,
t.flipkart_visits_Million,
t.Snapdeal_visits_Million from fundlist f
join website_traffic t on year(f.Date)=t.year 
group by f.Company_name,
year(f.Date),
t.year,
t.Flipkart_Visits_Million,
t.Snapdeal_Visits_Million
order by funding_year;

-- MARKET SHARE
-- Year on year market share
select company1,year,round(avg(Market_share_per1),2) as avg_share from market_share
group by company1,year 
order by avg_share desc;

select company2,year,round(avg(Market_share_per2),2) as avg_share from market_share
group by company2,year
order by avg_share desc; 

-- yearly percentage growth/decline
select m1.company1,m1.year as current_share,m1.market_share_per1,m2.market_share_per1,
round(((m1.market_share_per1-m2.market_share_per1)/m2.market_share_per1)*100,2) as growth_perc
from market_share m1
join market_share m2 on m1.company1=m2.company1 and m1.year=m2.year+1
order by m1.company1,m1.year;

select m1.company2,m1.year,m1.market_share_per2,m2.market_share_per2,
round(((m1.market_share_per2-m2.market_share_per2)/m2.market_share_per2)*100,2) as growth_perc 
from market_share m1
join market_share m2 on m1.company2=m2.company2 and m1.year=m2.year+1
order by m1.company2,m1.year;

-- creating a view
DROP VIEW IF EXISTS unified_market_share;
CREATE VIEW unified_market_share AS
select company1 as company,
market_share_per1 as market_share,
year as year
from market_share
union all
select company2 as company,
Market_share_per2 as market_share,
year as year
from market_share;

select * from unified_market_share;

-- Market share before vs after major milestone
select m.company,f.Date,
round(avg(case when m.year<year(f.Date) then m.market_share end),2) as avg_before,
round(avg(case when m.year>= year(f.Date) then m.market_share end),2) as avg_after
from unified_market_share m 
join fundlist f on m.company=f.Company_name
group by m.company,f.Date;

-- Benchmark againist industry average
select m.company,m.year,m.market_share,
(select avg(m1.market_share) from unified_market_share m1
where m1.year=m.year) as industry_avg,
m.market_share-(select avg(market_share) from unified_market_share m1
where m1.year=m.year) as diff_from_avg
from unified_market_share m
order by m.year ,m.company;

-- Market Concentration
select year,sum(power(market_share,2)) as hhi
from unified_market_share
group by year 
order by year;






