SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[WhereIsHruleUsed]      
 @p_hruleid int 
  
AS      
/**      
 *       
 * NAME:      
 * dbo.WhereIsHruleUsed  
 *      
 * TYPE:      
 * StoredProcedure      
 *      
 * DESCRIPTION:      
 * Pass the idnetity for a holiday rule and return a list of all order schedules where this rule is applied
 *      
 *            
 * RETURNS:      
 * no return code      
 *      
 * RESULT SETS:       
 *  NONE      
 *      
 * PARAMETERS:      
 * 001 -  @p_hruleid  int       
 *      
 * REFERENCES:      
 *       
 * REVISION HISTORY:      
 * 6/6/07 DPETE PTS35732- Created stored proc for SR requiring all  trips to be adjusted for the time zone.      
  * 7/30/07 DPETE 38586 swu=itch form sch_number to sch_masterid as key    
 *      
 **/ 
declare @today datetime
select @today = cast(floor(cast (getdate() as float)) as datetime)
     
Select 
shr.sch_masterid
,sch_description
,sch.ord_hdrnumber
,sch.mov_number
,lgh_number
,sch_expires_on
,sch_lastrundate
,sch_timestorun
,mpp_id,trc_number
,trl_id
,car_id
,ord_number = isnull(orderheader.ord_number,'')
,sch_copies
From schedule_holidayRules shr
join schedule_table sch on shr.sch_masterid = sch.sch_masterid
left outer join orderheader on sch.ord_hdrnumber = orderheader.ord_hdrnumber
where shr.hrule_id = @p_hruleid
and sch_expires_on >= @today

GO
GRANT EXECUTE ON  [dbo].[WhereIsHruleUsed] TO [public]
GO
