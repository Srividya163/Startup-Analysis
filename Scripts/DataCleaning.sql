select * from playstore_reviews;
update playstore_reviews
set review_date=str_to_date(review_date,'%d-%m-%Y');

ALTER TABLE playstore_reviews
modify review_date DATE;

SET SQL_SAFE_UPDATES=0;

select * from flipkartpricing;

ALTER TABLE flipkartpricing
modify date DATE;

select * from fundlist;

UPDATE fundlist
SET DATE=str_to_date(DATE,'%d-%m-%Y');

Alter Table fundlist
modify Date DATE;

select * from social_media;

Alter table social_media
modify Date DATE;

update playstore_reviews2
set review_date=str_to_date(review_date,'%d-%m-%Y');

Alter Table playstore_reviews2
modify review_date Date;

update playstore_reviews3
set review_date=str_to_date(review_date,'%d-%m-%Y');

Alter Table playstore_reviews3
modify review_date Date;

Alter Table website_traffic
add column Company_name char(10);

update website_traffic
set Company_name='flipkart';

set sql_safe_updates=0;

alter table website_traffic
add column company2 char(10);

update website_traffic
set company2='Snapdeal';
