SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/* DPETE PTS22154 3/30/04 (Paul's Hauling) Need to specify by company what may be picked up or delivered.
   For pickups only, specify product characterisitcs (density)
* 11/28/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 12/16/12 PTS66204 add fgt_suuplier
*/
CREATE PROCEDURE [dbo].[companyproduct_sp] @cmpid varchar(8),@pupdrp char(3),@cmdcode varchar(8)
AS

Select 
    cpr_identity   
,    cpr.cmp_ID 
,    cpr_pup_or_drp 
,		 cpr.cmd_code 
,    cpr.scm_subcode	
,    cpr_StartMonth
,    cpr_Startday 
,    cpr_EndMonth 
,    cpr_EndDay 
,    cpr_UpdateBy 
,    cpr_UpdateDate
,    cpr_density 
,    scm_description = IsNull(scm_description,'Sub code not defined')
,verticalbar = ' '
,    cmp_name
,  ISNULL(cpr.fgt_supplier,'UNKNOWN') fgt_supplier
From subcommodity scm  RIGHT OUTER JOIN  companyproduct cpr  ON  (scm.cmd_code  = cpr.cmd_code  AND	scm.scm_subcode  = cpr.scm_subcode)   
	LEFT OUTER JOIN  company  ON  company.cmp_id  = cpr.cmp_id  --pts40462 outer join conversion
Where @cmpid in ('UNKNOWN',cpr.cmp_id)
And cpr_pup_or_drp = @pupdrp
And @cmdcode in ('UNKNOWN',cpr.cmd_code)
Order by cpr.cmp_id,cpr.cmd_code,cpr.scm_subcode,cpr_startMonth

GO
GRANT EXECUTE ON  [dbo].[companyproduct_sp] TO [public]
GO
