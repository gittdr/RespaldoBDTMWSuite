SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_GetMCUnitSystem] 
( 
	@Truck_DriverID		Varchar(256),			-- Input Parameter For TruckID or Driver ID (DispsysTruckId or DispsysDriverId)
												-- PREFIXED with either MCTFORTRACTOR: or MCTFORDRIVER:
	@MobileCommType		Varchar(20),			-- Input Parameter corresponding to the MobileCommType from tblMobilCommType
												-- (e.g. InTouch, QualComm, etc.)
	@MCUnit				Varchar(256) OUTPUT		-- Output Parameter which return MCTUnit for Given Truck or Driver
)

AS

-- =============================================================================
-- Stored Proc: [dbo].[tm_GetMCUnitSystem]
-- Author     :	Rob Scott
-- Create date: 2013.02.22  - PTS 63996
-- Description:
--      Extension of tm_GetMCUnit:
--
--		Created from tm_GetMCUnit, only this takes MobileCommType (Vendor)
--   	into consideration.
--
--		Like tm_GetMCUnit, @Truck_DriverID input parameter MUST be prefixed
--		with either MCTFORTRACTOR: or MCTFORDRIVER: to determine a Truck or 
--		Driver lookup.
--
--		If a UnitID is NOT found for the @MobileCommType, tm_GetMCUnit is
--		executed
--
--
--Change Log:
--		
--		
--
-- =============================================================================
--
--      Input parameters:
--      ------------------------------------------------------------------------
--		001 - @Truck_DriverID	Varchar(256),  
--		002 - @MobileCommType	Varchar(20),
--
--      Output paramters:
--      ------------------------------------------------------------------------
--		001 - @MCUnit	Varchar(256)	Contains the MobileComm UnitID
--
-- =============================================================================


DECLARE
	@SN_tblTrkDrv	Int,
	@Dflt_MCUnit	Varchar(256)

SELECT @Truck_DriverID = LTRIM(RTRIM(@Truck_DriverID))
SELECT @MCUnit = ''
SELECT @Dflt_MCUnit = ''
SELECT @SN_TblTrkDrv = 0
SELECT @Dflt_MCUnit = ''

IF (UPPER(SUBSTRING(@Truck_DriverID,1,14))  = 'MCTFORTRACTOR:') AND (LEN(@Truck_DriverID) > 14)
	BEGIN
		--Get SN FROM TblTrucks Table for given DispsysTruckId               
		SELECT @SN_tblTrkDrv = ISNULL(SN,0) 
		FROM TblTrucks (NOLOCK)
		WHERE DispsysTruckId = SUBSTRING(@Truck_DriverID,15,LEN(@Truck_DriverID))

		--LinkedAddrType = '4'  is used for 'truck'
		SELECT	@MCUnit = ISNULL(UnitID, '')
		FROM	tblCabUnits (NOLOCK) INNER JOIN
				tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
		WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
				((Truck = @SN_TblTrkDrv AND LinkedAddrType = 4 AND LinkedObjSN = @SN_TblTrkDrv) OR  
				(Truck = @SN_TblTrkDrv AND LinkedAddrType IS NULL AND LinkedObjSN  IS NULL))
		ORDER BY tblCabUnits.SN
	
		--IF the Truck is having more than one MCTs then do following
		-- Search for default MCT Unit FROM TblTrucks table. IF default found then return it.
		-- IF no default MCT then get the first MCT from TblCabUnits table for that truck. 
		IF  @@RowCount > 1
			BEGIN
				SELECT @Dflt_MCUnit = DefaultCabUnit 
				FROM TblTrucks (NOLOCK)
				WHERE SN =  @SN_TblTrkDrv
				
				IF @Dflt_MCUnit IS NOT NULL
					BEGIN
						SELECT TOP 1 @MCUnit = ISNULL(UnitId,'') 
						FROM 	tblCabUnits (NOLOCK) INNER JOIN
								tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
						WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
								(tblCabUnits.SN = CAST(@Dflt_MCUnit AS Int))
					END
				ELSE IF @Dflt_MCUnit IS NULL
					BEGIN
						SELECT TOP 1 @MCUnit = ISNULL(UnitId,'') 
						FROM	tblCabUnits (NOLOCK) INNER JOIN
								tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
						WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
								((Truck = @SN_TblTrkDrv AND LinkedAddrType = 4 AND LinkedObjSN = @SN_TblTrkDrv) OR  
								(Truck = @SN_TblTrkDrv AND LinkedAddrType IS NULL AND LinkedObjSN  IS NULL))
						ORDER BY tblCabUnits.SN
					END
			END
		ELSE IF @@ROWCOUNT < 1 --not found, so execute original sp:
			EXEC tm_GetMCUnit @Truck_DriverID, @MCUnit OUTPUT 
	END

IF (UPPER(SUBSTRING(@Truck_DriverID,1,13))  = 'MCTFORDRIVER:') AND (LEN(@Truck_DriverID) > 13)
	BEGIN
		--Get SN FROM TblDrivers Table for given DispsysDriverId               
		SELECT @SN_TblTrkDrv = isnull(SN,0) 
		FROM TblDrivers (NOLOCK)
		WHERE DispsysDriverId = substring(@Truck_DriverID,14,len(@Truck_DriverID))
 
		--LinkedAddrType = '5'  is used for 'Driver'
		SELECT	@MCUnit = ISNULL(UnitID, '')
		FROM	tblCabUnits (NOLOCK) INNER JOIN
				tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
		WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
				(Truck = @SN_TblTrkDrv AND LinkedAddrType = 5 AND LinkedObjSN = @SN_TblTrkDrv)
		ORDER BY tblCabUnits.SN

		--IF the driver is having more than one MCTs then do following
		-- Search for default MCT Unit FROM TbllDriverss table. IF default found then return it.
		-- IF no default MCT then get the first MCT fro TblCabUnits table for that Drivers. 
		IF  @@RowCount > 1
			BEGIN
				SELECT @Dflt_MCUnit = DefaultCabUnit 
				FROM TblDrivers (NOLOCK)
				WHERE SN =  @SN_TblTrkDrv
				
				IF @Dflt_MCUnit IS NOT NULL
					BEGIN
						SELECT  TOP 1 @MCUnit = ISNULL(UnitId,'') 
						FROM 	tblCabUnits (NOLOCK) INNER JOIN
								tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
						WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
								(tblCabUnits.SN = CAST(@Dflt_MCUnit AS Int))
					END
				ELSE IF @Dflt_MCUnit is null
					BEGIN
						SELECT  TOP 1 @MCUnit = ISNULL(UnitId,'') 
						FROM	tblCabUnits (NOLOCK) INNER JOIN
								tblMobileCommType (NOLOCK) ON tblCabUnits.Type = tblMobileCommType.SN
						WHERE	(tblMobileCommType.MobileCommType = @MobileCommType) AND
								((Truck = @SN_TblTrkDrv AND LinkedAddrType = 5 AND LinkedObjSN = @SN_TblTrkDrv) OR  
								(Truck = @SN_TblTrkDrv AND LinkedAddrType IS NULL AND LinkedObjSN  IS NULL))
						ORDER BY tblCabUnits.SN
					END
			END
		ELSE IF @@ROWCOUNT < 1 --not found, so execute original sp:
			EXEC tm_GetMCUnit @Truck_DriverID, @MCUnit OUTPUT 
	END
GO
GRANT EXECUTE ON  [dbo].[tm_GetMCUnitSystem] TO [public]
GO
