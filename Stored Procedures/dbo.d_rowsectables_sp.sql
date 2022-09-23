SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_rowsectables_sp] 
				
AS BEGIN
	SELECT	rst.rst_id,   
			rst.rst_description,   
			rst.rst_table_name, 
			rst.rst_primary_key,  
			rst.rst_max_columns,
			rst.rst_enabled,
			rst.rst_applied,
			CASE rst.rst_applied
				WHEN 1 THEN
					CASE rst.rst_enabled
						WHEN 1 THEN 1
						ELSE 0
					END
				ELSE -1
			END as enablebutton,
			ColumnsSelected =	(	SELECT	count(*)
									FROM	RowSecColumns rsc
									WHERE	rsc.rst_id = rst.rst_id
											AND rsc.rsc_selected = 1
								),
			RowsToProcess = 0,
			RowsProcessed = 0,
			ProcessError = ''
			
			
	FROM RowSecTables rst 
END
GO
GRANT EXECUTE ON  [dbo].[d_rowsectables_sp] TO [public]
GO
