SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_asigned_views_sp] @viewtype varchar(2), @userid varchar(20) 
AS

-- PTS 49350 SGB 10/05/09 Increased @userid from varchar 12 to 20 
--create table #tablevar (dv_id varchar(8), grouporuser int)  -- RE - PTS #45466


--insert into #tablevar -- RE - PTS #45466
  SELECT dvassign.dv_id,   
		 dvassign.dv_validviews, -- RE - PTS #45466
         1  
    FROM dvassign  
   WHERE ( dvassign.dva_userid = @userid ) AND  
         ( dvassign.dva_type = 'USER' ) AND  
         ( dvassign.dv_type = @viewtype )   
   UNION   
  SELECT dvassign.dv_id,   
		 dvassign.dv_validviews, -- RE - PTS #45466
         2  
    FROM dvassign,   
         ttsgroupasgn  
   WHERE ( dvassign.dva_userid = ttsgroupasgn.grp_id ) and  
         ( ( dvassign.dv_type = @viewtype ) AND  
         ( ttsgroupasgn.usr_userid = @userid ) AND  
         ( dvassign.dva_type = 'GROUP' ) )    

--select dvassign.dv_id, dvassign.dv_validviews, grouporuser FROM #tablevar, dvassign where #tablevar.dv_id = dvassign.dv_id -- RE - PTS #45466
--drop table #tablevar -- RE - PTS #45466

GO
GRANT EXECUTE ON  [dbo].[d_asigned_views_sp] TO [public]
GO
