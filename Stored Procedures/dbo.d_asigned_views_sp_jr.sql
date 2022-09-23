SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Drop Proc d_asigned_views_sp_jr

CREATE PROC [dbo].[d_asigned_views_sp_jr] @viewtype varchar(2), @userid varchar(12) 
AS

create table #tablevar (dv_id varchar(8), grouporuser int)


insert into #tablevar
  SELECT dvassign.dv_id,   
         1  
    FROM dvassign  
   WHERE ( dvassign.dva_userid = @userid ) AND  
         ( dvassign.dva_type = 'USER' ) AND  
         ( dvassign.dv_type = @viewtype )   
   UNION   
  SELECT dvassign.dv_id,   
         2  
    FROM dvassign,   
         ttsgroupasgn  
   WHERE ( dvassign.dva_userid = ttsgroupasgn.grp_id ) and  
         ( ( dvassign.dv_type = @viewtype ) AND  
         ( ttsgroupasgn.usr_userid = @userid ) AND  
         ( dvassign.dva_type = 'GROUP' ) )    

select dvassign.dv_id, dvassign.dv_validviews, grouporuser 
FROM #tablevar, dvassign where #tablevar.dv_id = dvassign.dv_id 

-- se agrego esta parte para las vistas...JR 20 de oct 211
/*and dvassign.dva_userid = @userid
UNION
select dvassign.dv_id, dvassign.dv_validviews, grouporuser 
FROM #tablevar, dvassign where #tablevar.dv_id = dvassign.dv_id and grouporuser = 2
*/
drop table #tablevar


GO
