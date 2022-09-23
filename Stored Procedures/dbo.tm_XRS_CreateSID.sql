SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_XRS_CreateSID](

	@XRSSID VARCHAR(21),
	@ObjID VARCHAR(20)

)
AS	
/**
 * 
 * NAME:
 * dbo.tm_XRS_CreateSID
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * creates a moble com unit to repersent the driver or vechile for xrs, which is also its sid on xrs's side
 *
 * RETURNS:
 * 
 * 
 * PARAMETERS:
 * @XRSSID full sid with D or T before the full number
 * @ObjID suite ID for object being created
 * 
 * 
 * Change Log: 
 * rwolfe init 7/8/2013
 * 
 *
 **/

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED -- DIRTY READS FOR ALL TABLES IN THIS TRANSACTION Or REM this line and use (NOLOCK)

DECLARE
	@Dunit INT,
	@tempUnit CHAR,
	@objSN INT,
	@cabSN INT,
	@temp VARCHAR(10);
	
SET @tempUnit = SUBSTRING(@XRSSID,1,1);

IF @tempUnit = 'T'
	BEGIN
		SELECT @objSN = SN FROM dbo.tblTrucks WHERE DispSysTruckID = @ObjID;
		
		IF ISNULL(@objSN,0) = 0
		BEGIN
			RAISERROR('Invalid Truck',16,1);
			RETURN;
		END
			
		
		EXEC dbo.tm_ConfigMCUnit2
			@sNewName = @XRSSID, -- varchar(60)
		    @sOldName = NULL, -- varchar(60)
		    @sUnitType = 'XRSXFC', -- varchar(20)
		    @sCurrentDispatchGroup = '', -- varchar(30)
		    @sCurrentTruck = @ObjID, -- varchar(15)
		    @iCurrentMCUnitDefaultLevel = 0, -- int
		    @iRetired = 0, -- int
		    @iUseToResolve = 1, -- int
		    @SFLAGS = 0; -- int
		    
		SELECT @cabSN = SN FROM dbo.tblCabUnits WHERE UnitID = @XRSSID;
		UPDATE dbo.tblCabUnits SET LinkedAddrType = 4,LinkedObjSN = @objSN, GroupFlag = 0, PositionOnly = 1 WHERE UnitID = @XRSSID;
		select @temp = DefaultCabUnit FROM dbo.tblTrucks WHERE DispSysTruckID = @ObjID
		IF ISNULL(@temp,'') = ''
			UPDATE dbo.tblTrucks SET DefaultCabUnit = @cabSN WHERE SN = @objSN;
		
	END
ELSE IF @tempUnit = 'D'
	BEGIN
		SELECT @objSN = SN FROM dbo.tblDrivers WHERE DispSysDriverID = @ObjID;
		
		IF ISNULL(@objSN,0) = 0
		BEGIN
			RAISERROR('Invalid Driver',16,1)
			RETURN;
		END
		
		EXEC dbo.tm_ConfigMCUnit2
			@sNewName = @XRSSID, -- varchar(60)
		    @sOldName = NULL, -- varchar(60)
		    @sUnitType = 'XRSXFC', -- varchar(20)
		    @sCurrentDispatchGroup = '', -- varchar(30)
		    @sCurrentTruck = '', -- varchar(15)
		    @iCurrentMCUnitDefaultLevel = 0, -- int
		    @iRetired = 0, -- int
		    @iUseToResolve = 1, -- int
		    @SFLAGS = 0 -- int
		
		SELECT @cabSN = SN FROM dbo.tblCabUnits WHERE UnitID = @XRSSID;
		
		UPDATE dbo.tblCabUnits SET LinkedAddrType = 5, LinkedObjSN =@objSN, GroupFlag = 0 WHERE UnitID = @XRSSID;
		select @temp = DefaultCabUnit FROM dbo.tblTrucks WHERE DispSysTruckID = @ObjID
		IF ISNULL(@temp,'') = ''
			UPDATE dbo.tblDrivers SET DefaultCabUnit = @cabSN WHERE SN = @objSN;
		
	END
ELSE 
	RAISERROR('Invalid SID',16,1)
GO
GRANT EXECUTE ON  [dbo].[tm_XRS_CreateSID] TO [public]
GO
