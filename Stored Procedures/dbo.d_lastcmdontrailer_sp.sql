SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 CREATE     PROCEDURE [dbo].[d_lastcmdontrailer_sp] @p_trlid varchar( 13 ), @p_pupid varchar(13), @p_lgh int  AS    
/**    
 *     
 * NAME:    
 * dbo.d_lastcmdontrailer_sp    
 *    
 * TYPE:    
 * StoredProcedure    
 *    
 * DESCRIPTION:    
 * This procedure returns a list of the commodities and their names that    
 * were either picked up or delivered on the most recent    
 * trip segment that the passed trailer and PUP were assigned to. If there    
 * are records in the freight_by_comparment table (compartment loading)  for     
 * the last trip, indicate the commodity in each compartment. If there are    
 * records in the subcommodity table further defining the commodity    
 * and the last coomodity carried has a subcode, display the subcode     
 * name instead of the commodity name    
 *    
 * If the trailer and PUP were on different prior trips, the coomodities form those     
 * trips should be returned    
 *    
 *  Does not return rows for  NULL or UNKNOWN commodities    
 *    
 * ***** Differs from d_view_commodity_last_sp in that it will look at a prior planned trips    
 *       whereas d_view... is looking only at started or completed trip.    
 *    
 * RETURNS:    
 * none.    
 *    
 * RESULT SETS:     
 * trl_id varchar(13) will be trailer ID    
 * cmd_code varchar(8)    
 * commodname varchar (30) comes from either the commodity (cmd_name)  or the subcommodity table (scm_name)    
 * compartment int  from freight_by_compartment if compartment loading done    
 * mov_number int   for verifying the proc is working    
 * trialerposition varchar(4) "lead' fpr lead trailer, 'PUP' for PUP    
 * order number    
 * stp_arrivaldate    
 *    
 * PARAMETERS:    
 * 001 -  @p_trlid trailer ID number    
 * 002 - @p_pupid    PUP ID number (may be UNKNOWN)    
 * 003 - @p_lgh int  current leg lgh_number    
 *    
 * REFERENCES: (called by and calling references only, don't     
 *              include table/view/object references)    
 * N/A    
 *     
 *     
 *     
 *     
 *    
 * REVISION HISTORY:    
 *      
 * 03/16/06 .01 - PTS30927 - D Petersen - Initial release. Need list of last contained products on trip sheet, include compartment    
 * number if loaded into a compartment   
 * 04/25/06 .02 - PTS 32757 - D Petersen - limit the assignmetns checked to those prior to the current trip assignment   
 * 05/24/06 .01 - PTS 33201  - J Guo rework the logic to improve performance 
 * 4/19/08 PTS 40260 DPETE pull into main source for Pauls recode 
 */   
Declare @thisasgndate datetime  
Declare @maxasgndate datetime  
Declare @stp_number_tab TABLE (stp_number int null)  
  
declare @mov int  
  
Select @p_trlid = isnull(@p_trlid,'UNKNWON')      
Select @p_pupid = isnull(@p_pupid,'UNKNWON')
/* make sure the passed lgh_number is the first one on a split trip 
  found that whe you pass the second lgh_number on a split trip you get back infor from first leg */
  
select @mov = mov_number from legheader where lgh_number = @p_lgh
select @p_lgh = min(lgh_number) from stops where mov_number = @mov and stp_mfh_sequence = 1

 
select @thisasgndate = min(asgn_date) from assetassignment   
where lgh_number  = @p_lgh and   
asgn_type = 'trl'  
and asgn_id = @p_trlid   

/* get something distincet about the prior trip this trailer was assigned to */  
select @maxasgndate = max(asgn_date)  
from assetassignment   
         where asgn_type = 'trl'     
         and asgn_id = @p_trlid    
     --    and asgn_status = 'cmp'    
     --    and asgn_id <> 'UNKNOWN'    
     --    and lgh_number <> @p_lgh   
         and asgn_date < @thisasgndate   
--  and exists (select 1 from stops where stops.mov_number = assetassignment.mov_number     
--                                         and stp_type = 'DRP') 

/* Get the mov_number for this trip and then check to make sure it wasn't an empty move */    
  
select @mov = min(mov_number) from assetassignment where asgn_type = 'trl'     
         and asgn_id = @p_trlid  and asgn_date = @maxasgndate  
  
while not exists (select 1 from stops where stops.mov_number = @mov     
                                          and stp_type = 'DRP') and isnull(@mov, 0) > 0  
  
begin  
 select @maxasgndate = max(asgn_date)  
 from assetassignment   
         where asgn_type = 'trl'     
         and asgn_id = @p_trlid    
         and asgn_date < @maxasgndate   
  
select @mov = min(mov_number) from assetassignment where asgn_type = 'trl'     
         and asgn_id = @p_trlid  and asgn_date = @maxasgndate  
end  
   
select distinct     
trl_id = @p_trlid    
,cmd_code = f.cmd_code     
,commodname = case isNull(scm_description,'') when '' then cmd_name else scm_description end     
,compartment = convert(varchar(5),isNull(fbc_compartm_number,0))    
,s.mov_number    
,trailerposition = 'Lead'    
,ord_number    
,stp_arrivaldate    
from stops s    
join freightdetail f on s.stp_number = f.stp_number    
join commodity c on f.cmd_code = c.cmd_code     
join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber    
left outer join subcommodity sc on f.cmd_code = sc.cmd_code and ISNULL(f.scm_subcode,'**') = sc.scm_subcode    
left outer join freight_by_compartment fbc on f.fgt_number = fbc.fgt_number    
where s.stp_number in    
  (select stp_number from stops where lgh_number in (    
      select lgh_number from assetassignment where asgn_type = 'trl' and asgn_id = @p_trlid    
      and mov_number = @mov))  
and stp_type = 'DRP'    
and isnull(f.cmd_code,'UNKNOWN') <> 'UNKNOWN'     
and fbc_compartm_from = 'LEAD'    
  
union all   
    
select distinct     
trl_id = @p_pupid    
,cmd_code = f.cmd_code     
,commodname = case isNull(scm_description,'') when '' then cmd_name else scm_description end     
,compartment = convert(varchar(5),isNull(fbc_compartm_number,0))    
,s.mov_number    
,trailerposition = 'PUP'    
,ord_number    
,stp_arrivaldate    
from stops s    
join freightdetail f on s.stp_number = f.stp_number    
join commodity c on f.cmd_code = c.cmd_code     
join orderheader o on s.ord_hdrnumber = o.ord_hdrnumber    
left outer join subcommodity sc on f.cmd_code = sc.cmd_code and ISNULL(f.scm_subcode,'**') = sc.scm_subcode    
left outer join freight_by_compartment fbc on f.fgt_number = fbc.fgt_number    
where s.stp_number in    
  (select stp_number from stops where lgh_number in (    
      select lgh_number from assetassignment where asgn_type = 'trl' and asgn_id = @p_pupid    
      and mov_number = @mov ))    
and stp_type = 'DRP'    
and isnull(f.cmd_code,'UNKNOWN') <> 'UNKNOWN'     
and fbc_compartm_from = 'PUP'    
  

GO
GRANT EXECUTE ON  [dbo].[d_lastcmdontrailer_sp] TO [public]
GO
