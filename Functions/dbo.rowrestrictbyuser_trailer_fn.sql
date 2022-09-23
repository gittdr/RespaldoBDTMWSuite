SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[rowrestrictbyuser_trailer_fn]
(
	@trl as varchar(13)
)
RETURNS @Table TABLE(Value VARCHAR(13))

AS

	--PTS75456 JJF 20140724
	--DEPRECATED.  Do not use.  Use RowRestrictValidAssignments_trailerprofile_fn directly instead.


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
	--SELECT DISTINCT trl.trl_id 
	--FROM trailerprofile trl LEFT OUTER JOIN UserTypeAssignment uta on (trl.trl_terminal  = uta.uta_type1 or uta_type1 = 'UNK' or trl.trl_terminal = 'UNK') and usr_userid = @tmwuser
	--WHERE trl_id  LIKE @trl + '%'
	--		AND (uta.usr_userid = @tmwuser OR NOT EXISTS(SELECT * FROM UserTypeAssignment WHERE usr_userid = @tmwuser))

	INSERT @Table (value)
	SELECT DISTINCT trl.trl_id
	FROM trailerprofile trl INNER JOIN RowRestrictValidAssignments_trailerprofile_fn() rsva on (trl.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	WHERE trl_id  LIKE @trl + '%'
	--END PTS 51570 JJF 20100426

	RETURN 
END
GO
GRANT REFERENCES ON  [dbo].[rowrestrictbyuser_trailer_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[rowrestrictbyuser_trailer_fn] TO [public]
GO
