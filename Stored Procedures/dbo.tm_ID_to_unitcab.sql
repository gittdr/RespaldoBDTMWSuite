SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_ID_to_unitcab]
(
	@ID VARCHAR(21),
	@UnitType INT,
	@MCType VARCHAR(20)
)
AS 

/**
 * 
 * NAME:
 * dbo.tm_XRS_update_defults
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets mppID from unitcab, which in XRS integration is the internal ID
 * 
 *
 * RETURNS:
 * Drivers ID
 * 
 * PARAMETERS:
 * @ID VARCHAR(20)  
 * @UnitType  truck =4 driver =5
 *
 *
 * Change Log: 
 * rwolfe init 7/11/2013
 * rwolfe 8/14/13 accounted for more than one unit on a resource
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

IF ISNULL(@UnitType,0) = 0
BEGIN
	RAISERROR('Requires unit type',16,1);
	RETURN;
END

DECLARE @SID VARCHAR(21), @temp INT, @mcSN INT;

IF @UnitType = 5 --driver
	SELECT @temp = SN FROM dbo.tblDrivers WHERE DispSysDriverID = @ID;
ELSE 
	SELECT @temp = SN FROM dbo.tblTrucks WHERE DispSysTruckID = @ID;
	

IF ISNULL(@MCType,'') = ''
BEGIN
	SELECT UnitID FROM dbo.tblCabUnits WHERE LinkedObjSN = @temp AND LinkedAddrType = @UnitType;
	RETURN;
END
ELSE
BEGIN
	SELECT @mcSN = SN FROM dbo.tblMobileCommType WHERE @MCType = MobileCommType;
	
	SELECT UnitID FROM dbo.tblCabUnits WHERE LinkedObjSN = @temp AND LinkedAddrType = @UnitType AND dbo.tblCabUnits.Type = @mcSN;
	RETURN;
END

GO
GRANT EXECUTE ON  [dbo].[tm_ID_to_unitcab] TO [public]
GO
