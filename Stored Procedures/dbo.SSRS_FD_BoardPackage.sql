SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[SSRS_FD_BoardPackage]     
 (@startdate as datetime,      
  @pbcid int,
  @DriverID as varchar(MAX))    
as    
    
    
set transaction isolation level read uncommitted  
    
    
declare @sql varchar(8000)    
declare @where2 varchar(500)    
    
declare @whereclause varchar (500)    
declare @fromtable varchar (150)    
declare @strstartdate as varchar(10)    
    
-- [SSRS_FD_BoardPackage] '2013-06-05', 29, 'ANTOAN'
    
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
    
set @whereclause = @whereclause + ' and v.boarddate = ''' + @strstartdate + ''''    
    
set @sql = 'select lgh.lgh_number' +    
     ' FROM ' +  @fromtable + ' v WITH (NOLOCK) ' +     
   ' inner join shiftschedules ss WITH (NOLOCK) on v.driver = ss.mpp_id and ss.ss_date = ''' + @strstartdate + '''' +    
   ' inner join legheader lgh on lgh.shift_ss_id = ss.ss_id ' +    
    ' WHERE ' + substring(@whereclause,5,len(@whereclause))     
        
print @sql    
    
    
declare @Trips TABLE     
 (lgh_number int)    
    
    
if @DriverID = 'All'
 begin     
  INSERT INTO @Trips    
  exec (@sql)     
    end
else
 begin
  INSERT INTO @Trips    
  select lgh.lgh_number from legheader lgh
   inner join shiftschedules ss WITH (NOLOCK) on ss.ss_id = lgh.shift_ss_id
  where ss.mpp_id = @DriverID and ss.ss_date = @startdate
    end
    
    
select     
 l.mfh_number,    
 l.lgh_number,    
 l.lgh_driver1,  
 MPP.mpp_lastfirst,  
 l.lgh_startdate  
    
from @Trips t     
 inner join dbo.legheader l with (NOLOCK) on l.lgh_number = t.lgh_number              
 inner join dbo.manpowerprofile mpp on mpp.mpp_id = l.lgh_driver1  
    
order by l.lgh_driver1, l.mfh_number    
    
  
  
--  [SSRS_FD_BoardPackage] '2013-06-05', 29    
  
--select stp_mfh_sequence, * from stops where ord_hdrnumber = 31774
GO
GRANT EXECUTE ON  [dbo].[SSRS_FD_BoardPackage] TO [public]
GO
