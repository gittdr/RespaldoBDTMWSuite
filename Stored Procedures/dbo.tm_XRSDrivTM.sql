SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRSDrivTM]
(
	@ID VARCHAR(8)
)
AS 

/**
 * 
 * NAME:
 * dbo.tm_XRSDrivTM
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets driver Totalmail component
 * 
 *
 * RETURNS:
 * driver Totalmail component
 * 
 * PARAMETERS:
 *	@ID driver mpp_id
 *
 *
 * Change Log: 
 * rwolfe init 7/9/2013
 * rwolfe 11/8/2013 ajustments for 72798
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

DECLARE
	@dPortalSN INT,
	@persConveySN INT,
	@TimeClockSN INT,
	@BigDaySN INT,
	@useorgsetSN INT,
	@driLangSN INT,
	@IDSN INT,
	@Timesamp DATETIME,
	@ResGrpSN INT,
	@Retired INT,
	@MarkSN INT,
	@OrgSN INT,
	@PasswdSN INT;
	

DECLARE @tsn TABLE (PropCode VARCHAR(10),SN INT);

INSERT INTO @tsn
SELECT dbo.tblPropertyList.PropCode,dbo.tblResourcePropertiesMobileComm.SN 
FROM dbo.tblPropertyList JOIN dbo.tblResourcePropertiesMobileComm ON dbo.tblPropertyList.SN = dbo.tblResourcePropertiesMobileComm.PropSN
WHERE dbo.tblPropertyList.PropCode LIKE '%XRS%';


SELECT @dPortalSN = SN FROM @tsn WHERE PropCode = 'XRSDPortal';
SELECT @persConveySN = SN FROM @tsn WHERE PropCode = 'XRSDPerCon';
SELECT @TimeClockSN =SN FROM @tsn WHERE PropCode = 'XRSDTimeC';
SELECT @useorgsetSN = SN FROM @tsn WHERE PropCode = 'XRSDOrgSet';
SELECT @BigDaySN = SN FROM @tsn WHERE PropCode = 'XRSDBigDay';
SELECT @driLangSN= SN FROM @tsn WHERE PropCode = 'XRSDLang';
SELECT @ResGrpSN = SN FROM @tsn WHERE PropCode = 'XRSResGrp';
SELECT @MarkSN = SN FROM @tsn WHERE PropCode = 'XRSMARK';
SELECT @OrgSN = SN FROM @tsn WHERE PropCode = 'XRSORG';

DECLARE 
	@DriverP VARCHAR(255),
	@TimeClock VARCHAR(255),
	@BigDay VARCHAR(255),
	@UseOrg VARCHAR(255),
	@DriverLang VARCHAR(255),
	@ResGrp VARCHAR(255),
	@personCon VARCHAR(255),
	@Mark VARCHAR(255),
	@Org VARCHAR(255),
	@Passwd VARCHAR(255);

DECLARE @props TABLE (value VARCHAR(255),PropMCSN INT);

SELECT @IDSN = SN, @Timesamp= updated_on,@Retired = Retired, @Passwd = DriverPassword FROM dbo.tblDrivers WHERE DispSysDriverID = @ID;

INSERT INTO @props
SELECT value,PropMCSN FROM dbo.tblResourceProperties WHERE ResourceType = 5 AND ResourceSN = @IDSN;

SELECT @DriverP = value FROM @props WHERE PropMCSN = @dPortalSN;
SELECT @TimeClock = value FROM @props WHERE PropMCSN = @TimeClockSN;
SELECT @BigDay = value FROM @props WHERE PropMCSN = @BigDaySN;
SELECT @UseOrg = value FROM @props WHERE PropMCSN = @useorgsetSN;
SELECT @DriverLang = value FROM @props WHERE PropMCSN = @driLangSN;
SELECT @personCon = Value FROM @props WHERE PropMCSN = @persConveySN;
SELECT @ResGrp = value FROM @props WHERE PropMCSN =@ResGrpSN;
SELECT @Mark = value FROM @props WHERE PropMCSN = @MarkSN;
SELECT @Org = value FROM @props WHERE PropMCSN = @OrgSN;

SELECT 'Timesamp'=@Timesamp, 'DriverP'=@DriverP,'TimeC'=@TimeClock,'BigDay'=@BigDay,
'UseOrg'=@UseOrg,'DriverLang'=@DriverLang,'PersonalCon'=@personCon,'Retired'=@Retired,'ResourceGrp'=@ResGrp,
'Marked' = @Mark,'Organization' = @Org,'passwd'=@Passwd;


GRANT EXECUTE ON dbo.tm_XRSDrivTM TO PUBLIC
GO
