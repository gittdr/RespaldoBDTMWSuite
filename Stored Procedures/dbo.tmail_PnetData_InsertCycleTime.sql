SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_PnetData_InsertCycleTime]
( 
	@version VARCHAR(24),
	@type VARCHAR(200),
	@companyid INT,
	@EventDate DATETIME,
	@DriverId VARCHAR(200),
	@DriverName VARCHAR(200),
	@VehicleNumber VARCHAR(200),
	@ShippingInfo VARCHAR(1),
	@TrailerNumber VARCHAR(200),
	@CoDrivers VARCHAR(200),
	@DataEndDate DATETIME,
	@LastDutyStatus INT,
	@LastDutyStatusAddlInfo VARCHAR(200),
	@LastDutyStatusChangeDate DATETIME,
	@CurrentHoSRegulation VARCHAR(200),
	@DrivingSecondsToday INT,
	@OnDutySecondsToday INT,
	@sbSecondsToday INT,
	@OffDutySecondsToday INT,
	@DrivingSecsYesterday INT,
	@OnDutySecsYesterday INT,
	@sbSecsYesterday INT,
	@OffDutySecsYesterday INT
)
AS

/**
 * 
 * NAME:
 * dbo.[tmail_PnetData_InsertCycleTime]
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 *  insert record into cycletime table and return id
 *
 * RETURNS:
 *  CycleTimeId
 * 
 * REVISION HISTORY:
 * 05/27/2014.01 - PTS77176 - APC - create proc
 *
 **/

SET NOCOUNT ON

INSERT INTO dbo.CycleTime
    ( [version] ,
      [Type] ,
      CompanyId ,
      EventDate ,
      DriverId ,
      DriverName ,
      VehicleNumber ,
      ShippingInfo ,
      TrailerNumber ,
      CoDrivers ,
      DataEndDate ,
      LastDutyStatus ,
      LastDutyStatusAddlInfo ,
      LastDutyStatusChangeDate ,
      CurrentHoSRegulation ,
      DrivingSecondsToday ,
      OnDutySecondsToday ,
      sbSecondsToday ,
      OffDutySecondsToday ,
      DrivingSecsYesterday ,
      OnDutySecsYesterday ,
      sbSecsYesterday ,
      OffDutySecsYesterday,
      ModifiedLast
    )
VALUES  
(	@version,
	@type,
	@companyid,
	@EventDate,
	@DriverId,
	@DriverName,
	@VehicleNumber,
	@ShippingInfo,
	@TrailerNumber,
	@CoDrivers,
	@DataEndDate,
	@LastDutyStatus,
	@LastDutyStatusAddlInfo,
	@LastDutyStatusChangeDate,
	@CurrentHoSRegulation,
	@DrivingSecondsToday,
	@OnDutySecondsToday,
	@sbSecondsToday,
	@OffDutySecondsToday,
	@DrivingSecsYesterday,
	@OnDutySecsYesterday,
	@sbSecsYesterday,
	@OffDutySecsYesterday,
	GETDATE()
)

SELECT @@IDENTITY;

GO
GRANT EXECUTE ON  [dbo].[tmail_PnetData_InsertCycleTime] TO [public]
GO
