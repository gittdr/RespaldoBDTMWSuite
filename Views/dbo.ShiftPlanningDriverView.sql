SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[ShiftPlanningDriverView]
AS
SELECT tsdv.*, 
    scity.cty_nmstct AS HomeCity, 
    man.mpp_hiredate AS HireDate, 
    man.mpp_senioritydate AS SeniorityDate, 
    man.mpp_currentphone AS Phone1, 
    man.mpp_alternatephone AS Phone2,  
    man.mpp_avl_cmp_id AS AvlCmpID, 
    acity.cty_nmstct AS AvlCity, 
    man.mpp_pln_date AS PlnDate, 
    man.mpp_pln_cmp_id AS PlnCmp, 
    pcity.cty_nmstct AS PlnCty,  
    man.mpp_gps_desc AS GPSDesc, 
	man.mpp_gps_date AS GPSDate, 
	man.mpp_mile_day7 AS [7DayMile], 
	man.mpp_last_log_date AS LastLogDate, 
	man.mpp_hours1 AS Day1Hours, 
	man.mpp_hours2 AS Day2Hours, 
	man.mpp_hours3 AS Day3Hours, 
	man.mpp_dailyhrsest AS DailyHrs, 
	man.mpp_weeklyhrsest AS WeeklyHrs, 
    man.mpp_pta_date AS PTADate, 
    isnull(man.sth_id, 0) as ShiftTemplateId, 
    sth_startdate as ShiftTemplateStartDate,
	(select max(ss.ss_date) from shiftschedules as ss where ss.mpp_id = man.mpp_id) as MaxShiftDate,
    man.mpp_athome_terminal, 
    man.mpp_default_shiftstart, 
    man.mpp_default_shiftend,
	man.mpp_domicile as Domicile
FROM TMWScrollDriverView tsdv 
	join dbo.manpowerprofile man (nolock) on tsdv.mpp_id = man.mpp_id 
	LEFT JOIN dbo.city AS scity (nolock) ON man.mpp_city = scity.cty_code 
	LEFT JOIN dbo.city AS acity (nolock) ON man.mpp_avl_city = acity.cty_code 
	LEFT JOIN dbo.city AS pcity (nolock) ON man.mpp_pln_city = pcity.cty_code
WHERE (man.mpp_status <> 'OUT')

GO
GRANT SELECT ON  [dbo].[ShiftPlanningDriverView] TO [public]
GO
