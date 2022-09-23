SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_trip_sheet_by_domicile_report_available_hours_sp]
	@mpp_id varchar (8)
AS
/**
 * 
 * NAME:
 * d_trip_sheet_by_domicile_report_available_hours_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Returns the last 8 days of Driver Hours information.   
 *
 * RETURNS:
 *
 * RESULT SETS: 
 * Returns a column for the the date and hours over the last 8 days.  
 * In addtion, the total hours from the last reset point is returned as well.
 *
 * PARAMETERS:
 * @mpp_id, varchar (8), IN, Driver whose hours you want returned
 *
 * 
 * REVISION HISTORY:
 * 08/15/2005.01 ? PTS29063 - Greg Kanzinger ? Created Procedure
 *
 **/
BEGIN
declare @hrs_current float,
	@hrs_1 float,
	@hrs_2 float,
	@hrs_3 float,
	@hrs_4 float,
	@hrs_5 float,
	@hrs_6 float,
	@hrs_7 float,
	@date_current datetime,
	@date_1 datetime,
	@date_2 datetime,
	@date_3 datetime,
	@date_4 datetime,
	@date_5 datetime,
	@date_6 datetime,
	@date_7 datetime,
	@date_reset datetime,
	@hrs_used float
	
	

/*select @log_date_begin = convert (varchar (10), getdate (), 112)
select @log_date_end = convert (varchar (10), getdate (), 112)*/

select @date_current = getdate ()
select @date_1 = DateAdd (dd, -1, @date_current)
select @date_2 = DateAdd (dd, -2, @date_current)
select @date_3 = DateAdd (dd, -3, @date_current)
select @date_4 = DateAdd (dd, -4, @date_current)
select @date_5 = DateAdd (dd, -5, @date_current)
select @date_6 = DateAdd (dd, -6, @date_current)
select @date_7 = DateAdd (dd, -7, @date_current)

SELECT @date_reset = Max (log_date)
FROM log_driverlogs
WHERE mpp_id = @mpp_id
and rule_reset_indc = 'Y'
and log_date <= @date_current

IF @date_reset IS NULL 
	select @hrs_used = 0
ELSE
	SELECT @hrs_used = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
	FROM log_driverlogs
	WHERE mpp_id = @mpp_id
	AND convert (varchar (10), log_date, 112) <= convert (varchar (10), @date_current, 112)
	AND convert (varchar (10), log_date, 112) >= convert (varchar (10), @date_reset, 112)

SELECT @hrs_used = IsNull (@hrs_used, 0)

SELECT @hrs_current = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_current, 112)
AND mpp_id = @mpp_id

select @hrs_current = IsNull (@hrs_current, -1)

SELECT @hrs_1 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_1, 112)
AND mpp_id = @mpp_id

select @hrs_1 = IsNull (@hrs_1, -1)

SELECT @hrs_2 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_2, 112)
AND mpp_id = @mpp_id

select @hrs_2 = IsNull (@hrs_2, -1)

SELECT @hrs_3 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_3, 112)
AND mpp_id = @mpp_id

select @hrs_3 = IsNull (@hrs_3, -1)

SELECT @hrs_4 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_4, 112)
AND mpp_id = @mpp_id

select @hrs_4 = IsNull (@hrs_4, -1)

SELECT @hrs_5 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_5, 112)
AND mpp_id = @mpp_id

select @hrs_5 = IsNull (@hrs_5, -1)

SELECT @hrs_6 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_6, 112)
AND mpp_id = @mpp_id

select @hrs_6 = IsNull (@hrs_6, -1)

SELECT @hrs_7 = Sum (IsNull (driving_hrs , 0)  +  IsNull (on_duty_hrs , 0))
FROM log_driverlogs
WHERE convert (varchar (10), log_date, 112) = convert (varchar (10), @date_7, 112)
AND mpp_id = @mpp_id

select @hrs_7 = IsNull (@hrs_7, -1)

select 	@hrs_current as current_hrs,
	@hrs_1 as hrs_1,
	@hrs_2 as hrs_2,
	@hrs_3 as hrs_3,
	@hrs_4 as hrs_4,
	@hrs_5 as hrs_5,
	@hrs_6 as hrs_6,
	@hrs_7 as hrs_7,
	@date_current as date_current,
	@date_1 as date_1,
	@date_2 as date_2,
	@date_3 as date_3,
	@date_4 as date_4,
	@date_5 as date_5,
	@date_6 as date_6,
	@date_7 as date_7,
	@hrs_used as hrs_used,
	@date_reset as date_reset

END
GO
GRANT EXECUTE ON  [dbo].[d_trip_sheet_by_domicile_report_available_hours_sp] TO [public]
GO
