SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PnetData_InsertHosRule]
( 
	@Category VARCHAR(200),
	@RuleName VARCHAR(200),
	@RuleHours INT,
	@RuleDays INT,
	@DrivingSecondsAvailable INT,
	@OnDutySecondsAvailable INT,
	@CycleResetHours INT,
	@LastResetDate DATETIME,
	@USResetStartDate DATETIME = NULL,
	@CycleTimeSecondsRemaining INT,
	@RemainingOnSecsUntilBreakRequired INT = NULL,
	@CycleTimeId INT
)
AS

/**
 * 
 * NAME:
 * dbo.[tmail_PnetData_InsertHosRule]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  insert record into HosRule table and return id
 *
 * RETURNS:
 *  HosRuleId
 * 
 * REVISION HISTORY:
 * 05/27/2014.01 - PTS77176 - APC - create proc
 *
 **/

SET NOCOUNT ON

INSERT INTO HoSRule
	(	Category,
		RuleName,
		RuleHours,
		RuleDays,
		DrivingSecondsAvailable,
		OnDutySecondsAvailable,
		CycleResetHours,
		LastResetDate,
		USResetStartDate,
		CycleTimeSecondsRemaining,
		RemainingOnSecsUntilBreakRequired,
		CycleTimeId,
		ModifiedLast
	)
VALUES  
	(	@Category,
		@RuleName,
		@RuleHours,
		@RuleDays,
		@DrivingSecondsAvailable,
		@OnDutySecondsAvailable,
		@CycleResetHours,
		@LastResetDate,
		@USResetStartDate,
		@CycleTimeSecondsRemaining,
		@RemainingOnSecsUntilBreakRequired,
		@CycleTimeId,
		GETDATE()
	)

SELECT @@IDENTITY;

GO
GRANT EXECUTE ON  [dbo].[tmail_PnetData_InsertHosRule] TO [public]
GO
