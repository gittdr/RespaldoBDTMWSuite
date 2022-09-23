SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_update_estLog_drverlog]
	@Driver VARCHAR(8),
	@AntiWeek FLOAT,
	@AntiDuty FLOAT,
	@AntiDriving FLOAT
	
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
 * Updates Remaining Time Feilds in the mmp table for HOS
 * 
 *
 * RETURNS:
 * 0 For correct Excution, anything else is an error
 * 
 * PARAMETERS:
 *	@Driver VARCHAR(8), mpp_id of driver 
 *	@AntiWeek FLOAT, Weekly hours remaining
 *	@AntiDuty FLOAT, Daily hours remaining
 *	@AntiDriving FLOAT, Daily driving remaining
 *
 * 
 * Change Log: 
 * 
 * rwolfe -init 8/28/13
 *
 **/

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


--check for valid input	
IF NOT EXISTS (SELECT TOP 1 * FROM dbo.log_driverlogs  WHERE mpp_id =@Driver)
BEGIN
	RAISERROR ('Invalid Driver', 16, -1, @Driver );
	RETURN 1;
END

DECLARE @temp INT;

--get the newest log
SELECT TOP 1 @temp = log_driverlog_ID FROM dbo.log_driverlogs WHERE mpp_id = @Driver ORDER BY log_date DESC;
	
UPDATE dbo.log_driverlogs SET 
	sixty_seventy_hr_rule = @AntiWeek,
	fourteen_hr_rule = @AntiDuty,
	eleven_hr_rule = @AntiDriving
WHERE log_driverlog_ID = @temp;


GO
GRANT EXECUTE ON  [dbo].[tmail_update_estLog_drverlog] TO [public]
GO
