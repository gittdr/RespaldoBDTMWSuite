SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  StoredProcedure [dbo].[tm_get_inbox2]    Script Date: 12/05/2009 17:58:44 ******/

CREATE PROCEDURE [dbo].[tm_get_Positions_Manager]	
					@TruckSN int,
					@DriverSN int,
					@CabUnitSN int,
					@PositionSN int,
					@MaxPositions int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20),
					@Status varchar(12)
AS

/**
 * 
 * NAME:
 * dbo.[tm_get_Positions_Manager]
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	general functionality of this proc
 * 
 * RETURNS:
 *  none
 *
 * RESULT SETS: 
 *  none
 *
 * PARAMETERS:
 * 001 - @p_varname varchar(12)     
 *
 * REVISION HISTORY:
 * 12/05/2009  proc created
 * 02/13/2013	 - PTS55851 - APC - put description here
 **/

/* [tm_get_Positions_Manager]
 **************************************************************
******************************************/
SET NOCOUNT ON

DECLARE @Temp datetime

--CREATE TABLE #T2 ( DTSent datetime NULL, SN int ) 
CREATE TABLE #T2 (SN int ) 

INSERT #T2 EXECUTE dbo.tm_get_Positions_Manager_help @TruckSN,
													@DriverSN,
													@CabUnitSN,
													@PositionSN,
													@MaxPositions, 
													@FromDate, 
													@ToDate, 
													@OrderByDate,
													@OrderByDateOrder,
													@Status

-- Go collect and return the data.
SELECT tblLatLongs.SN,  
            tblLatLongs.Unit,
            tblLatLongs.DateAndTime,
            tblLatLongs.Lat,
            tblLatLongs.Long,
            tblLatLongs.Remark,
            tblLatLongs.UpdatePS,
            tblLatLongs.Quality, 
            tblLatLongs.Landmark,
            tblLatLongs.Miles, 
            tblLatLongs.Direction, 
            tblLatLongs.CityName, 
            tblLatLongs.[State], 
            tblLatLongs.Zip, 
            tblLatLongs.NearestLargeCityName, 
            tblLatLongs.NearestLargeCityState, 
            tblLatLongs.NearestLargeCityZip, 
            tblLatLongs.NearestLargeCityDirection, 
            tblLatLongs.NearestLargeCityMiles, 
            tblLatLongs.VehicleIgnition, 
            tblLatLongs.UpdateDisp, 
            tblLatLongs.Odometer, 
            tblLatLongs.TripStatus, 
            tblLatLongs.odometer2, 
            tblLatLongs.speed, 
            tblLatLongs.speed2, 
            tblLatLongs.heading, 
            tblLatLongs.gps_type, 
            tblLatLongs.gps_miles, 
            tblLatLongs.fuel_meter, 
            tblLatLongs.idle_meter, 
            tblLatLongs.AssociatedMsgSN, 
            tblLatLongs.[STATUS], 
            tblLatLongs.StatusReason, 
            tblLatLongs.ExtraData01, 
            tblLatLongs.ExtraData02, 
            tblLatLongs.ExtraData03, 
            tblLatLongs.ExtraData04, 
            tblLatLongs.ExtraData05, 
            tblLatLongs.ExtraData06, 
            tblLatLongs.ExtraData07, 
            tblLatLongs.ExtraData08, 
            tblLatLongs.ExtraData09, 
            tblLatLongs.ExtraData10, 
            tblLatLongs.ExtraData11, 
            tblLatLongs.ExtraData12, 
            tblLatLongs.ExtraData13, 
            tblLatLongs.ExtraData14,
            tblLatLongs.ExtraData15, 
            tblLatLongs.ExtraData16, 
            tblLatLongs.ExtraData17, 
            tblLatLongs.ExtraData18,
            tblLatLongs.ExtraData19,
            tblLatLongs.ExtraData20
FROM #T2  
WITH (NOLOCK)
INNER JOIN tblLatlongs ON #T2.SN = tblLatlongs.SN 

GO
GRANT EXECUTE ON  [dbo].[tm_get_Positions_Manager] TO [public]
GO
