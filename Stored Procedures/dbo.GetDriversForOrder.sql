SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[GetDriversForOrder] @pl_ordhdrnumber int
AS
  
/* Created 8/22/12 DPETE PTS63725 to retriev all the drivers for all legs  of the order  
   9/25 retrun asgn_enddate to insert date of trip on messages
  
*/  
set nocount on  
DECLARE @moves table (mov_number int)  
DECLARE @legs table (lgh_number int)  
DECLARE @results table (evt_driver1 varchar(8) , drivername varchar(50) null, mpp_tractornumber varchar(15) null
   , mpp_email varchar(50) null, cmp_id_start varchar(50) null, cmp_id_end varchar(50) null, asgn_enddate datetime null)  
  
  
INSERT into @moves  
SELECT distinct mov_number   
FROM stops WITH (NOLOCK)   
WHERE ord_hdrnumber = @pl_ordhdrnumber  
AND ord_hdrnumber > 0  
  
INSERT INTO @legs  
SELECT Distinct lgh_number   
FROM @moves mov
join stops WITH (NOLOCK) on mov.mov_number = stops.mov_number   

  
/* if you want both primary and secondary driver remove the asgn_controlling = 'Y' */
INSERT Into @results 
select Distinct asgn_id
, substring(left(isnull(mpp_firstname,''),1)  + ' ' + isnull(mpp_lastname,'') ,1,50)  
, isnull(mpp_tractornumber,'UNKNOWN') mpp_tractornumber
, isnull(mpp_email,'') mpp_email
,ISNULL(cmp_id_start,'') + '(' + SUBSTRING(lgh_startcty_nmstct,1,CHARINDEX(',',isnull(lgh_startcty_nmstct,'') + ' ,') - 1) + ')'
,isnull(cmp_id_end,'') + '(' + SUBSTRING(lgh_endcty_nmstct,1,CHARINDEX(',',isnull(lgh_endcty_nmstct,'') + ' ,') - 1) + ')'
,asgn_enddate   
From @legs legs  
join assetassignment WITH (NOLOCK) on legs.lgh_number = assetassignment.lgh_number and asgn_type = 'DRV' and asgn_controlling = 'Y'  
left outer join manpowerprofile WITH (NOLOCK) on assetassignment.asgn_id = manpowerprofile.mpp_id 
left outer join legheader on assetassignment.lgh_number = legheader.lgh_number 
where assetassignment.asgn_id <> 'UNKNOWN' and rtrim(isnull(assetassignment.asgn_id,'')) <> ''  
order by asgn_enddate

if @@ROWCOUNT = 0  
   INSERT into @results  values ('????????','No Driver','','','','','19500101 00:00')  
  
Select evt_driver1,drivername,mpp_tractornumber,mpp_email,cmp_id_start, cmp_id_end,asgn_enddate from @results  

GO
GRANT EXECUTE ON  [dbo].[GetDriversForOrder] TO [public]
GO
