SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRS_update_defaults]
( 
	@CompanyName varchar(255) = '',
	@CompanySID varchar(255) = '',
	@DPortal Varchar(255) = '',
	@DpersonalConv Varchar(255) = '',
	@DTimeClock VARCHAR(255) = '',
	@DOrgSettings VARCHAR(255) = '',
	@DBigDay VARCHAR(255) = '',
	@DLang VARCHAR(255) = '',
	@VAUX VARCHAR(255) = '',
	@VElectricEng VARCHAR(255) = '',
	@VHUT VARCHAR(255) = '',
	@VHasBirth VARCHAR(255) = '',
	@VownerOp VARCHAR(255) = '',
	@VIFTA VARCHAR(255) = '',
	@OdomSend VARCHAR(255) = '',
	@DOrgType VARCHAR(255) = '',
	@DOrgString VARCHAR(255) = '',
	@DUserPass VARCHAR(255) = '',
	@VOrgType VARCHAR(255) = '',
	@VOrgString VARCHAR(255) = '',
	@TTypeType VARCHAR(255) = '',
	@TTGTMsic VARCHAR(255) = '',
	@ResGrp VARCHAR(255) = '',
	@DSRuleString VARCHAR(255) = '',
	@SendTMER VARCHAR(255) = '',
	@OwnerOperatorType VARCHAR(255) = '',
	@OwnerOperatorLB VARCHAR(255) = '',
	@DriverSyncMethod VARCHAR(255) = '',
	@TruckSyncMethod VARCHAR(255) = '',
	@OrganizationDefult VARCHAR(255) = '',
	@TruckTypeDefault VARCHAR(255) = '',
	@TTypeLB VARCHAR(255) = '',
	@StriTruck VARCHAR(255) = '',
	@StriTLoc VARCHAR(255) = '',
	@StriTLB VARCHAR(255) = '',
	@XRSTBirLoc VARCHAR(255) = '',
	@XRSTBirLB VARCHAR(255) = '',
	@XRSSIDWarn VARCHAR(255) = '',
	@PollerAlertTime VARCHAR(50) = ''
	
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
 * Sets the values for xrs defults, if nothing is sent for any pram, does not set value
 * Also sets Integration level settings
 * 
 *
 * RETURNS:
 * 
 * 
 * PARAMETERS:
 *  These are propertys of the integration or propertys on Drivers or Trucks
 *	@CompanyName varchar(255) integration value
 *	@CompanySID varchar(255) integration value
 *	@DPortal Varchar(255) driver default
 *	@DpersonalConv Varchar(255) driver default
 *	@DTimeClock VARCHAR(255) driver default
 *	@DOrgSettings VARCHAR(255) driver default
 *	@DBigDay VARCHAR(255) driver default
 *	@DLang VARCHAR(255) driver default
 *	@VAUX VARCHAR(255) truck default
 *	@VElectricEng VARCHAR(255) truck default
 *	@VHUT VARCHAR(255) truck default
 *	@VHasBirth VARCHAR(255) truck default
 *	@VownerOp VARCHAR(255) truck default
 *	@VIFTA VARCHAR(255) truck default
 *	@OdomSend VARCHAR(255) integration value
 *	@DOrgType VARCHAR(255) integration value
 *	@DOrgString VARCHAR(255) integration value
 *	@DUserPass VARCHAR(255) integration value
 *	@VOrgType VARCHAR(255) integration value
 *	@VOrgString VARCHAR(255) integration value
 *	@TTypeType VARCHAR(255) integration value
 * 	@TTGTMsic VARCHAR(255) integration value
 *	@ResGrp VARCHAR(255) Truck or Driver default
 *	@DSRuleString VARCHAR(255) integration value
 *	@SendTMER VARCHAR(255) integration value
 * 
 * 
 * Change Log: 
 * rwolfe init 6/6/2013
 * rwolfe 10/23/2013 added more settings to XRS for pts:72798
 * rwolfe 2/17/2014 added XRSSIDWarn to suppress warnings if wanted
 * rwolfe 4/21/2014 added XRSHOS timeout saving
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)


--guts of proc here
DECLARE @temp INT;



IF DATALENGTH(ISNULL(@PollerAlertTime,'')) > ''
BEGIN
	UPDATE dbo.tblRS
	SET text = @PollerAlertTime
	WHERE keyCode = 'TiouXRSHOS'
END

IF DATALENGTH(ISNULL(@DPortal,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDPortal';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DPortal)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@DpersonalConv,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDPerCon';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DpersonalConv)
	WHERE SN = @temp;
End

IF DATALENGTH(ISNULL(@DTimeClock,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDTimeC';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DTimeClock)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@DOrgSettings,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDOrgSet';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DOrgSettings)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@DBigDay,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDBigDay';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DBigDay)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@DLang,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDLang';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@DLang)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VAUX,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSVAUX';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@VAUX)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VElectricEng,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSVElecEn';
	UPDATE dbo.tblPropertyList
	SET DefaultValue= RTRIM(@VElectricEng)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VHUT,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSVHUT';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@VHUT)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VHasBirth,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSVHBirth';
	UPDATE dbo.tblPropertyList
	SET DefaultValue= RTRIM(@VHasBirth)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VownerOp,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSVOwnOp';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@VownerOp)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@VIFTA,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSIFTA';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@VIFTA)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@OrganizationDefult,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSORG';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@OrganizationDefult)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@TruckTypeDefault,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTType';
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@TruckTypeDefault)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@StriTruck,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTStri'
	UPDATE dbo.tblPropertyList
	SET DefaultValue = RTRIM(@StriTruck)
	WHERE SN = @temp;
END

--configuration settings
IF DATALENGTH(ISNULL(@OdomSend,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSPOSODOM';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@OdomSend)
	WHERE PropSN = @temp;
END


IF DATALENGTH(ISNULL(@DOrgType,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDOrgTyp';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@DOrgType)
	WHERE PropSN = @temp;
END


IF DATALENGTH(ISNULL(@DOrgString,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDOTypLb';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@DOrgString)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@DUserPass,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDCred';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@DUserPass)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@VOrgType,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOrgTyp';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@VOrgType)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@VOrgString,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOTypLb';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@VOrgString)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@TTypeType,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTTypTyp';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@TTypeType)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@TTGTMsic,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTTGTMis';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@TTGTMsic)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@ResGrp,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSResGrp';
	UPDATE dbo.tblPropertyList
	SET DefaultValue= RTRIM(@ResGrp)
	WHERE SN = @temp;
END

IF DATALENGTH(ISNULL(@DSRuleString,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSServLB';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@DSRuleString)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@SendTMER,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSErrorTM';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@SendTMER)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@OwnerOperatorType,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOWNOTP';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@OwnerOperatorType)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@OwnerOperatorLB,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTOWNOLB';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@OwnerOperatorLB)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@DriverSyncMethod,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSDSYNC';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@DriverSyncMethod)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@TruckSyncMethod,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTSYNC';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@TruckSyncMethod)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@TTypeLB,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTTypeLB';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@TTypeLB)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@StriTLoc,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTStrLoc';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@StriTLoc)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@StriTLB,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTStriLB';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@StriTLB)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@XRSTBirLoc,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTBirLoc';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@XRSTBirLoc)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@XRSTBirLB,'')) > ''
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSTBirLB';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@XRSTBirLB)
	WHERE PropSN = @temp;
END

IF DATALENGTH(ISNULL(@XRSSIDWarn,'')) > 0
BEGIN
	SELECT @temp = SN FROM dbo.tblPropertyList WHERE PropCode = 'XRSSIDWarn';
	UPDATE dbo.tblMCTypeProperties
	SET Value = RTRIM(@XRSSIDWarn)
	WHERE PropSN = @temp;
END

GO
GRANT EXECUTE ON  [dbo].[tm_XRS_update_defaults] TO [public]
GO
