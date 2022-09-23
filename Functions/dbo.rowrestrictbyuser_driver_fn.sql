SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[rowrestrictbyuser_driver_fn]
(
	@drv as varchar(8)
)
RETURNS @Table TABLE(Value VARCHAR(8))

AS


	--PTS75456 JJF 20140724
	--DEPRECATED.  Do not use.  Use RowRestrictValidAssignments_manpowerprofile_fn directly instead.


/**
 * 
 * NAME:
 * dbo.rowrestrictbyuser_driver_fn
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
	--SELECT DISTINCT drv.mpp_id
	--FROM manpowerprofile drv LEFT OUTER JOIN UserTypeAssignment uta on (drv.mpp_terminal  = uta.uta_type1 or uta_type1 = 'UNK' or drv.mpp_terminal = 'UNK') and usr_userid = @tmwuser
	--WHERE mpp_id  LIKE @drv + '%'
	--		AND (uta.usr_userid = @tmwuser OR NOT EXISTS(SELECT * FROM UserTypeAssignment WHERE usr_userid = @tmwuser))
	
	INSERT @Table (value)
	SELECT DISTINCT drv.mpp_id
	FROM manpowerprofile drv INNER JOIN RowRestrictValidAssignments_manpowerprofile_fn() rsva on (drv.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
	WHERE mpp_id LIKE @drv + '%'
	--END PTS 51570 JJF 20100426

	RETURN 
END
GO
GRANT REFERENCES ON  [dbo].[rowrestrictbyuser_driver_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[rowrestrictbyuser_driver_fn] TO [public]
GO
