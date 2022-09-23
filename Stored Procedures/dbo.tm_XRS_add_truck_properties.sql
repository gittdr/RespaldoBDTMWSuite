SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRS_add_truck_properties]
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
 * Adds Propertys for new trucks
 * It is the callers responsibility to Make certain this is a XRS Truck
 *
 * RETURNS:
 * 
 * 
 * PARAMETERS:
 *	@ID varchar(20) --Truck ID to add propertys to
 * 
 * Change Log: 
 * rwolfe -init 6/6/2013
 * rwolfe 11/8/2013 ajustments for 72798
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

DECLARE
	@sn INT,
	@temp INT,
	@syncMode INT,
	@OwnerOpTyp INT,
	@TypTypKind INT,
	@OrgKind INT;
	
--SELECT @sn= SN FROM dbo.tblTrucks;

--truck sn's
DECLARE
	@sAUX INT,
	@sElectricEn INT,
	@sHUT INT,
	@sHasBirth INT,
	@sOwnerOp INT,
	@sIFTA INT,
	@sResGrp INT,
	@sTypTyp INT,
	@sOrg INT;
	
--defults
DECLARE
	@AUX VARCHAR(255),
	@ElectricEN VARCHAR(255),
	@HUT VARCHAR(255),
	@HasBirth VARCHAR(255),
	@OwnerOp VARCHAR(255),
	@IFTA VARCHAR(255),
	@ResGrp VARCHAR(255),
	@TypType VARCHAR(255),
	@Org VARCHAR(255);


SELECT @sn =SN FROM dbo.tblTrucks WHERE DispSysTruckID = @ID;

DECLARE @tsn TABLE (PropCode VARCHAR(10),SN INT, DefaultValue VARCHAR(255));

--dont mess with non xrs drivers
SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSNOT';
SELECT @temp = SN FROM dbo.tblResourcePropertiesMobileComm WHERE PropSN = @temp;
IF EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE ResourceSN =@sn AND PropMCSN = @temp AND ResourceType = 4)
	RETURN;

SELECT @syncMode = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTSYNC';
SELECT @SyncMode = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @syncMode;

SELECT @OwnerOpTyp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOWNOTP';
SELECT @OwnerOpTyp = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @OwnerOpTyp;

SELECT @TypTypKind = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOTypLb';
SELECT @TypTypKind = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @TypTypKind;

SELECT @OrgKind = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOrgTyp';
SELECT @OrgKind = Value FROM dbo.tblMCTypeProperties WHERE PropSN = @OrgKind;

INSERT INTO @tsn
SELECT dbo.tblPropertyList.PropCode,dbo.tblResourcePropertiesMobileComm.SN, tblPropertyList.DefaultValue
FROM dbo.tblPropertyList JOIN dbo.tblResourcePropertiesMobileComm ON dbo.tblPropertyList.SN = dbo.tblResourcePropertiesMobileComm.PropSN
WHERE dbo.tblPropertyList.PropCode LIKE '%XRS%';

SELECT @sAUX = SN,@AUX = DefaultValue FROM @tsn WHERE PropCode ='XRSVAUX';
SELECT @sElectricEn = SN, @ElectricEN = DefaultValue FROM @tsn WHERE PropCode ='XRSVElecEn';
SELECT @sHUT = SN,@HUT = DefaultValue FROM @tsn WHERE PropCode ='XRSVHUT';
SELECT @sHasBirth = SN,@HasBirth = DefaultValue FROM @tsn WHERE PropCode ='XRSVHBirth';
SELECT @sOwnerOp = SN,@OwnerOp = DefaultValue FROM @tsn WHERE PropCode ='XRSVOwnOp';
SELECT @sIFTA = SN,@IFTA = DefaultValue FROM @tsn WHERE PropCode ='XRSIFTA';
SELECT @sResGrp = SN,@ResGrp = DefaultValue FROM @tsn WHERE PropCode ='XRSResGrp';
SELECT @sOrg = SN, @Org = DefaultValue FROM @tsn WHERE PropCode = 'XRSORG';
SELECT @sTypTyp = SN, @TypType = DefaultValue FROM @tsn WHERE PropCode = 'XRSTType';


IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN =@sAUX AND ResourceSN = @sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sAUX , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @AUX  -- Value - varchar(255)
	        );
	        
IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sElectricEn AND ResourceSN =@sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sElectricEn , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @ElectricEN  -- Value - varchar(255)
	        );
	        
IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sHUT AND ResourceSN = @sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sHUT , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @HUT  -- Value - varchar(255)
	        );
	        
IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sHasBirth AND ResourceSN = @sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sHasBirth , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @HasBirth  -- Value - varchar(255)
	        );

IF @OwnerOpTyp = 0
	IF NOT EXISTS ( SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sOwnerOp AND ResourceSN = @sn AND ResourceType = 4)
		INSERT INTO dbo.tblResourceProperties
				( PropMCSN ,
				  ResourceSN ,
				  ResourceType ,
				  Value
				)
		VALUES  ( @sOwnerOp , -- PropMCSN - int
				  @sn , -- ResourceSN - int
				  4 , -- ResourceType - int
				  @OwnerOp  -- Value - varchar(255)
				);
	        
IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sIFTA AND ResourceSN = @sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sIFTA , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @IFTA  -- Value - varchar(255)
	        );

IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sResGrp AND ResourceSN = @sn AND ResourceType = 4)
	INSERT INTO dbo.tblResourceProperties
	        ( PropMCSN ,
	          ResourceSN ,
	          ResourceType ,
	          Value
	        )
	VALUES  ( @sResGrp , -- PropMCSN - int
	          @sn , -- ResourceSN - int
	          4 , -- ResourceType - int
	          @ResGrp  -- Value - varchar(255)
	        );

IF  @TypTypKind = 0
	IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sTypTyp  AND ResourceSN = @sn AND ResourceType = 4)
		INSERT INTO dbo.tblResourceProperties
				( PropMCSN ,
				  ResourceSN ,
				  ResourceType ,
				  Value
				)
		VALUES  ( @sTypTyp , -- PropMCSN - int
				  @sn , -- ResourceSN - int
				  4 , -- ResourceType - int
				  @TypType  -- Value - varchar(255)
				);

IF @OrgKind = 0
	IF NOT EXISTS (SELECT SN FROM dbo.tblResourceProperties WHERE PropMCSN = @sOrg AND ResourceSN = @sn AND ResourceType = 4)
		INSERT INTO dbo.tblResourceProperties
				( PropMCSN ,
				  ResourceSN ,
				  ResourceType ,
				  Value
				)
		VALUES  ( @sOrg , -- PropMCSN - int
				  @sn , -- ResourceSN - int
				  4 , -- ResourceType - int
				  @Org  -- Value - varchar(255)
				);

GO
GRANT EXECUTE ON  [dbo].[tm_XRS_add_truck_properties] TO [public]
GO
