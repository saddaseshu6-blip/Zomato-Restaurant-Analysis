create database `Zomato`;
use `Zomato`;
CREATE TABLE Restaurants (
    RestaurantID BIGINT PRIMARY KEY,
    RestaurantName VARCHAR(255),
    CountryCode INT,
    City VARCHAR(100),
    Address TEXT,
    Locality VARCHAR(255),
    LocalityVerbose VARCHAR(255),
    Longitude DECIMAL(10, 6),
    Latitude DECIMAL(10, 6),
    Cuisines VARCHAR(500),
    Currency VARCHAR(100),
    Has_Table_booking VARCHAR(10),
    Has_Online_delivery VARCHAR(10),
    Is_delivering_now VARCHAR(10),
    Switch_to_order_menu VARCHAR(10),
    Price_range INT,
    Votes INT,
    Average_Cost_for_two INT,
    Rating DECIMAL(3, 2),
    Datekey_Opening VARCHAR(20)
);

select* from `Restaurants`;

LOAD DATA LOCAL INFILE 'C:/Users/balas/Downloads/Sheet1.csv'
INTO TABLE Restaurants
CHARACTER SET latin1
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

select * from `restaurants`;

select distinct `countryCode`
from `restaurants`
order by `CountryCode`;

CREATE TABLE Countries (
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(100)
);

INSERT INTO Countries (CountryID, CountryName)
VALUES
(1, 'India'),
(14, 'Australia'),
(30, 'Brazil'),
(37, 'Canada'),
(94, 'Indonesia'),
(148, 'New Zealand'),
(162, 'Philippines'),
(166, 'Qatar'),
(184, 'Singapore'),
(189, 'South Africa'),
(191, 'Sri Lanka'),
(208, 'Turkey'),
(214, 'United Arab Emirates'),
(215, 'United Kingdom'),
(216, 'United States');

select * from countries;

SELECT
    r.RestaurantID,
    r.RestaurantName,
    r.CountryCode,
    c.CountryName,
    r.City
FROM Restaurants r
JOIN Countries c
    ON r.CountryCode = c.CountryID;
    
    ALTER TABLE Restaurants
ADD CONSTRAINT fk_restaurants_countries
FOREIGN KEY (CountryCode)
REFERENCES Countries(CountryID);

alter table `restaurants` add column currency_symbol varchar(10) after currency;

update `restaurants`
set currency_symbol =
case
 WHEN Currency LIKE '%Botswana%' THEN 'P'
        WHEN Currency LIKE '%Brazilian%' THEN 'R$'
        WHEN Currency LIKE '%Dollar%' THEN '$'
        WHEN Currency LIKE '%Emirati%' THEN 'AED'
        WHEN Currency LIKE '%Indian%' THEN 'INR'
        WHEN Currency LIKE '%Indonesian%' THEN 'IDR'
        WHEN Currency LIKE '%New Zealand%' THEN 'NZ$'
        WHEN Currency LIKE '%Pound%' THEN '£'
        WHEN Currency LIKE '%Qatar%' THEN 'QR'
        WHEN Currency LIKE '%Rand%' THEN 'R'
        WHEN Currency LIKE '%Sri Lankan%' THEN 'LKR'
        WHEN Currency LIKE '%Turkish%' THEN 'TL'
        ELSE ''
    END;
    
     alter table`restaurants` add column Average_Price_Bucket varchar(10) after Average_cost_for_two;
    
    update `restaurants`
    set Average_Price_Bucket = 
    case
    when Average_cost_for_two is null then "Blank"
    when Average_cost_for_two <=250 then "0-250"
    when Average_cost_for_two <=500 then "251-500"
    when Average_cost_for_two <=750 then "501-750"
    when Average_cost_for_two <=1000 then "751-1000"
    when Average_cost_for_two <=1500 then "1001-1500"
    else "1501+"
    end;
    
     alter table `restaurants` add column Rating_Stars varchar(10) after Rating;
    
    alter table `restaurants` modify  Rating_Stars varchar(20) character set utf8mb4;
    
    UPDATE `restaurants`
SET `Rating_Stars` =
    CASE
        WHEN `Rating` IS NULL
             OR `Rating` < 0
             OR `Rating` > 5
        THEN ''
        ELSE CONCAT(
            REPEAT('★', ROUND(`Rating`, 0)),
            REPEAT('☆', 5 - ROUND(`Rating`, 0))
        )
    END;
    
    alter table `restaurants` 
add column `year` smallint,
add column `month` tinyint,
add column `year_month` varchar(7),
add column `weekday` varchar(10),
add column `Weekday_number` tinyint,
add column `Financial_Month` tinyint,
add column `Financial_Quarter` varchar(2);

UPDATE `restaurants`
SET
    `year` = YEAR(`Datekey_opening`),

    `month` = MONTH(`Datekey_opening`),

    `year_month` = DATE_FORMAT(`Datekey_opening`, '%Y-%m'),

    `weekday` = DAYNAME(`Datekey_opening`),

    `weekday_number` = WEEKDAY(`Datekey_opening`) + 1,

    `financial_month` =
        CASE
            WHEN MONTH(`Datekey_opening`) >= 4
                THEN MONTH(`Datekey_opening`) - 3
            ELSE MONTH(`Datekey_opening`) + 9
        END,

    `financial_Quarter` =
        CONCAT('Q', QUARTER(
            DATE_SUB(`Datekey_opening`, INTERVAL 3 MONTH)
        ));
        
  -- (1) Country_wise Restaurants

SELECT
    c.CountryID,
    r.CountryCode,
    c.CountryName,
    COUNT(r.RestaurantID) AS Total_Restaurants
FROM Countries c
LEFT JOIN Restaurants r
    ON c.CountryID = r.CountryCode
GROUP BY
    c.CountryID,
    r.CountryCode,
    c.CountryName
ORDER BY
    c.CountryID;
    
-- (2) Total Restaurants
    select count(*) from restaurants;
    
  -- (3) Total_Countries
select count(distinct countrycode)  as Total_Countries from restaurants;
  
-- (4) Total_Cities
select count(distinct City) as Total_Cities from restaurants;

-- (5) Total_Cuisines
select count(distinct cuisines) as Total_Cuosines from restaurants;

-- (6) Total_Votes
select count(distinct votes) as Total_Votes from restaurants;

-- (7) Average_rating
select round(avg(Rating),2)Avg_Rating from restaurants;

-- (8) year_wise restaurants along with Percentage
SELECT
    SUBSTRING_INDEX(Datekey_Opening, '_', 1) AS Opening_Year,
    COUNT(RestaurantID) AS Total_Restaurants,
    ROUND(
        COUNT(RestaurantID) * 100.0 /
        (SELECT COUNT(*) FROM Restaurants
         WHERE Datekey_Opening IS NOT NULL),
        2
    ) AS Percentage
FROM Restaurants
WHERE Datekey_Opening IS NOT NULL
GROUP BY SUBSTRING_INDEX(Datekey_Opening, '_', 1)
ORDER BY Opening_Year;

-- (9) Quarter_Wise Restuarants
SELECT
    CONCAT(
        'Q',
        QUARTER(
            STR_TO_DATE(
                REPLACE(Datekey_Opening, '_', '-'),
                '%Y-%m-%d'
            )
        )
    ) AS Opening_Quarter,
    COUNT(RestaurantID) AS Total_Restaurants
FROM Restaurants
WHERE STR_TO_DATE(
    REPLACE(Datekey_Opening, '_', '-'),
    '%Y-%m-%d'
) IS NOT NULL
GROUP BY Opening_Quarter
ORDER BY Opening_Quarter;

-- (10) Month_Wise Restaurants
SELECT
    MONTHNAME(
        STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'),
            '%Y-%m-%d'
        )
    ) AS Opening_Month,
    COUNT(RestaurantID) AS Total_Restaurants
FROM Restaurants
WHERE STR_TO_DATE(
    REPLACE(Datekey_Opening, '_', '-'),
    '%Y-%m-%d'
) IS NOT NULL
GROUP BY MONTH(
    STR_TO_DATE(
        REPLACE(Datekey_Opening, '_', '-'),
        '%Y-%m-%d'
    )
), Opening_Month
ORDER BY MONTH(
    STR_TO_DATE(
        REPLACE(Datekey_Opening, '_', '-'),
        '%Y-%m-%d'
    )
);

-- (11) Day_Wise restaurants
SELECT
    DAYNAME(
        STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'),
            '%Y-%m-%d'
        )
    ) AS Opening_Weekday,
    COUNT(RestaurantID) AS Total_Restaurants
FROM Restaurants
WHERE STR_TO_DATE(
    REPLACE(Datekey_Opening, '_', '-'),
    '%Y-%m-%d'
) IS NOT NULL
GROUP BY DAYOFWEEK(
    STR_TO_DATE(
        REPLACE(Datekey_Opening, '_', '-'),
        '%Y-%m-%d'
    )
), Opening_Weekday
ORDER BY DAYOFWEEK(
    STR_TO_DATE(
        REPLACE(Datekey_Opening, '_', '-'),
        '%Y-%m-%d'
    )
);

-- (12) Finacial_Quarter by Restaurants
SELECT
    Financial_Quarter,
    COUNT(*) AS Total_Restaurants
FROM (
    SELECT
        CASE
            WHEN MONTH(
                STR_TO_DATE(
                    REPLACE(Datekey_Opening, '_', '-'),
                    '%Y-%m-%d'
                )
            ) BETWEEN 4 AND 6 THEN 'Q1'

            WHEN MONTH(
                STR_TO_DATE(
                    REPLACE(Datekey_Opening, '_', '-'),
                    '%Y-%m-%d'
                )
            ) BETWEEN 7 AND 9 THEN 'Q2'

            WHEN MONTH(
                STR_TO_DATE(
                    REPLACE(Datekey_Opening, '_', '-'),
                    '%Y-%m-%d'
                )
            ) BETWEEN 10 AND 12 THEN 'Q3'

            ELSE 'Q4'
        END AS Financial_Quarter
    FROM Restaurants
    WHERE STR_TO_DATE(
        REPLACE(Datekey_Opening, '_', '-'),
        '%Y-%m-%d'
    ) IS NOT NULL
) AS RestaurantData
GROUP BY Financial_Quarter
ORDER BY Financial_Quarter;

-- (13) Finacial_Month by Restaurants
SELECT
    CASE
        WHEN MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) >= 4
        THEN MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) - 3
        ELSE MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) + 9
    END AS Financial_Month,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
WHERE STR_TO_DATE(
    REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
) IS NOT NULL
GROUP BY
    CASE
        WHEN MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) >= 4
        THEN MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) - 3
        ELSE MONTH(STR_TO_DATE(
            REPLACE(Datekey_Opening, '_', '-'), '%Y-%m-%d'
        )) + 9
    END
ORDER BY Financial_Month;

-- (14) Average_Price_Bucket by Restaurants

select Average_Price_Bucket,count(*) as Total_restaurants
from restaurants
group by Average_Price_Bucket
order by Total_Restaurants;

-- (15) Restaurants by Cities
select city,count(*) as Total_Restaurants
from restaurants
group by city
order by Total_Restaurants desc
limit 10;

-- (16) Table_booking by Restaurants
select Has_Table_booking,count(*) as Total_Restaurants,
round(count(*)* 100.0/sum(count(*)) over(),2) as Percentage
from restaurants
group by Has_Table_booking
order by Total_Restaurants desc;

-- (17) Has_Online_Delivery by Restaurants
select Has_Online_delivery,count(*) as Total_Restaurants,
round(count(*) * 100.0/sum(count(*)) over(),2) as  Percentage
from restaurants
group by Has_Online_delivery
order by Total_Restaurants desc;

-- (18) cuisines by restaurants
select cuisines,count(*) as Total_Restaurants
from restaurants
group by cuisines
order by Total_Restaurants desc
limit 10;

-- (19) Rating by Restaurants along with rating stars
SELECT
    CONCAT(
        REPEAT('★', FLOOR(Rating)),
        REPEAT('☆', 5 - FLOOR(Rating))
    ) AS Rating_Stars,
    Rating,
    COUNT(*) AS Total_Restaurants,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS Percentage
FROM Restaurants
WHERE Rating IS NOT NULL
GROUP BY Rating
ORDER BY Rating DESC;

select* from restaurants;

-- (20) Average by Currency along with symbol
SELECT
    Currency AS Currency_Symbol,
    ROUND(AVG(Average_Cost_for_two), 2) AS Average_Cost,
    COUNT(*) AS Total_Restaurants
FROM Restaurants
WHERE Currency IS NOT NULL
  AND Average_Cost_for_two IS NOT NULL
GROUP BY Currency
ORDER BY Average_Cost DESC;