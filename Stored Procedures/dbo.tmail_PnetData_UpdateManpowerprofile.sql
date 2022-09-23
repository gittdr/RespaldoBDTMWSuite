SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PnetData_UpdateManpowerprofile]
( 
	@cycletimeid INT
	--@driverId VARCHAR(25)
	--,@mppFieldMappedToDriverId VARCHAR(25)	

)
AS

/**
 * 
 * NAME:
 * dbo.[tmail_PnetData_UpdateManpowerprofile]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  determine mpp_id that corresponds with dbo.cycletime.driverid value
 *  update dbo.cycletime.mpp_id with correct mpp_id
 *  update dbo.manpowerprofile.mpp_hours1_week with calculated value matching Peoplenet Fleet Manager's OnDutyPerReg value
 *
 * RETURNS:
 * 
 * 
 * REVISION HISTORY:
 * 06/03/2014.01 - PTS77176 - APC - create proc
 * 06/06/2014.01 - PTS77176 - APC - verify new mpp_commid field exists
 * 06/12/2014.01 - PTS77176 - APC - update mpp_hours1_week instead of mpp_weeklyhrsest
 * 06/23/2014.01 - PTS77176 - APC - edit calculation for OnDutyHoursPerReg 
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @driverid VARCHAR(200),
		@mpp_id VARCHAR(8),
		@OnDutyHoursPerReg FLOAT,
		@CycleTimeSecondsRemaining INT

SELECT @driverid = driverid FROM dbo.CycleTime WHERE cycletimeid = @cycletimeid;

IF @driverid = NULL BEGIN
	-- cycletimeid passed into this proc is invalid
	RETURN;
END

-- match pnet driverID with value in one of 3 Manpowerprofile fields (in this order: mpp_id, mpp_otherid, mpp_mcommID)
SELECT TOP 1 @mpp_id = mpp_id FROM dbo.manpowerprofile WHERE mpp_id = LEFT(@driverid,8)

IF @mpp_id = NULL BEGIN
	SELECT TOP 1 @mpp_id = mpp_id FROM dbo.manpowerprofile WHERE mpp_otherid = LEFT(@driverid, 25)
END

IF @mpp_id = NULL BEGIN
	IF EXISTS(SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'manpowerprofile' AND COLUMN_NAME = 'mpp_mcommID') 
	BEGIN
		SELECT TOP 1 @mpp_id = mpp_id FROM dbo.manpowerprofile WHERE mpp_mcommID = LEFT(@driverid, 30)
	END
END

IF @mpp_id = NULL BEGIN
	-- no matching record in manpowerprofile, or not mapping to correct field in mpp
	RETURN;
END

-- record mpp_id in dbo.CycleTime for easier retrieval of cycletime data in the future
UPDATE dbo.CycleTime SET mpp_id = @mpp_id WHERE CycleTimeId = @cycletimeid;

-- get CycleTimeSecondsRemaining based on Regulation then calculate OnDutyPerReg
IF EXISTS(SELECT TOP 1 cycletimeid FROM dbo.CycleTime WHERE CurrentHoSRegulation LIKE '%US Federal 70%') BEGIN

	SELECT @CycleTimeSecondsRemaining = CycleTimeSecondsRemaining 
	FROM dbo.HoSRule 
	WHERE Category LIKE '%US%' AND CycleTimeId = @cycletimeid;		
END
ELSE
BEGIN
	SELECT @CycleTimeSecondsRemaining = CycleTimeSecondsRemaining 
	FROM dbo.HoSRule 
	WHERE Category LIKE '%Canada%' AND CycleTimeId = @cycletimeid;
END

-- convert seconds to hours and subtract from 70 (70 hr rule)
SELECT @OnDutyHoursPerReg = ROUND(70 - (CAST(@CycleTimeSecondsRemaining AS FLOAT)/CAST(3600 AS FLOAT)), 2)

-- save to mpp_hours1_week
UPDATE dbo.manpowerprofile SET mpp_hours1_week = @OnDutyHoursPerReg WHERE mpp_id = @mpp_id;

GO
GRANT EXECUTE ON  [dbo].[tmail_PnetData_UpdateManpowerprofile] TO [public]
GO
