SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[SSRS_FD_Board]       
 (@startdate as datetime,        
  @pbcid int)      
as      
      
      
declare @sql varchar(8000)      
declare @where2 varchar(500)      
      
declare @whereclause varchar (500)      
declare @fromtable varchar (150)      
declare @strstartdate as varchar(10)      
      
      
-- [SSRS_FD_Board] '2013-06-07', '30'  
      
      
      
set @sql = ''      
set @where2 = ''      
set @whereclause = ''      
set @strstartdate = cast(datepart(m,@startdate) as varchar(2)) + '/' +      
   cast(datepart(d,@startdate) as varchar(2)) + '/' +      
   cast(datepart(yyyy,@startdate) as varchar(4))       
      
--select pbcid, Description, * from planningboardconfig where BoardType = 'POWER'      
      
set @fromtable = (select DriverViewName from planningboardconfig WITH (NOLOCK) where pbcid = @pbcid)      
      
select @where2 = ('v.' + w.columnname + ' ' + w.columnwhere),@whereclause = ' and ' + @where2 + @whereclause        
   from planningboardconfigwhere w WITH (NOLOCK) inner join dbo.PlanningBoardConfigColumns c WITH (NOLOCK)      
   on c.pbcid = w.pbcid and w.columnname = c.columnname      
   where w.pbcid = @pbcid and c.viewname = @fromtable      
      
set @whereclause = @whereclause --+ ' and v.boarddate = ''' + @strstartdate + ''''      
      
set @sql = 'select lgh.lgh_number' +      
     ' FROM ' +  @fromtable + ' v WITH (NOLOCK) ' +       
   ' inner join shiftschedules ss WITH (NOLOCK) on v.driver = ss.mpp_id and ss.ss_date = ''' + @strstartdate + '''' +      
   ' inner join legheader lgh on lgh.shift_ss_id = ss.ss_id ' +      
    ' WHERE ' + substring(@whereclause,5,len(@whereclause))       
          
print @sql      
      
      
CREATE TABLE #tmp (lgh_number int)      
INSERT INTO #tmp      
exec (@sql)       
      
      
CREATE TABLE #Driver      
 (      
  mpp_id varchar(20)      
 )      
INSERT INTO #Driver      
select distinct      
 mpp.mpp_id      
from #tmp      
 inner join legheader lgh on lgh.lgh_number = #tmp.lgh_number      
 inner join manpowerprofile mpp on mpp.mpp_id = lgh.lgh_driver1      
      
      
CREATE TABLE #DriverTrips       
 (mpp_id varchar(20),      
  lgh_number int,      
  mfh_number int      
  )      
INSERT INTO #DriverTrips      
select       
 mpp.mpp_id,      
 lgh.lgh_number,      
 lgh.mfh_number      
from #tmp      
 inner join legheader lgh on lgh.lgh_number = #tmp.lgh_number      
 inner join manpowerprofile mpp on mpp.mpp_id = lgh.lgh_driver1      
      
      
      
      
select       
 mpp.mpp_id,      
 mpp.mpp_lastfirst,      
 ss.ss_shift,      
 (select max(Description) from planningboardconfig where BoardType = 'POWER' and pbcid = @pbcid) as 'Board Name',      
       
 Trip1.lgh_driver1 as 'Trip 1 Driver',      
 Trip1.lgh_tractor as 'Trip 1 Tractor',      
 Trip1.lgh_primary_trailer as 'Trip 1 Trailer',      
 Trip1.mfh_number as 'Trip 1',      
 Trip1.lgh_outstatus as 'Trip 1 Status',      
 Trip1.ord_hdrnumber as 'Trip 1 Order No',      
 Trip1.lgh_startcty_nmstct as 'Trip 1 Start City',      
 Trip1.lgh_endcty_nmstct as 'Trip 1 End City',      
 ord1Ship.cmp_name as 'Trip 1 Shipper',  
 ord1Con.cmp_name as 'Trip 1 Consignee',  
 --[dbo].[fcn_referencenumbers_comma_sep](Trip1.ord_hdrnumber,'orderheader') 'Trip 1 Ref',      
       
 Trip2.lgh_driver1 as 'Trip 2 Driver',      
 Trip2.lgh_tractor as 'Trip 2 Tractor',      
 Trip2.lgh_primary_trailer as 'Trip 2 Trailer',      
 Trip2.mfh_number as 'Trip 2',      
 Trip2.lgh_outstatus as 'Trip 2 Status',      
 Trip2.ord_hdrnumber as 'Trip 2 Order No',      
 Trip2.lgh_startcty_nmstct as 'Trip 2 Start City',      
 Trip2.lgh_endcty_nmstct as 'Trip 2 End City',    
 ord2Ship.cmp_name as 'Trip 2 Shipper',  
 ord2Con.cmp_name as 'Trip 2 Consignee',    
 --[dbo].[fcn_referencenumbers_comma_sep](Trip2.ord_hdrnumber,'orderheader') 'Trip 2 Ref',      
       
 Trip3.lgh_driver1 as 'Trip 3 Driver',      
 Trip3.lgh_tractor as 'Trip 3 Tractor',      
 Trip3.lgh_primary_trailer as 'Trip 3 Trailer',      
 Trip3.mfh_number as 'Trip 3',      
 Trip3.lgh_outstatus as 'Trip 3 Status',      
 Trip3.ord_hdrnumber as 'Trip 3 Order No',      
 Trip3.lgh_startcty_nmstct as 'Trip 3 Start City',      
 Trip3.lgh_endcty_nmstct as 'Trip 3 End City',      
 ord3Ship.cmp_name as 'Trip 3 Shipper',  
 ord3Con.cmp_name as 'Trip 3 Consignee',  
   
 --[dbo].[fcn_referencenumbers_comma_sep](Trip3.ord_hdrnumber,'orderheader') 'Trip 3 Ref',      
       
 Trip4.lgh_driver1 as 'Trip 4 Driver',        
 Trip4.lgh_tractor as 'Trip 4 Tractor',      
 Trip4.lgh_primary_trailer as 'Trip 4 Trailer',      
 Trip4.mfh_number as 'Trip 4',      
 Trip4.lgh_outstatus as 'Trip 4 Status',      
 Trip4.ord_hdrnumber as 'Trip 4 Order No',      
 Trip4.lgh_startcty_nmstct as 'Trip 4 Start City',      
 Trip4.lgh_endcty_nmstct as 'Trip 4 End City',      
 ord4Ship.cmp_name as 'Trip 4 Shipper',  
 ord4Con.cmp_name as 'Trip 4 Consignee',  
 --[dbo].[fcn_referencenumbers_comma_sep](Trip4.ord_hdrnumber,'orderheader') 'Trip 4 Ref',      
       
 Trip5.lgh_driver1 as 'Trip 5 Driver',        
 Trip5.lgh_tractor as 'Trip 5 Tractor',      
 Trip5.lgh_primary_trailer as 'Trip 5 Trailer',      
 Trip5.mfh_number as 'Trip 5',      
 Trip5.lgh_outstatus as 'Trip 5 Status',      
 Trip5.ord_hdrnumber as 'Trip 5 Order No',      
 Trip5.lgh_startcty_nmstct as 'Trip 5 Start City',      
 Trip5.lgh_endcty_nmstct as 'Trip 5 End City',      
 ord5Ship.cmp_name as 'Trip 5 Shipper',  
 ord5Con.cmp_name as 'Trip 5 Consignee',  
 --[dbo].[fcn_referencenumbers_comma_sep](Trip5.ord_hdrnumber,'orderheader') 'Trip 5 Ref',      
       
 Trip6.lgh_driver1 as 'Trip 6 Driver',        
 Trip6.lgh_tractor as 'Trip 6 Tractor',      
 Trip6.lgh_primary_trailer as 'Trip 6 Trailer',      
 Trip6.mfh_number as 'Trip 6',      
 Trip6.lgh_outstatus as 'Trip 6 Status',      
 Trip6.ord_hdrnumber as 'Trip 6 Order No',      
 Trip6.lgh_startcty_nmstct as 'Trip 6 Start City',      
 Trip6.lgh_endcty_nmstct as 'Trip 6 End City',  
 ord6Ship.cmp_name as 'Trip 6 Shipper',  
 ord6Con.cmp_name as 'Trip 6 Consignee'  
 --[dbo].[fcn_referencenumbers_comma_sep](Trip6.ord_hdrnumber,'orderheader') 'Trip 6 Ref'      
       
       
from #Driver      
 left join legheader Trip1 on Trip1.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 1)      
 left join orderheader ord1 on ord1.ord_hdrnumber = Trip1.ord_hdrnumber  
 left join company ord1Ship on ord1Ship.cmp_id = ord1.ord_shipper  
 left join company ord1Con on ord1Con.cmp_id = ord1.ord_consignee  
               
 left join legheader Trip2 on Trip2.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 2)     
 left join orderheader ord2 on ord2.ord_hdrnumber = Trip2.ord_hdrnumber   
 left join company ord2Ship on ord2Ship.cmp_id = ord2.ord_shipper  
 left join company ord2Con on ord2Con.cmp_id = ord2.ord_consignee             
     
 left join legheader Trip3 on Trip3.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 3)      
  left join orderheader ord3 on ord3.ord_hdrnumber = Trip3.ord_hdrnumber  
 left join company ord3Ship on ord3Ship.cmp_id = ord3.ord_shipper  
 left join company ord3Con on ord3Con.cmp_id = ord3.ord_consignee  
   
 left join legheader Trip4 on Trip4.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 4)      
 left join orderheader ord4 on ord4.ord_hdrnumber = Trip4.ord_hdrnumber  
 left join company ord4Ship on ord4Ship.cmp_id = ord4.ord_shipper  
 left join company ord4Con on ord4Con.cmp_id = ord4.ord_consignee  
   
 left join legheader Trip5 on Trip5.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 5)      
 left join orderheader ord5 on ord5.ord_hdrnumber = Trip5.ord_hdrnumber  
 left join company ord5Ship on ord5Ship.cmp_id = ord5.ord_shipper  
 left join company ord5Con on ord5Con.cmp_id = ord5.ord_consignee  
   
 left join legheader Trip6 on Trip6.lgh_number = (select max(lgh_number) from #DriverTrips dt      
             where dt.mpp_id = #Driver.mpp_id and dt.mfh_number = 6)   
 left join orderheader ord6 on ord6.ord_hdrnumber = Trip6.ord_hdrnumber  
 left join company ord6Ship on ord6Ship.cmp_id = ord6.ord_shipper  
 left join company ord6Con on ord6Con.cmp_id = ord6.ord_consignee                  
      
 inner join manpowerprofile mpp on mpp.mpp_id = Trip1.lgh_driver1      
   
 inner join shiftschedules ss on ss.ss_id = Trip1.shift_ss_id      
      
      
--drop table #tmp      
      
      
-- select top 1 * from legheader        
      
      
-- exec SSRS_FD_Board '2012-11-05', 25
GO
