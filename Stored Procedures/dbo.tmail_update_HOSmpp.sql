SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_update_HOSmpp]
	@Driver VARCHAR(8),
	@LastAvailHoursReCal DATETIME,
	@DriveinHours FLOAT,
	@WeeklyHours FLOAT,
	@DutyHours FLOAT,
	@LogDate DATETIME,
	@Status INT,
	@statusdate DATETIME
	
AS	

/**
 * 
 * NAME:
 * dbo.tmail_update_HOSmpp
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Updates Drive Time Feilds in the mmp table for HOS
 * 
 *
 * RETURNS:
 * 0 For correct Excution, anything else is an error
 * 
 * PARAMETERS:
 *	@Driver VARCHAR(8), mpp_id of driver 
 *	@LastAvailHoursReCal FLOAT, 
 *	@DriveinHours FLOAT, Driving hours
 *	@WeeklyHours FLOAT, Weeks hours
 *	@DutyHours FLOAT, On Duty hours
 *	@LogDate DATETIME date, if missing, uses curent date
 *  @Status HOS curent status
 *  @statusdate date vendor collected date
 * 
 *
 * Status:
 * 1 = off duty
 * 2 = sleeper
 * 3 = driving
 * 4 = on duty
 * 5 = in personal vehicle(not used)
 * -1 or null = unknown
 * 
 * Change Log: 
 * 
 * rwolfe -init 5/31/2013
 * rwolfe -added status 8/28/13
 *
 **/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


--check for valid input
IF ISNULL(@Driver,'') = ''
BEGIN
	RAISERROR ('Invalid Driver', 16, -1, @Driver );
	RETURN 1;
END
	
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.manpowerprofile WHERE mpp_id =@Driver)
BEGIN
	RAISERROR ('Invalid Driver', 16, -1, @Driver );
	RETURN
END
	
	
IF ISNULL(@LogDate,'')=''
	SET @LogDate = GETDATE();

--run update
Update manpowerprofile SET
	mpp_lastlog_estdate = @LastAvailHoursReCal,
	mpp_dailyhrsest = @DriveinHours,
	mpp_weeklyhrsest = @WeeklyHours,
	mpp_fourteenhrest = @DutyHours,
	mpp_estlog_datetime = @LogDate,
	mpp_hosstatus = @Status,
	mpp_hosstatusdate = @statusdate,
	mpp_hosactivityupdateon = GETDATE()
WHERE mpp_id = @Driver;


GO
GRANT EXECUTE ON  [dbo].[tmail_update_HOSmpp] TO [public]
GO
