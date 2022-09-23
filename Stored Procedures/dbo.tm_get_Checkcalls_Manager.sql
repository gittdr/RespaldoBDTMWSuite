SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_Checkcalls_Manager]	
					@TruckNumber varchar(13),
					@DriverID varchar(13),
					@TrailerID varchar(13),
					@CheckCallNumber int,
					@MaxPositions int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20)

AS

SET NOCOUNT ON 

DECLARE @Temp datetime

--CREATE TABLE #T2 ( DTSent datetime NULL, SN int ) 
CREATE TABLE #T2 (ckc_number int ) 

INSERT #T2 EXECUTE dbo.tm_get_Checkcalls_Manager_help @TruckNumber,
													@DriverID,
													@TrailerID,
													@CheckCallNumber,
													@MaxPositions, 
													@FromDate, 
													@ToDate, 
													@OrderByDate,
													@OrderByDateOrder

-- Go collect and return the data.
SELECT Checkcall.ckc_number,  
            Checkcall.ckc_status,
            Checkcall.ckc_asgntype,
            Checkcall.ckc_asgnid,
            Checkcall.ckc_date,
            Checkcall.ckc_event,
            Checkcall.ckc_city, 
            Checkcall.ckc_comment,
            Checkcall.ckc_updatedby, 
            Checkcall.ckc_updatedon, 
            Checkcall.ckc_latseconds, 
            Checkcall.ckc_longseconds, 
            Checkcall.ckc_lghnumber, 
            Checkcall.ckc_tractor, 
            Checkcall.ckc_extsensoralarm, 
            Checkcall.ckc_vehicleignition, 
            Checkcall.ckc_milesfrom, 
            Checkcall.ckc_directionfrom, 
            Checkcall.ckc_validity, 
            Checkcall.ckc_mtavailable, 
            Checkcall.ckc_minutes, 
            Checkcall.ckc_mileage, 
            Checkcall.ckc_home, 
            Checkcall.ckc_cityname, 
            Checkcall.ckc_state, 
            Checkcall.ckc_zip, 
            Checkcall.ckc_commentlarge, 
            Checkcall.ckc_minutes_to_final, 
            Checkcall.ckc_miles_to_final, 
            Checkcall.ckc_Odometer, 
			Checkcall.TripStatus,
            Checkcall.ckc_speed, 
            Checkcall.ckc_odometer2, 
            Checkcall.ckc_speed2, 
            Checkcall.ckc_heading, 
            Checkcall.ckc_gps_type, 
            Checkcall.ckc_gps_miles, 
            Checkcall.ckc_fuel_meter, 
            Checkcall.ckc_idle_meter, 
            Checkcall.ckc_AssociatedMsgSN, 
            Checkcall.ckc_ExtraData01, 
            Checkcall.ckc_ExtraData02, 
            Checkcall.ckc_ExtraData03, 
            Checkcall.ckc_ExtraData04, 
            Checkcall.ckc_ExtraData05, 
            Checkcall.ckc_ExtraData06, 
            Checkcall.ckc_ExtraData07, 
            Checkcall.ckc_ExtraData08,
            Checkcall.ckc_ExtraData09, 
            Checkcall.ckc_ExtraData10, 
            Checkcall.ckc_ExtraData11, 
            Checkcall.ckc_ExtraData12,
            Checkcall.ckc_ExtraData13,
            Checkcall.ckc_ExtraData14,
            Checkcall.ckc_ExtraData15,
            Checkcall.ckc_ExtraData16,
            Checkcall.ckc_ExtraData17,
            Checkcall.ckc_ExtraData18,
            Checkcall.ckc_ExtraData19,
            Checkcall.ckc_ExtraData20,
            Checkcall.ckc_TimeZone
FROM #T2  
WITH (NOLOCK)
INNER JOIN Checkcall ON #T2.ckc_number = Checkcall.ckc_number

GO
GRANT EXECUTE ON  [dbo].[tm_get_Checkcalls_Manager] TO [public]
GO
