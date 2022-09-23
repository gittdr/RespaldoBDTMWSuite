SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_unitcab_to_ID]
(
	@Unit VARCHAR(21)
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
 * Gets unitcab Unit ID, which in XRS integration is the sid
 * 
 *
 * RETURNS:
 * Drivers ID
 * 
 * PARAMETERS:
 *	@Unit VARCHAR(20)  unit cab value for enity, SID in XRS prefixed with d or v
 *
 *
 * Change Log: 
 * rwolfe init 6/29/2013
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)


DECLARE @sn INT,@linked INT;

SELECT @sn =LinkedObjSN , @linked = LinkedAddrType FROM dbo.tblCabUnits WHERE UnitID = @Unit;

IF ISNULL(@sn,0)=0
BEGIN
	RAISERROR ('Unit with this sid does not exist', 16, 1);
	RETURN;
END
	
IF (@linked = 5)
	SELECT DispSysDriverID FROM dbo.tblDrivers WHERE SN = @sn;
ELSE IF(@linked = 4)
	SELECT DispSysTruckID FROM dbo.tblTrucks WHERE SN = @sn;
ELSE
	SELECT NULL;


GO
GRANT EXECUTE ON  [dbo].[tm_unitcab_to_ID] TO [public]
GO
