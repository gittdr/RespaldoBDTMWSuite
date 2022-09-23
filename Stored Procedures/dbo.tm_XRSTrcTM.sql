SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRSTrcTM]
(
	@ID VARCHAR(8)
)
AS 

/**
 * 
 * NAME:
 * dbo.tm_XRSTrcTM
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Gets Truck TotalMail component
 * 
 *
 * RETURNS:
 * Truck TotalMail component
 * 
 * 
 * PARAMETERS:
 *	@ID Truck trc_id
 *
 *
 * Change Log: 
 * rwolfe init 7/9/2013
 * rwolfe 10/24/2013 pts72798
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

--find propertys sn's
DECLARE 
	@compnameSN INT,
	@compsidSN INT,
	@ownOpSN INT,
	@xrsauxSN INT,
	@ElecEngSN INT,
	@HUTSN INT,
	@BirthSN INT,
	@IFTASN INT,
	@ResgrpSN INT,
	@MarkSN INT,
	@OrgSN INT,
	@TypeSN INT,
	@tgtSN INT,
	@StrightSN INT;
	
	
DECLARE @tsn TABLE (PropCode VARCHAR(10),SN INT);

INSERT INTO @tsn
SELECT dbo.tblPropertyList.PropCode,dbo.tblResourcePropertiesMobileComm.SN 
FROM dbo.tblPropertyList JOIN dbo.tblResourcePropertiesMobileComm ON dbo.tblPropertyList.SN = dbo.tblResourcePropertiesMobileComm.PropSN
WHERE dbo.tblPropertyList.PropCode LIKE '%XRS%';

SELECT @compnameSN=SN FROM @tsn WHERE PropCode = 'XRSCompN';
SELECT @compsidSN = SN FROM @tsn WHERE PropCode = 'XRSCompSID';
SELECT @xrsauxSN = SN FROM @tsn WHERE PropCode = 'XRSVAUX';
SELECT @ElecEngSN = SN FROM @tsn WHERE PropCode = 'XRSVElecEn';
SELECT @HUTSN = SN FROM  @tsn WHERE PropCode = 'XRSVHUT';
SELECT @BirthSN = SN FROM @tsn WHERE PropCode ='XRSVHBirth';
SELECT @IFTASN=SN FROM @tsn WHERE PropCode = 'XRSIFTA';
SELECT @ResgrpSN = SN FROM @tsn WHERE PropCode = 'XRSResGrp';
SELECT @ownOpSN = SN FROM @tsn WHERE PropCode = 'XRSVOwnOp';
SELECT @xrsauxSN = SN FROM @tsn WHERE PropCode = 'XRSVAUX';
SELECT @MarkSN = SN FROM @tsn WHERE PropCode = 'XRSMARK';
SELECT @OrgSN = SN FROM @tsn WHERE PropCode = 'XRSORG';
SELECT @TypeSN = SN FROM @tsn WHERE PropCode = 'XRSTType';
SELECT @tgtSN = SN FROM @tsn WHERE PropCode = 'XRSTTGT';
SELECT @StrightSN = SN FROM @tsn WHERE PropCode = 'XRSTStri';



--find parts vars
DECLARE 
	@IDSN INT;
	
--Returning Vars
DECLARE 
	@ModifyedDate DATETIME,
	@OwnerOperator VARCHAR(255),
	@ElectricEngin VARCHAR(255),
	@HasBirth VARCHAR(255),
	@HUT VARCHAR(255),
	@IFTA VARCHAR(255),
	@aux VARCHAR(255),
	@ResGrp VARCHAR(255),
	@Retire INT,
	@Mark VARCHAR(255),
	@Org VARCHAR(255),
	@Type VARCHAR(255),
	@tgt VARCHAR(255),
	@Stright VARCHAR(255);
	

SELECT @IDSN = SN, @ModifyedDate =updated_on, @Retire = Retired FROM dbo.tblTrucks WHERE DispSysTruckID = @ID;

DECLARE @props TABLE (value VARCHAR(255),PropMCSN INT);

INSERT INTO @props
SELECT value,PropMCSN FROM dbo.tblResourceProperties WHERE ResourceType = 4 AND ResourceSN = @IDSN;

SELECT @OwnerOperator = value FROM @props WHERE PropMCSN = @ownOpSN;
SELECT @ElectricEngin = value FROM @props WHERE PropMCSN = @ElecEngSN;
SELECT @HasBirth = value FROM @props WHERE PropMCSN = @BirthSN;
SELECT @HUT = value FROM @props WHERE PropMCSN = @HUTSN;
SELECT @IFTA = value FROM @props WHERE PropMCSN = @IFTASN;
SELECT @aux = value FROM @props WHERE PropMCSN = @xrsauxSN;
SELECT @ResGrp = value FROM @props WHERE PropMCSN = @ResgrpSN;
SELECT @Mark = value FROM @props WHERE PropMCSN = @MarkSN;
SELECT @Org = value FROM @props WHERE PropMCSN = @OrgSN;
SELECT @Type = value FROM @props WHERE PropMCSN = @TypeSN;
SELECT @tgt = value FROM @props WHERE PropMCSN = @tgtSN;
SELECT @Stright = value FROM @props WHERE PropMCSN = @StrightSN;



SELECT 'ModifyedDate'=@ModifyedDate,'OwnerOperator'=@OwnerOperator,'ElectricEngin'=@ElectricEngin,
'HasBirth'=@HasBirth,'HUT'=@HUT,'IFTA'=@IFTA,'AUX'=@aux,'Retired'=@Retire,'ResourceGrp'=@ResGrp,
'Mark' = @Mark, 'Organization' = @Org,'Type' = @Type,'TGT'=@tgt,'Stright'=@Stright;


GRANT EXECUTE ON dbo.tm_XRSTrcTM TO PUBLIC
GO
