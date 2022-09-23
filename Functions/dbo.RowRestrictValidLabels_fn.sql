SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [dbo].[RowRestrictValidLabels_fn](@labeldefinition varchar(20))
RETURNS @Table TABLE	(
	abbr varchar(6) NOT NULL
)

AS

BEGIN
	--This is the primary function called that retrieves all valid label entries
	--Returns a table of all allowed label values
	
	DECLARE @tmwuser 		varchar(255)

	IF NOT EXISTS	(	SELECT	*
						FROM	RowSecColumns rsc
						WHERE	rsc.rsc_sequence > 0
								AND rsc.labeldefinition_values = @labeldefinition
					) BEGIN
		--Security not set up on any table table.  Return a wildcard indicator
		INSERT	@table (abbr)
		SELECT	'*'
	END
	ELSE BEGIN

		EXEC	@tmwuser = dbo.gettmwuser_fn
		
		INSERT	@table (abbr)
		
		SELECT DISTINCT abbr 
		FROM	labelfile lbl 
				INNER JOIN RowSecColumnValues rscv on rscv.rscv_value = lbl.abbr
				INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id
				INNER JOIN RowSecUserAssignments rsua on rsua.rscv_id = rscv.rscv_id
		WHERE	((rsua.usr_userid = @tmwuser and rsua.rsua_idtype = 'U') 
				 OR (rsua.rsua_idtype = 'G' and rsua.usr_userid in (select g.grp_id from ttsgroupasgn g where g.usr_userid = @tmwuser)))
				AND rsc.labeldefinition_values = @labeldefinition
				AND lbl.labeldefinition = @labeldefinition
		--expand unknowns	
		UNION 
		SELECT DISTINCT abbr 
		FROM	labelfile lbl 
		WHERE	lbl.labeldefinition = @labeldefinition
		  AND	exists (	SELECT	rscv_inner1.rscv_value
								FROM	RowSecUserAssignments rsua_inner1
										INNER JOIN RowSecColumnValues rscv_inner1 on rsua_inner1.rscv_id = rscv_inner1.rscv_id
										INNER JOIN RowSecColumns rsc_inner1 on rsc_inner1.rsc_id = rscv_inner1.rsc_id
								WHERE	((rsua_inner1.usr_userid = @tmwuser and rsua_inner1.rsua_idtype = 'U') 
										 OR (rsua_inner1.rsua_idtype = 'G' and rsua_inner1.usr_userid in (select g.grp_id from ttsgroupasgn g where g.usr_userid = @tmwuser)))
										AND rsc_inner1.labeldefinition_values = @labeldefinition
										AND rsc_inner1.rsc_sequence > 0
										AND rscv_inner1.rscv_value = rsc_inner1.rsc_unknown_value
										AND NOT EXISTS	(	SELECT	*
															FROM	RowSecUserAssignments rsua_inner2
																	INNER JOIN RowSecColumnValues rscv_inner2 on rsua_inner2.rscv_id = rscv_inner2.rscv_id
															WHERE	((rsua_inner2.usr_userid = @tmwuser and rsua_inner2.rsua_idtype = 'U') 
																	 OR (rsua_inner2.rsua_idtype = 'G' and rsua_inner2.usr_userid in (select g.grp_id from ttsgroupasgn g where g.usr_userid = @tmwuser)))
																	AND rscv_inner2.rsc_id = rsc_inner1.rsc_id
																	AND rscv_inner2.rscv_value <> rsc_inner1.rsc_unknown_value
														)
					)
	
	END
	
	RETURN 

	
END
GO
GRANT REFERENCES ON  [dbo].[RowRestrictValidLabels_fn] TO [public]
GO
GRANT SELECT ON  [dbo].[RowRestrictValidLabels_fn] TO [public]
GO
