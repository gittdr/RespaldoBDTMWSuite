SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  FUNCTION [dbo].[RowSecurity_SecuredRowValues_fn_NET](@TableName varchar(50), @TmwUser varchar(255) = NULL)
RETURNS @Table TABLE	(
	rowsec_rsrv_id int NOT NULL primary key
)

AS

BEGIN
    --Function called that retrieves all valid row level user assigments
    --Returns NULL table if row security not enabled or not enabled for table
    --For use in LEFT OUTER JOIN scenarios where each row corresponds to an allowed rowsec_rsrv_id in secured tables.
    --To be used along with RowSecurity_Unsecured_fn
    --Example:
    --FROM  orderheader oh WITH (NOLOCK) 
    --	   LEFT OUTER JOIN dbo.RowSecurity_SecuredRowValues_fn_NET('orderheader', null) rssrv ON (oh.rowsec_rsrv_id = rssrv.rowsec_rsrv_id)
    --	   LEFT OUTER JOIN dbo.RowSecurity_Unsecured_fn('orderheader', null) rsu ON (rsu.IsUnsecured = 1)
    --WHERE (rssrv.rowsec_rsrv_id > 0 or rsu.IsUnsecured = 1)
	
	DECLARE @rst_id int

	IF NOT EXISTS	(	SELECT	*
						FROM	Generalinfo
						WHERE	gi_name = 'RowSecurity'
								AND gi_string1 = 'Y'
					) BEGIN
		--Row Security not enabled
		RETURN
	END

	SELECT @rst_id = rst.rst_id
	FROM	  RowSecTables rst
	WHERE  rst.rst_table_name = @TableName

	IF NOT EXISTS	(	SELECT	*
						FROM	RowSecColumns rsc
								INNER JOIN RowSecTables rst on rst.rst_id = rsc.rst_id
						WHERE	rst.rst_id = @rst_id
								AND rsc.rsc_sequence > 0
								AND rst.rst_enabled = 1
					) BEGIN
		--Security not set up on this table.  
	   RETURN	
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
GRANT REFERENCES ON  [dbo].[RowSecurity_SecuredRowValues_fn_NET] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecurity_SecuredRowValues_fn_NET] TO [public]
GO
