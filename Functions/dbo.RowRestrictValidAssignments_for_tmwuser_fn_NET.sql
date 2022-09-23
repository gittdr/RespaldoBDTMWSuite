SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--jet - 2/28/12 - PTS 61665, removed from trigger because this affects the settings needed for 
--	a change requested by Ryder and recommended by Mindy (use of a Unique index on mpp_otherid that ignores NULLS)
--SET ANSI_NULLS ON
--GO
--
--SET QUOTED_IDENTIFIER ON
--GO

CREATE  FUNCTION [dbo].[RowRestrictValidAssignments_for_tmwuser_fn_NET](@TableName varchar(50), @TmwUser varchar(255) = NULL)
RETURNS @Table TABLE	(
	rowsec_rsrv_id int NOT NULL primary key
)

AS

BEGIN
	--This is the primary function called that retrieves all valid row level user assigments
	--In most places, a function named RowRestrictValidAssignments_(tablename)_fn is used that in turn calls this function.
	--Using the functions specific to each table allows sql server to pass exceptions, whereas if the table name is incorrect,
	--no error will occur
	
	--PTS 69940 JJF 20130619 - allow for optional passing in of user
	--DECLARE @tmwuser 		varchar(255)
	--END PTS 69940 JJF 20130619 - allow for optional passing in of user
	DECLARE @rst_id int

	SELECT	@rst_id = rst.rst_id
	FROM	RowSecTables rst
	WHERE	rst.rst_table_name = @TableName
	--PTS 53255 JJF 20101029 - permits function to work ok in an inner join
	IF NOT EXISTS	(	SELECT	*
						FROM	Generalinfo
						WHERE	gi_name = 'RowSecurity'
								AND gi_string1 = 'Y'
					) BEGIN
		--Row Security not enabled
		INSERT	@table (rowsec_rsrv_id)
		SELECT	0
	END
	ELSE IF NOT EXISTS	(	SELECT	*
						FROM	RowSecColumns rsc
								INNER JOIN RowSecTables rst on rst.rst_id = rsc.rst_id
						WHERE	rst.rst_id = @rst_id
								AND rsc.rsc_sequence > 0
								AND rst.rst_enabled = 1
					) BEGIN
		--Security not set up on this table.  Return a wildcard indicator
		INSERT	@table (rowsec_rsrv_id)
		SELECT	0
	
	END
	ELSE BEGIN
		--PTS 69940 JJF 20130619 - allow for optional passing in of user
		IF @TmwUser IS NULL BEGIN
			EXEC	@tmwuser = dbo.gettmwuser_fn
		END
		--EXEC	@tmwuser = dbo.gettmwuser_fn
		--END PTS 69940 JJF 20130619 - allow for optional passing in of user
		
		INSERT	@table (rowsec_rsrv_id)
		SELECT	DISTINCT rsrcv.rsrv_id
		FROM	RowSecRowColumnValues rsrcv
				RIGHT JOIN	(	SELECT	rsua.rscv_id
								FROM	RowSecUserAssignments rsua
										--PTS 63035 JJF 20120516 not needed
										--INNER JOIN RowSecColumnValues rscv on rscv.rscv_id = rsua.rscv_id
										--INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id
								--PTS 63035 JJF 20120516
								--WHERE	usr_userid = @tmwuser
								--		AND rsc.rst_id = @rst_id
								WHERE	(	(	rsua.rsua_idtype = 'U'
												AND rsua.usr_userid = @tmwuser
											)
											OR
											(	--rsua.rsua_wildcard <> 1 
												rsua.rsua_idtype = 'G'
												AND rsua.usr_userid in	(	SELECT	grpasgn.grp_id
																			FROM	ttsgroupasgn grpasgn
																			WHERE	grpasgn.usr_userid = @tmwuser
																		)
											)
										)
										--AND rsc.rst_id = @rst_id
										AND rsua.rst_id = @rst_id
										
								UNION	--expand unknowns


								SELECT	rscv.rscv_id
								FROM	RowSecColumnValues rscv 
										INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id
								WHERE	rsc.rst_id = @rst_id
										AND rsc.rsc_selected = 1
										AND EXISTS	(	SELECT	*
														FROM	RowSecUserAssignments rsua_inner1
																INNER JOIN RowSecColumnValues rscv_inner1 on rsua_inner1.rscv_id = rscv_inner1.rscv_id
														WHERE	rscv_inner1.rsc_id = rsc.rsc_id
																AND rscv_inner1.rscv_value = rsc.rsc_unknown_value
																AND (	(	rsua_inner1.rsua_idtype = 'U'
																			AND rsua_inner1.usr_userid = @tmwuser
																		)
																		OR
																		(	rsua_inner1.rsua_idtype = 'G'
																			AND rsua_inner1.usr_userid in	(	SELECT	grpasgn.grp_id
																												FROM	ttsgroupasgn grpasgn
																												WHERE	grpasgn.usr_userid = @tmwuser
																											)
																		)
																	)
																AND NOT EXISTS	(	SELECT	*
																					FROM	RowSecUserAssignments rsua_inner2
																							INNER JOIN RowSecColumnValues rscv_inner2 on rsua_inner2.rscv_id = rscv_inner2.rscv_id
																					WHERE	rscv_inner2.rsc_id = rsc.rsc_id
																							AND rscv_inner2.rscv_value <> rsc.rsc_unknown_value
																							AND	(	(	rsua_inner2.usr_userid = @tmwuser
																										AND rsua_inner2.rsua_idtype = 'U'
																									)
																									OR
																									(	rsua_inner2.rsua_idtype = 'G'
																										AND rsua_inner2.usr_userid in	(	SELECT	grpasgn.grp_id
																																			FROM	ttsgroupasgn grpasgn
																																			WHERE	grpasgn.usr_userid = @tmwuser
																																		)
																									)
																								)
																					)
													)



								) rsua on rsrcv.rscv_id = rsua.rscv_id
				WHERE 	rsrcv.rsrv_id IS NOT NULL
				GROUP BY rsrcv.rsrv_id
				HAVING	count(*) = (	SELECT	MAX(rsc_sequence)
										FROM	RowSecColumns rsc_inner
										WHERE	rsc_inner.rst_id = @rst_id
									)
		
		
		
	END
	
	RETURN 

	
END


GO
GRANT REFERENCES ON  [dbo].[RowRestrictValidAssignments_for_tmwuser_fn_NET] TO [public]
GO
GRANT SELECT ON  [dbo].[RowRestrictValidAssignments_for_tmwuser_fn_NET] TO [public]
GO
