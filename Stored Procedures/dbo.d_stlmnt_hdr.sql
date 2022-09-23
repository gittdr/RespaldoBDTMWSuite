SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create PROC [dbo].[d_stlmnt_hdr](@payheader 	int,
 			@paydate	datetime,
			@asgn_type 	varchar(6),
			@asgn_id 	varchar(8))

AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/06/2007.01 ? PTS40186 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * 7-23-2009 JSwindell   PTS 47021   Add Columns.  payee_invoice_number(x30),  payee_invoice_date (datetime)
 * 05/20/2011	 - pts54402 - vjh - add payto as a pseudo asgn_type for pay headers
 *
 **/

exec d_stlmnt_hdr_overloadpayto @payheader, @paydate, @asgn_type, @asgn_id, ''


GO
GRANT EXECUTE ON  [dbo].[d_stlmnt_hdr] TO [public]
GO
