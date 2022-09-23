SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec sp_ordenesdx '2016-10-01' , '2016-10-11', 'SAYER'

CREATE proc [dbo].[sp_ordenesdx] (@fini datetime, @ffin datetime, @flota varchar(20))
as

declare @temp as table (dx int, man int)


if (@fini = '2099-12-31')
 begin
  select @fini =    CONVERT(varchar,getdate()-7,101)
  select @ffin =  CONVERT(varchar,getdate(),101)
 end


insert into @temp 

select count(*),0  from orderheader (nolock) where ord_bookedby = 'DX'
and (ord_Startdate between @fini and @ffin) 
and ord_Status <> 'CAN'
and ord_tractor in (select trc_number from tractorprofile (nolock) where trc_fleet = (select abbr from labelfile where labeldefinition  = 'fleet' and name = @flota) and trc_status <> 'OUT')


update @temp set man =
(select count(*)  from orderheader (nolock) 
where ord_bookedby <> 'DX'
and (ord_Startdate between @fini and @ffin) 
and ord_Status <> 'CAN'
and ord_tractor in (select trc_number from tractorprofile (nolock) where trc_fleet = (select abbr from labelfile where labeldefinition  = 'fleet' and name = @flota) and trc_status <> 'OUT'))


select * from @temp
GO
