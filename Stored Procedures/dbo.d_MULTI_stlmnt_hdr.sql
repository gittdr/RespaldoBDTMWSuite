SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_MULTI_stlmnt_hdr](@paydate	datetime,	@asgn_type 	varchar(6),	@asgn_id 	varchar(8))

AS
/* Revision History:
	Date		Name		Label	Description
	-----------	---------------	-------	------------------------------------------------------------------------------------
	
	3/27/2009	JSwindell	PTS 45170   Created.
	4/10/09		PTS 45170 fix: Don't pull payheader numbers = 0
	5/20/2009   PTS 47082 fix: limit data to only the date desired.
*/

select distinct pd.pyh_number, pd.lgh_number, pd.mov_number, pd.ord_hdrnumber
from paydetail pd
where pd.asgn_type = @asgn_type 
and   pd.asgn_id = @asgn_id  
and   pd.pyh_number > 0
and   pd.lgh_number in ( select ph.pyh_lgh_number from payheader ph where 
						        ph.pyh_payperiod = @paydate and ph.asgn_type = @asgn_type  and  ph.asgn_id = @asgn_id )
And   pd.pyh_payperiod = @paydate			-- PTS 47082 fix.
order by pyh_number

GO
GRANT EXECUTE ON  [dbo].[d_MULTI_stlmnt_hdr] TO [public]
GO
