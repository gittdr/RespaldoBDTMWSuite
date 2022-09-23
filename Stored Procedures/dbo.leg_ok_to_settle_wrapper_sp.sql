SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE proc [dbo].[leg_ok_to_settle_wrapper_sp]  (
	@p_leg				int,
	@ps_returnvalue		varchar(60) output)

AS  
BEGIN
/**
 * 
 * NAME:
 * dbo.leg_ok_to_settle_wrapper_sp
 *
 * TYPE:
 * Function
 *
 * DESCRIPTION:
 * This proc replaces logic strung throughout d_scroll_assignments and
 * w_stlmnt_edit::wf_retrieveit, where settings SplitMustINV,
 * STLMustINV and StlXInvStat are applied.  It also introduces 2 changes:
 *   1. Cross Dock legs now become order aware
 *   2. Invoice by Move is supported
 *
 * RETURNS:
 * Y/N
 *
 * RESULT SETS: 
 * na
 *
 * PARAMETERS:
 *	001 - @p_leg			int
 *	001 - @ps_returnvalue	varchar(60)
 *
 * REVISION HISTORY:
 * 03/30/09.01 PTS45562, PTS44306 - vjh - created function
 * 07/20/09.01 PTS47363 - vjh - Added LH functionality
 * 09/23/10.01 PTS52942 - vjh - add SLTMUSTORD to control restriction legs unless all orders on that led are complete.
 *
 **/

declare	@StlMustInv		char(1)
declare	@StlMustOrd		char(1)
declare	@StlMustInvLH	char(60)
declare	@SplitMustInv	char(1)
declare	@ps_CRBST		char(1) --ComputeRevenueByTripSegment
declare	@ls_invstat1	varchar(60)
declare	@ls_invstat2	varchar(60)
declare	@ls_invstat3	varchar(60)
declare	@ls_invstat4	varchar(60)
declare	@ComputeRevenueByTripSegment	varchar(60)

SELECT @ComputeRevenueByTripSegment = Upper(gi_string1) from generalinfo where Upper(gi_name) = 'COMPUTEREVENUEBYTRIPSEGMENT'
select 	@ls_invstat1 = gi_string1,
	@ls_invstat2 = gi_string2,
	@ls_invstat3 = gi_string3,
	@ls_invstat4 = gi_string4
from 	generalinfo 
where 	gi_name = 'StlXInvStat'
select @ls_invstat1 = IsNull(@ls_invstat1,'')
select @ls_invstat2 = IsNull(@ls_invstat2,@ls_invstat1)
select @ls_invstat3 = IsNull(@ls_invstat3,@ls_invstat1)
select @ls_invstat4 = IsNull(@ls_invstat4,@ls_invstat1)
select @splitmustinv = substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'SPLITMUSTINV'
select @stlmustinv =  substring(upper(gi_string1),1,1),
	@stlmustinvLH =  upper(gi_string2)
from generalinfo
where gi_name = 'STLMUSTINV'
select @StlMustOrd = substring(upper(gi_string1),1,1) from generalinfo where gi_name = 'STLMUSTORD'

if @stlmustinvLH is null or @stlmustinvLH <> 'ALL' set @stlmustinvLH = 'LH'

exec dbo.leg_ok_to_settle_sp  
	@p_leg,
	@StlMustInv,
	@StlMustInvLH,
	@SplitMustInv,
	@StlMustOrd,
	@ps_CRBST, 
	@ls_invstat1,
	@ls_invstat2,
	@ls_invstat3,
	@ls_invstat4,
	@ps_returnvalue output

END
GO
GRANT EXECUTE ON  [dbo].[leg_ok_to_settle_wrapper_sp] TO [public]
GO
