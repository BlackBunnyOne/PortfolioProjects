--Seperate date and time and add Start_Time and End_Time columns for October
select CONVERT(nvarchar(20), Start_Date, 108) AS Start_Time,
CONVERT(nvarchar(20), End_Date, 108) AS End_Time
from Q4Oct2021

alter table Q4Oct2021
add Start_Time datetime, End_Time datetime;

update Q4Oct2021
set Start_Time = CONVERT(nvarchar(20), Start_Date, 108),
	End_Time = CONVERT(nvarchar(20), End_Date, 108);


select *
from Q4Oct2021


--Create Table

create table DivvyBikeRiders(
Ride_Type nvarchar(255),
Status nvarchar(255),
Start_Date datetime,
End_Date datetime,
Start_Time datetime,
End_Time datetime)

select *
from DivvyBikeRiders

--Add data to table 
insert into DivvyBikeRiders 

select Ride_Type, Status, Start_Date, End_Date, Start_Time, End_Time
from Q3July2022
union

select Ride_Type, Status, Start_Date, End_Date, Start_Time, End_Time
from Q2Apr2022
union

select Ride_Type, Status, Start_Date, End_Date, Start_Time, End_Time
from Q4Oct2021
union

select Ride_Type, Status, Start_Date, End_Date, Start_Time, End_Time
from Q1Dec2021
;



--Check each column for nulls

select * 
from DivvyBikeRiders
where Start_Date is null 
-- where Ride_type is null 
-- where status is null
-- where start_time is null
-- where end_time is null
-- where Start_Date is null
-- where End_Date  is null
order by Status


--Use Start_Time and End_Time to calculate Total Ride Minutes

select Start_Time, End_Time, DATEDIFF(MINUTE,Start_Time, End_Time) as TotalRideMins
From DivvyBikeRiders

--Add RideMins column to table

alter table DivvyBikeRiders
add TotalRideMins int;

-- Add data to new column

update DivvyBikeRiders
set TotalRideMins =  DATEDIFF(minute,Start_Time, End_Time)

select*
from DivvyBikeRiders

--Delete rides less than 1 minute from temp table but more than 300 ride minutes

delete
from DivvyBikeRiders
where TotalRideMins <= 1 or TotalRideMins > 300

--Seperate Date for future use and update table

 select datepart(YEAR, Start_date) as Year,
		datepart(MONTH, Start_date) as Month,
		datepart(DAY, Start_date) as Day
 from DivvyBikeRiders

 alter table DivvyBikeRiders
 add Year int, Month int, Day int;
 

 Update DivvyBikeRiders
 set Year = datepart(YEAR, Start_Date),
	Month = datepart(month, Start_date),
	Day = datepart(day, Start_date);

select*
from DivvyBikeRiders


-- Change Day for int to char and update table

select Day,
case
when Day = '1' then 'Sunday'
when Day = '2' then 'Monday'
when Day = '3' then 'Tuesday'
when Day = '4' then 'Wednesday'
when Day = '5' then 'Thursday'
when Day = '6' then 'Friday'
when Day = '7' then 'Saturday'
end as RideDay
from DivvyBikeRiders

alter table DivvyBikeRiders
add RideDay nvarchar(255);

update DivvyBikeRiders
set RideDay = (
case when Day = '1' then 'Sunday'
when Day = '2' then 'Monday'
when Day = '3' then 'Tuesday'
when Day = '4' then 'Wednesday'
when Day = '5' then 'Thursday'
when Day = '6' then 'Friday'
when Day = '7' then 'Saturday'
end)

select *
from DivvyBikeRiders

--Update Month from int to char

select MONTH,
case
when MONTH = '12' then 'Dec'
when MONTH = '4' then 'Apr'
when MONTH = '7' then 'Jul'
when MONTH = '10' then 'Oct'
end as RideMonth
From DivvyBikeRiders

 alter table DivvyBikeRiders
add RideMonth nvarchar(255);


Update DivvyBikeRiders
set RideMonth = (
case 
when MONTH = '12' then 'Dec'
when MONTH = '4' then 'Apr'
when MONTH = '7' then 'Jul'
when MONTH = '10' then 'Oct'
end)

select *
from DivvyBikeRiders

--Add column to reflect season
select MONTH,
case
when MONTH = '12' then 'Winter'
when MONTH = '4' then 'Spring'
when MONTH = '7' then 'Summer'
when MONTH = '10' then 'Autumn'
end as RideSeason
From DivvyBikeRiders

 alter table DivvyBikeRiders
add RideSeason nvarchar(255);


Update DivvyBikeRiders
set  RideSeason = (
case
when MONTH = '12' then 'Winter'
when MONTH = '4' then 'Spring'
when MONTH = '7' then 'Summer'
when MONTH = '10' then 'Autumn'
end)

-- Total number of rides by status

select Status, count(status) as RideTotals
from DivvyBikeRiders
where ride_type != 'docked_bike'
group by status


--Begin query for visuals

--Average ride mins per season
select RideSeason, round(avg(totalRideMins), 0) as Casual_Avg
from DivvyBikeRiders
where status =  'casual'
Group by RideSeason;

select RideSeason, round(avg(totalRideMins), 0) as Member_Avg
from DivvyBikeRiders
where status =  'member'
Group by RideSeason;

--Average Ride mins per month
select RideMonth, round(avg(totalRideMins), 0) as Casual_Avg
from DivvyBikeRiders
where status =  'casual'
Group by RideMonth;

-- Look at bike type rentals per month

select  status, RideMonth, Ride_Type, count(Ride_type) as TotalRentals
from DivvyBikeRiders
where Ride_Type != 'docked_bike'
group by Ride_Type, status, RideMonth
order by TotalRentals

-- Look at docked by usage
select  Status, RideMonth, Ride_Type, count(Ride_type) as TotalRentals
from DivvyBikeRiders
where Ride_Type = 'docked_bike'
group by Ride_Type, status, RideMonth
order by TotalRentals

-- Look at popular ride days per season

select max(Rideday) as PopularDay, count(status) as Total_Rentals, Status, RideSeason
from DivvyBikeRiders
where Ride_Type != 'docked_bike'
and RideDay is not null
group by RideDay, Status, RideSeason
order by Total_Rentals desc


--Total rentals more than 5 mins per month

select Status, RideMonth, year, Ride_Type, count(start_date) as TotalRentals
from DivvyBikeRiders
where TotalRideMins >= '5' and Ride_Type != 'docked_bike'
group by Status, RideMonth, year, Ride_Type
order by  TotalRentals desc

--Total rentals for docked bikes

select Status, RideMonth, year, Ride_Type, count(start_date) as TotalRentals
from DivvyBikeRiders
where TotalRideMins >= '5' and Ride_Type = 'docked_bike'
group by Status, RideMonth, year, Ride_Type
order by TotalRentals desc

select Status, RideMonth, year, Ride_Type, count(start_date) as TotalRentals
from DivvyBikeRiders
where Status = 'member' and Ride_Type = 'docked_bike'
group by Status, RideMonth, year, Ride_Type
order by RideMonth, Ride_Type, year desc

--Total number of rentals more than 5 mins per ride type

select  Ride_Type, count(Ride_type) as MemberRentals
from DivvyBikeRiders
where Status = 'member' and totalridemins >= '5'
group by Ride_Type

select Ride_Type, count(Ride_type) as CasualRentals
from DivvyBikeRiders
where Status = 'casual' and totalridemins >= '5'
group by Ride_Type


select *
from DivvyBikeRiders


--Total Rides by status and season

select  RideSeason, status, count(Status) as TotalRides
from DivvyBikePercents
--Where Status = 'casual' and Ride_Type != 'docked_bike'
group by RideSeason, status
order by RideSeason


