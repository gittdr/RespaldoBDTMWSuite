SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_GetMCUnit] 

( 
@Truck_DriverID            Varchar(256),                 -- Input Parameter For TruckID or Drivaer ID (DispsysTruckId or DispsysDriverId)
@MCUnit                      Varchar(256) output        -- Output Parameter which return MCTUnit for Given Truck or Driver
)

AS

SET NOCOUNT ON

Declare

@SN_TblTrkDrv              int,
@Dflt_MCUnit                Varchar(256)


set @Truck_DriverID = ltrim(@Truck_DriverID)
set @Truck_DriverID = rtrim(@Truck_DriverID)
set @MCUnit = ''
set @Dflt_MCUnit = ''
set @SN_TblTrkDrv = 0
set @Dflt_MCUnit = ''


IF upper(substring(@Truck_DriverID,1,14))  = 'MCTFORTRACTOR:'    and len(@Truck_DriverID) > 14  BEGIN


            --Get SN FROM TblTrucks Table for given DispsysTruckId               
            SELECT @SN_TblTrkDrv = isnull(SN,0) 
            FROM TblTrucks (NOLOCK)
            WHERE DispsysTruckId = substring(@Truck_DriverID,15,len(@Truck_DriverID))


            --LinkedAddrType = '4'  is used for 'truck'
            SELECT  @MCUnit = isnull(UnitId,'') 
            FROM TblCabUnits (NOLOCK) 
            WHERE (Truck = @SN_TblTrkDrv and LinkedAddrType = 4 and LinkedObjSN = @SN_TblTrkDrv) OR  
            (Truck = @SN_TblTrkDrv and LinkedAddrType is null and LinkedObjSN  is null) 
            ORDER BY SN


            --IF the Truck is having more than one MCTs then do following
            -- Search for default MCT Unit FROM TblTrucks table. IF default found then return it.
            -- IF no default MCT then get the first MCT fro TblCabUnits table for that truck. 
             IF  @@RowCount > 1 BEGIN
                        SELECT @Dflt_MCUnit = DefaultCabUnit 
                        FROM TblTrucks (NOLOCK)
                        WHERE SN =  @SN_TblTrkDrv
                        IF @Dflt_MCUnit is not null BEGIN
                                    SELECT  top 1 @MCUnit = isnull(UnitId,'') 
                                    FROM TblCabUnits (NOLOCK) 
                                    WHERE SN = CAST(@Dflt_MCUnit as int)
                        END
                        else IF @Dflt_MCUnit is null BEGIN
                                    SELECT  Top 1 @MCUnit = isnull(UnitId,'') 
                                    FROM TblCabUnits (NOLOCK) 
                                    WHERE (Truck = @SN_TblTrkDrv and LinkedAddrType = 4 and LinkedObjSN = @SN_TblTrkDrv) OR  
                                    (Truck = @SN_TblTrkDrv and LinkedAddrType is null and LinkedObjSN  is null) 
                                    ORDER BY SN 
                        END
            END

END


IF upper(substring(@Truck_DriverID,1,13))  = 'MCTFORDRIVER:'     and len(@Truck_DriverID) > 13  BEGIN

            --Get SN FROM TblDrivers Table for given DispsysDriverId               
            SELECT @SN_TblTrkDrv = isnull(SN,0) 
            FROM TblDrivers (NOLOCK)
            WHERE DispsysDriverId = substring(@Truck_DriverID,14,len(@Truck_DriverID))
 
            --LinkedAddrType = '5'  is used for 'Driver'
            SELECT  @MCUnit = isnull(UnitId,'') 
            FROM TblCabUnits (NOLOCK)
            WHERE Truck = @SN_TblTrkDrv and LinkedAddrType = 5 and LinkedObjSN = @SN_TblTrkDrv  
            ORDER BY SN

            --IF the driver is having more than one MCTs then do following
            -- Search for default MCT Unit FROM TbllDriverss table. IF default found then return it.
            -- IF no default MCT then get the first MCT fro TblCabUnits table for that Drivers. 
             IF  @@RowCount > 1 BEGIN
                        SELECT @Dflt_MCUnit = DefaultCabUnit 
                        FROM TblDrivers (NOLOCK)
                        WHERE SN =  @SN_TblTrkDrv
                        IF @Dflt_MCUnit is not null BEGIN
                                    SELECT  top 1 @MCUnit = isnull(UnitId,'') 
                                    FROM TblCabUnits (NOLOCK)
                                    WHERE SN = CAST(@Dflt_MCUnit as int)
                        END
                        else IF @Dflt_MCUnit is null BEGIN
                                    SELECT  Top 1 @MCUnit = isnull(UnitId,'') 
                                    FROM TblCabUnits (NOLOCK)
                                    WHERE Truck = @SN_TblTrkDrv and LinkedAddrType = 5 and LinkedObjSN = @SN_TblTrkDrv  
                                    ORDER BY SN 
                        END
            END

END
GO
GRANT EXECUTE ON  [dbo].[tm_GetMCUnit] TO [public]
GO
