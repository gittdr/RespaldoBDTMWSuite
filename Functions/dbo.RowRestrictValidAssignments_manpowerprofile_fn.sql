SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [dbo].[RowRestrictValidAssignments_manpowerprofile_fn]()
RETURNS @Table TABLE	(
	rowsec_rsrv_id int NOT NULL
)

AS

BEGIN
	INSERT	@Table
	SELECT	rowsec_rsrv_id
	FROM	RowRestrictValidAssignments_fn('manpowerprofile')
	
	RETURN  
END
GO
GRANT REFERENCES ON  [dbo].[RowRestrictValidAssignments_manpowerprofile_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[RowRestrictValidAssignments_manpowerprofile_fn] TO [public]
GO
