SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[rowrestrictbyuser_company_fn]
(
	@comp as varchar(8)
)
RETURNS @Table TABLE(Value VARCHAR(8))

AS


	--PTS75456 JJF 20140724
	--DEPRECATED.  Do not use.  Use RowRestrictValidAssignments_company_fn directly instead.


/**
 * 
 * NAME:
 * dbo.rowrestrictbyuser_company_fn
 *
 * TYPE:
 * UDF
 *
 * DESCRIPTION:
 * Returns companies that match based on user revtype
 * 
 *
 * RETURNS:
 * table of acceptable companies
 *
 *
 **/

BEGIN


	--PTS 51570 JJF 20100510
	--DECLARE @tmwuser 		varchar(255)

	--exec @tmwuser = dbo.gettmwuser_fn

	--INSERT @Table
	--SELECT DISTINCT cmp.cmp_id 
	--FROM Company cmp LEFT OUTER JOIN UserTypeAssignment uta on (cmp.cmp_BelongsTo  = uta.uta_type1 or uta_type1 = 'UNK' or cmp.cmp_BelongsTo = 'UNK') and usr_userid = @tmwuser 
	--WHERE cmp_id LIKE @comp + '%'
	--		AND (uta.usr_userid = @tmwuser OR NOT EXISTS(SELECT * FROM UserTypeAssignment WHERE usr_userid = @tmwuser))

	INSERT @Table (value)
	SELECT DISTINCT cmp.cmp_id
	FROM Company cmp INNER JOIN RowRestrictValidAssignments_company_fn() rsva on (cmp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	WHERE cmp_id LIKE @comp + '%'
	--END PTS 51570 JJF 20100426

	RETURN 
END
GO
GRANT REFERENCES ON  [dbo].[rowrestrictbyuser_company_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[rowrestrictbyuser_company_fn] TO [public]
GO
