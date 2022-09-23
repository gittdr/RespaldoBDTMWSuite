SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec sp_ordenesdx '2016-10-01' , '2016-10-11', 'SAYER'
CREATE  proc [dbo].[sp_ordenesdxdetail] (@fini datetime, @ffin datetime, @flota varchar(20), @modo varchar(4))
as

declare @temp as table (orden varchar(20),fecha datetime, bookedby varchar(20), origen varchar(100), destino varchar(100))


if (@fini = '2099-12-31')
 begin
  select @fini =    CONVERT(varchar,getdate()-7,101)
  select @ffin =  CONVERT(varchar,getdate(),101)
 end


if @modo = 'DX'
 begin

insert into @temp 

select ord_hdrnumber,ord_bookdate,ord_bookedby, ord_shipper, ord_consignee  from orderheader (nolock) where ord_bookedby = 'DX'
and (ord_Startdate between @fini and @ffin) 
and ord_Status <> 'CAN'
and ord_tractor in (select trc_number from tractorprofile (nolock) where trc_fleet = (select abbr from labelfile where labeldefinition  = 'fleet' and name = @flota) and trc_status <> 'OUT')
 end


if @modo = 'NODX'
 begin

insert into @temp 

select ord_hdrnumber,ord_bookdate, ord_bookedby,ord_shipper, ord_consignee  from orderheader (nolock) where ord_bookedby <> 'DX'
and (ord_Startdate between @fini and @ffin) 
and ord_Status <> 'CAN'
and ord_tractor in (select trc_number from tractorprofile (nolock) where trc_fleet = (select abbr from labelfile where labeldefinition  = 'fleet' and name = @flota) and trc_status <> 'OUT')
 end


select * from @temp
GO
