SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[rowrestrictbyuser_tractor_fn]
(
	@trc as varchar(8)
)
RETURNS @Table TABLE(Value VARCHAR(8))

AS

	--PTS75456 JJF 20140724
	--DEPRECATED.  Do not use.  Use RowRestrictValidAssignments_TractorProfile_fn directly instead.


/**
 * 
 * NAME:
 * dbo.rowrestrictbyuser_trailer_fn
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



	--PTS 51570 JJF 20100426
	--DECLARE @tmwuser 		varchar(255)

	--exec @tmwuser = dbo.gettmwuser_fn
	
	--INSERT @Table
	--SELECT DISTINCT trc.trc_number
	--FROM tractorprofile trc LEFT OUTER JOIN UserTypeAssignment uta on (trc.trc_terminal = uta.uta_type1 or uta_type1 = 'UNK' or trc.trc_terminal = 'UNK') and usr_userid = @tmwuser
	--WHERE trc_number  LIKE @trc + '%'
	--		AND (uta.usr_userid = @tmwuser OR NOT EXISTS(SELECT * FROM UserTypeAssignment WHERE usr_userid = @tmwuser))

	INSERT @Table (value)
	SELECT DISTINCT trc.trc_number
	FROM tractorprofile trc INNER JOIN RowRestrictValidAssignments_TractorProfile_fn() rsva on (trc.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	WHERE trc_number  LIKE @trc + '%'
	--END PTS 51570 JJF 20100426

	RETURN 
END
GO
GRANT REFERENCES ON  [dbo].[rowrestrictbyuser_tractor_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[rowrestrictbyuser_tractor_fn] TO [public]
GO
