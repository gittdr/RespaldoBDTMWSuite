SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/* DPETE 22154 3/30/04 Finds where a subcode is in use for a company product



*/
CREATE PROCEDURE [dbo].[is_subcode_inuse_sp] @cmdcode varchar(8),@subcode varchar(8)
AS

Select cmp_id
,cpr_pup_or_drp
,cpr_startmonth
,cpr_startday
,cpr_endmonth
,cpr_endday
,cpr_identity
,cmd_code
,scm_subcode
From companyproduct
Where cmd_code = @cmdcode
And scm_subcode = @subcode
Order By cmp_id,cpr_pup_or_drp

GO
GRANT EXECUTE ON  [dbo].[is_subcode_inuse_sp] TO [public]
GO
