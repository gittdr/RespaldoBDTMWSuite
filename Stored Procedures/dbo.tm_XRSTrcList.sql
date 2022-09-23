SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRSTrcList]

AS 

/**
 * 
 * NAME:
 * dbo.tm_XRSTrcList
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets truck List
 * 
 *
 * RETURNS:
 * List of Trucks
 *
 *
 * Change Log: 
 * rwolfe init 7/9/2013
 * rwolfe 7/11/7/2013 changed to account for 72798
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

DECLARE @notXRS INT,
		@mark INT,
		@syncMode INT;
		
DECLARE @tsn TABLE (PropCode VARCHAR(10),SN INT);

INSERT INTO @tsn
SELECT dbo.tblPropertyList.PropCode,dbo.tblResourcePropertiesMobileComm.SN 
FROM dbo.tblPropertyList JOIN dbo.tblResourcePropertiesMobileComm ON dbo.tblPropertyList.SN = dbo.tblResourcePropertiesMobileComm.PropSN
WHERE dbo.tblPropertyList.PropCode LIKE '%XRS%';

SELECT @notXRS = SN FROM @tsn WHERE PropCode = 'XRSNOT';
SELECT @mark = SN FROM @tsn WHERE PropCode = 'XRSMARK';
SELECT @syncMode = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTSYNC';
SELECT @SyncMode = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @syncMode;

IF @syncMode = 1
BEGIN
	SELECT DISTINCT dbo.tblTrucks.DispSysTruckID FROM 
	dbo.tblResourceProperties JOIN dbo.tblTrucks
	ON dbo.tblResourceProperties.ResourceSN = dbo.tblTrucks.SN
	WHERE dbo.tblResourceProperties.ResourceType = 4 AND ISNULL(DispSysTruckID,'') > '' AND PropMCSN = @mark
	EXCEPT
	SELECT DISTINCT dbo.tblTrucks.DispSysTruckID FROM 
	dbo.tblResourceProperties JOIN dbo.tblTrucks
	ON dbo.tblResourceProperties.ResourceSN = dbo.tblTrucks.SN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 4
	ORDER BY DispSysTruckID ASC;
END
ELSE IF @syncMode =2
BEGIN
	SELECT DISTINCT DispSysTruckID FROM dbo.tblTrucks WHERE ISNULL(DispSysTruckID, '') != '' 
	EXCEPT
	SELECT DISTINCT dbo.tblTrucks.DispSysTruckID FROM 
	dbo.tblResourceProperties JOIN dbo.tblTrucks
	ON dbo.tblResourceProperties.ResourceSN = dbo.tblTrucks.SN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 4 OR PropMCSN = @mark
	ORDER BY DispSysTruckID ASC;
END
ELSE IF @syncMode = 3 OR @syncMode = 4 --handled in code, ignore marks
BEGIN
	SELECT DISTINCT DispSysTruckID FROM dbo.tblTrucks WHERE ISNULL(DispSysTruckID, '') != '' 
	EXCEPT
	SELECT DISTINCT dbo.tblTrucks.DispSysTruckID FROM 
	dbo.tblResourceProperties JOIN dbo.tblTrucks
	ON dbo.tblResourceProperties.ResourceSN = dbo.tblTrucks.SN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 4
	ORDER BY DispSysTruckID ASC;
END

GRANT EXECUTE ON dbo.tm_XRSTrcList TO PUBLIC
GO
