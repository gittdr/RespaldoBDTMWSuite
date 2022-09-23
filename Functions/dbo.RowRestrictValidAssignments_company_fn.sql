SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [dbo].[RowRestrictValidAssignments_company_fn]()
RETURNS @Table TABLE	(
	--PTS 53255 JJF 20101130
	rowsec_rsrv_id int NOT NULL primary key
	--rowsec_rsrv_id int 
	--END PTS 53255 JJF 20101130
)

AS

BEGIN
	INSERT	@Table
	SELECT	rowsec_rsrv_id
	FROM	RowRestrictValidAssignments_fn('company')
	
	RETURN  
END
GO
GRANT REFERENCES ON  [dbo].[RowRestrictValidAssignments_company_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[RowRestrictValidAssignments_company_fn] TO [public]
GO
