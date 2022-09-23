SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_CheckRecordsinCache]
	@Instance int

	
	
AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_CheckRecordsinCache]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @Instance int
 *       
 *
 * REVISION HISTORY:
 * 06/12/12      - PTS 63352 SJ - Created Stored Procedure for Transaction Agent
 **/

/* [tm_GET_CheckRecordsinCache]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT TOP 100 l1.SN, Unit, DateAndTime, Lat, Long, Remark, UpdatePS, Quality, Landmark, Miles, Direction, 
CityName, [State], Zip, NearestLargeCityName, NearestLargeCityState, NearestLargeCityZip, 
NearestLargeCityDirection, NearestLargeCityMiles, VehicleIgnition, UpdateDisp, GetDate() as NOW, 
UnitID, LinkedAddrType, LinkedObjSN, [Status], InstanceId, TripStatus 
FROM tblLatLongs l1(NoLock) 
INNER JOIN tblCabUnits(NoLock) 
ON tblCabUnits.SN = Unit 
WHERE (ISNULL(STATUS, -1) & 1) = 0  



GO
GRANT EXECUTE ON  [dbo].[tm_GET_CheckRecordsinCache] TO [public]
GO
