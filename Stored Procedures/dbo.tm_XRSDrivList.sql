SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRSDrivList]

AS 

/**
 * 
 * NAME:
 * dbo.tm_XRSDrivList
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets driver List
 * 
 *
 * RETURNS:
 * List of drivers
 *
 *
 * Change Log: 
 * rwolfe init 7/102013
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
SELECT @syncMode = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDSYNC';
SELECT @SyncMode = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @syncMode;

IF @syncMode = 1
BEGIN
	SELECT DISTINCT DispSysDriverID FROM 
	dbo.tblDrivers JOIN dbo.tblResourceProperties ON dbo.tblDrivers.SN = dbo.tblResourceProperties.ResourceSN
	WHERE dbo.tblResourceProperties.ResourceType = 5 AND ISNULL(DispSysDriverID,'') > '' AND PropMCSN = @mark
	EXCEPT
	SELECT DISTINCT DispSysDriverID FROM 
	dbo.tblDrivers JOIN dbo.tblResourceProperties ON dbo.tblDrivers.SN = dbo.tblResourceProperties.ResourceSN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 4
	ORDER BY DispSysDriverID ASC;
END
ELSE IF @syncMode = 2
BEGIN
	SELECT DISTINCT DispSysDriverID FROM dbo.tblDrivers WHERE ISNULL(DispSysDriverID,'')>''
	EXCEPT
	SELECT DISTINCT DispSysDriverID FROM 
	dbo.tblDrivers JOIN dbo.tblResourceProperties ON dbo.tblDrivers.SN = dbo.tblResourceProperties.ResourceSN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 5 OR PropMCSN = @mark
	ORDER BY DispSysDriverID ASC;
END
ELSE IF @syncMode = 3 --handled in code, ignore marks
BEGIN
	SELECT DISTINCT DispSysDriverID FROM dbo.tblDrivers WHERE ISNULL(DispSysDriverID,'')>'' 
	EXCEPT
	SELECT DISTINCT dbo.tblDrivers.DispSysDriverID FROM 
	dbo.tblDrivers JOIN dbo.tblResourceProperties ON dbo.tblDrivers.SN = dbo.tblResourceProperties.ResourceSN
	WHERE PropMCSN = @notXRS AND dbo.tblResourceProperties.ResourceType = 5 
	ORDER BY DispSysDriverID ASC;
END

GRANT EXECUTE ON dbo.tm_XRSDrivList TO PUBLIC
GO
