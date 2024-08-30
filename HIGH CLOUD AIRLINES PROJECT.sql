use airline;

show tables; 

select * from maindata limit 5; 

select count(*) as Total_Rows from maindata;

select count(*) as Total_Flights from maindata;

desc maindata; 
-- --------------------------------------------------------------------------
alter table maindata 
ADD COLUMN load_factor_percentage DECIMAL(5,2);

alter table maindata rename column load_factor_percentage to load_factor; 
UPDATE maindata 
SET 
    load_factor = CASE
        WHEN `Available_Seats` = 0 THEN 0
        ELSE ((`Transported_Passengers`) / (`Available_Seats`)) * 100
    END;
set sql_safe_updates = 0 ;
select * from maindata;

-- -------------------------------------------------------------------------

alter table maindata rename column `%Distance Group ID` to `Distance_Group_ID`; 
alter table maindata rename column `# Available Seats` to `Available_Seats`;
alter table maindata rename column `From - To City` to `From_To_City`;
alter table maindata rename column `Carrier Name` to `Carrier_Name`;
alter table maindata rename column `# Transported Passengers` to `Transported_Passengers`;
alter table maindata rename column `%Airline ID` to `Airline_id` ; 
alter table maindata rename column `# Departures Performed` to `Departures_Performed` ; 

drop view if exists View_date_f;

CREATE VIEW View_date_f AS
    SELECT 
        CONCAT(`Year`, '-', `Month`, '-', `Day`) AS Date_field,
        `Available_Seats`,
        `From_To_City`,
        `Carrier_Name`,
        `Transported_Passengers`,
        `Airline_id`,
        `Departures_Performed`,
        `Distance`,
-- -----------------------------------------------------------------------------
        /*CASE
    WHEN  `Available_Seats`= 0 THEN 0
    ELSE (sum(`Transported_Passengers`)/ sum(`Available_Seats`) )* 100
END as */
-- -----------------------------------------------------------------------------
Load_Factor 
    FROM
        maindata;

SELECT 
    *
FROM
    View_date_f; 

                      -- ------------KPI1--------


drop view if exists View_kpi1;

CREATE VIEW View_kpi1 AS
    SELECT 
        YEAR(Date_field) AS years,
        MONTH(Date_field) AS month_no,
        DAY(date_field) AS day_no,
        MONTHNAME(date_field) AS MonthFullName,
        QUARTER(date_field) AS Quarters,
        CONCAT(YEAR(Date_field),
                '-',
                MONTHNAME(Date_field)) AS yearMonth,
        WEEK(date_field) AS WeekdayNO,
        DAYNAME(date_field) AS weekdayname,
        CASE
            WHEN MONTH(Date_Field) >= 4 THEN MONTH(date_field) - 3
            ELSE MONTH(date_field) + 9
        END AS FinancialMonth,
        CASE
            WHEN MONTH(date_field) IN (1 , 2, 3) THEN 'FQ-4'
            WHEN MONTH(Date_field) IN (4 , 5, 6) THEN 'FQ-1'
            WHEN MONTH(Date_field) IN (7 , 8, 9) THEN 'FQ-2'
            WHEN MONTH(Date_field) IN (10 , 11, 12) THEN 'FQ-3'
        END AS FinancialQuarter,
        CASE
            WHEN WEEKDAY(DATE_FIELD) IN (5 , 6) THEN 'WEEKEND'
            WHEN WEEKDAY(DATE_FIELD) IN (0 , 1, 2, 3, 4) THEN 'WEEKEDAY'
        END AS WEEKEND_WEEKDAY,
        CASE
            WHEN `Distance` BETWEEN 0 AND 500 THEN '0-500 miles'
            WHEN `Distance` BETWEEN 501 AND 1000 THEN '501-1000 miles'
            WHEN `Distance` BETWEEN 1001 AND 1500 THEN '1001-1500 miles'
            WHEN `Distance` BETWEEN 1501 AND 2000 THEN '1501-2000 miles'
            WHEN `Distance` BETWEEN 2001 AND 2500 THEN '2001-2500 miles'
            WHEN `Distance` BETWEEN 2501 AND 3000 THEN '2501-3000 miles'
            WHEN `Distance` BETWEEN 3001 AND 3500 THEN '3001-3500 miles'
            WHEN `Distance` BETWEEN 3501 AND 4000 THEN '3501-4000 miles'
            WHEN `Distance` BETWEEN 4001 AND 4500 THEN '4001-4500 miles'
            WHEN `Distance` BETWEEN 4501 AND 5000 THEN '4501-5000 miles'
            WHEN `Distance` > 5001 THEN '> 5000 miles'
            ELSE 'Unknown'
        END AS `Distance_Interval`,
        `Available_Seats`,
        `From_To_City`,
        `Carrier_Name`,
        `Transported_Passengers`,
        `Airline_id`,
        `Departures_Performed`,
        load_factor
    FROM
        View_date_f; 
-- ------------------------------------------------
select * from View_KPI1;


                                   -- KPI-2 --

-- ---------------------------  YEAR-WISE ---------------------------
select 
 years as Years_Wise,
    SUM(`Transported_Passengers`) as Total_Transported_Passengers,
    SUM(`Available_Seats`) as Total_Available_Seats,
    round(avg(Load_Factor),2) as Avg_Load_Factor
FROM
    View_KPI1
GROUP BY 1;

-- ----------------------------- MONTH-WISE ----------------------------
select 
 Month_no as Month_wise,
    SUM(`Transported_Passengers`) as Total_Transported_Passengers,
    SUM(`Available_Seats`) as Total_Available_Seats,
    round(avg(Load_Factor),2) as Avg_Load_Factor
FROM
    View_KPI1
GROUP BY 1 order by 1 ;

-- ----------------------------- QUARTER WISE ---------------------------
select 
 quarters as Quarters_wise,
    SUM(`Transported_Passengers`) as Total_Transported_Passengers,
    SUM(`Available_Seats`) as Total_Available_Seats,
    round(avg(Load_Factor),2) as Avg_Load_Factor
FROM
    View_KPI1
GROUP BY 1;

                                               -- KPI-3 --
 
 SELECT 
    Carrier_Name, ROUND(AVG(LOAD_FACTOR), 2) AS Avg_Load_Factor
FROM
    View_Date_f
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


											--  KPI-4  --

SELECT  Carrier_Name,ROUND(SUM(Transported_Passengers/1000000),2) AS PASSENGER_PREFFENCE
FROM View_kpi1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

										      -- KPI-5 --

SELECT From_To_City ,COUNT(Departures_Performed) AS TOP_ROUTS
FROM VIEW_KPI1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


                                           -- KPI-6 --
                                           
                                           
 SELECT  WEEKEND_WEEKDAY, 
 CONCAT(ROUND(COUNT(LOAD_FACTOR)/1000,2),'%') AS LOAD_FACTOR_PERCENTAGE
 FROM VIEW_KPI1
 GROUP BY 1
 ORDER BY 2;

                                         -- KPI-7 --

SELECT Distance_Interval,COUNT(Departures_Performed)
FROM VIEW_KPI1
GROUP BY 1
ORDER BY 2 DESC;




