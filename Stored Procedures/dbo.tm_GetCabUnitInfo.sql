SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[tm_GetCabUnitInfo] @CabUnit varchar(30), @MCommType varchar(30), @InstanceID varchar(30)
as
declare @EffMCType int, @EffInstance int
SET @EffInstance=NULL
SET @EffMCType=NULL
if ISNUMERIC(@InstanceID)<>0 SET @EffInstance=CONVERT(int, @InstanceID)
if ISNUMERIC(@MCommType)<>0 SET @EffMCType=CONVERT(int, @MCommType)
select tbldrivers.DispSysDriverID DRV, tbldrivers.Name TMDRV, 
	tblTrucks.DispSysTruckID TRC, tblTrucks.TruckID TMTRC, 
	tblCabUnits.LinkedAddrType AddrType 
	from tblCabUnits 
		left outer join tblDrivers on tblCabUnits.LinkedObjSN = tblDrivers.SN and tblCabUnits.LinkedAddrType=5
		left outer join tblTrucks on tblCabUnits.LinkedObjSN = tblTrucks.SN and tblCabUnits.LinkedAddrType=4
where tblCabUnits.UnitID=@CabUnit 
	and ISNULL(tblCabUnits.InstanceId, 1) = ISNULL(@EffInstance, ISNULL(tblCabUnits.InstanceId, 1))
	and ISNULL(tblCabUnits.Type, 0) = ISNULL(@EffMCType, ISNULL(tblCabUnits.Type, 0))
GO
GRANT EXECUTE ON  [dbo].[tm_GetCabUnitInfo] TO [public]
GO
