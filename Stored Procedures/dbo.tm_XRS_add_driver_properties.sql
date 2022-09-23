SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRS_add_driver_properties]
( 
	@ID varchar(8) 
)
AS

/**
 * 
 * NAME:
 * dbo.tm_XRS_add_propertys
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Adds Propertys for new drivers
 *
 * RETURNS:
 * 
 * 
 * PARAMETERS:
 *	@ID varchar(20) --Driver ID to add propertys to
 * 
 * 
 * Change Log: 
 * rwolfe -init 6/6/2013
 * rwolfe 11/8/2013 ajustments for 72798
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)


DECLARE
	@TDsn INT,
	@temp INT,
	@orgLBTyp INT;

SELECT @TDsn=SN FROM dbo.tblDrivers WHERE DispSysDriverID = @ID;


--dont mess with non xrs drivers
SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSNOT';
SELECT @temp = SN FROM dbo.tblResourcePropertiesMobileComm WHERE PropSN = @temp;
IF EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE ResourceSN =@TDsn AND PropMCSN = @temp AND ResourceType = 5)
	RETURN;

SELECT @orgLBTyp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOTypLb';
SELECT @orgLBTyp = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @orgLBTyp;


	
--get defult values and sn's
DECLARE
	@Portal VARCHAR(255),
	@PersonalConv VARCHAR(255),
	@TimeClock VARCHAR(255),
	@UseOrgSettings VARCHAR(255),
	@BigDay VARCHAR(255),
	@Lang VARCHAR(255),
	@ResGrp VARCHAR(255),
	@Org VARCHAR(255);
	
DECLARE
	@sPortal INT,
	@sPersonalConv INT,
	@sTimeClock INT,
	@sUseOrgSettings INT,
	@sBigDay INT,
	@sLang INT,
	@sResGrp INT,
	@sMark INT,
	@sOrg INT,
	@syncMode INT;
	
DECLARE @tsn TABLE (PropCode VARCHAR(10),SN INT, DefaultValue VARCHAR(255));

INSERT INTO @tsn
SELECT dbo.tblPropertyList.PropCode,dbo.tblResourcePropertiesMobileComm.SN, tblPropertyList.DefaultValue
FROM dbo.tblPropertyList JOIN dbo.tblResourcePropertiesMobileComm ON dbo.tblPropertyList.SN = dbo.tblResourcePropertiesMobileComm.PropSN
WHERE dbo.tblPropertyList.PropCode LIKE '%XRS%';


SELECT @sPortal = SN, @Portal = DefaultValue FROM @tsn WHERE PropCode = 'XRSDPortal';
SELECT @sPersonalConv = SN, @PersonalConv = DefaultValue FROM @tsn WHERE PropCode = 'XRSDPerCon';
SELECT @sTimeClock =SN, @TimeClock = DefaultValue FROM @tsn WHERE PropCode = 'XRSDTimeC';
SELECT @sUseOrgSettings = SN, @UseOrgSettings = DefaultValue FROM @tsn WHERE PropCode = 'XRSDOrgSet';
SELECT @sBigDay = SN, @BigDay = DefaultValue FROM @tsn WHERE PropCode = 'XRSDBigDay';
SELECT @sLang= SN, @Lang = DefaultValue FROM @tsn WHERE PropCode = 'XRSDLang';
SELECT @sResGrp = SN, @ResGrp = DefaultValue FROM @tsn WHERE PropCode = 'XRSResGrp';
SELECT @sOrg = SN, @Org = DefaultValue FROM @tsn WHERE PropCode = 'XRSORG';
SELECT @syncMode = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTSYNC';
SELECT @SyncMode = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @syncMode;

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sPortal AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sPortal , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @Portal  -- Value - varchar(255)
	        );
	        
IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN =@sPersonalConv AND ResourceSN =@TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sPersonalConv , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @PersonalConv  -- Value - varchar(255)
	        );

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sTimeClock AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sTimeClock , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @TimeClock  -- Value - varchar(255)
	        );

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN =@sUseOrgSettings AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sUseOrgSettings , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @UseOrgSettings  -- Value - varchar(255)
	        );

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sBigDay AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sBigDay , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @BigDay  -- Value - varchar(255)
	        );
	        

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sLang AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sLang , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @Lang  -- Value - varchar(255)
	        )

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sResGrp AND ResourceSN = @TDsn AND ResourceType = 5)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sResGrp , -- PropMCSN - int
	          @TDsn , -- ResourceSN - int
	          5 , -- ResourceType - int
	          @ResGrp  -- Value - varchar(255)
	        )
IF @syncMode = 0
	IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN =@sOrg  AND ResourceSN = @TDsn AND ResourceType = 5)
		INSERT INTO dbo.tblResourceProperties
				( PropMCSN ,
				  ResourceSN ,
				  ResourceType ,
				  Value
				)
		VALUES  ( @sOrg , -- PropMCSN - int
				  @TDsn , -- ResourceSN - int
				  5 , -- ResourceType - int
				  @Org  -- Value - varchar(255)
				)

GO
GRANT EXECUTE ON  [dbo].[tm_XRS_add_driver_properties] TO [public]
GO
