SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

--PTS 63035 JJF 20120517 - add group/id type
CREATE PROCEDURE [dbo].[d_RowSecUserAssignments_sp] (
					@IDType char(1),
					@UserID char(20)
				)
				
AS

	
	SELECT	rst_id,
			rst_description,
			rsc_id,
			rsc_column_name,
			rsc_description,
			rsc_sequence,
			rscv_id,
			rscv_value,
			rscv_description,
			Is_Unknown,
			rsua_id,
			@UserID as usr_userid,	
			@IDType as idtype,
			CASE ISNULL(rsua_id,0)
				WHEN 0 THEN 0
				ELSE 1
			END as Checked,
			0 as Effective
	FROM	(
				SELECT	rst.rst_id,
						rst.rst_description,
						rsc.rsc_id,
						rsc.rsc_column_name,
						isnull(rsc.rsc_description, rsc.labeldefinition_values) as rsc_description,
						rsc.rsc_sequence,
						rscv.rscv_id,
						rscv.rscv_value,
						rscv.rscv_description,
						CASE rscv.rscv_value
							WHEN isnull(rsc.rsc_unknown_value, 'UNK') THEN 1
							ELSE 0
						END as Is_Unknown,
						rsua_id =	(	SELECT	rsua_inner.rsua_id
										FROM	RowSecUserAssignments rsua_inner
												INNER JOIN RowSecColumnValues rscv_inner on rsua_inner.rscv_id = rscv_inner.rscv_id
										WHERE	rscv_inner.rscv_id = rscv.rscv_id
												and rsua_inner.usr_userid = @UserID
												and rsua_inner.rsua_idtype = @IDType
									)
										
				FROM	RowSecTables rst 
						INNER JOIN RowSecColumns rsc on (rst.rst_id = rsc.rst_id)
						LEFT OUTER JOIN RowSecColumnValues rscv on (rscv.rsc_id = rsc.rsc_id)
				WHERE	rsc.rsc_sequence > 0
			) innerselect
GO
GRANT EXECUTE ON  [dbo].[d_RowSecUserAssignments_sp] TO [public]
GO
