SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  FUNCTION [dbo].[RowSecurity_Unsecured_fn_NET](@TableName varchar(50), @TmwUser varchar(255) = NULL)
RETURNS @Table TABLE	(
	IsUnsecured int NOT NULL primary key
)

AS

BEGIN
    --Returns null if table secured, single row of 1 when no security
    --For use in LEFT OUTER JOIN scenarios where the presence of a row indicates row security not enabled for table
    --To be used along with RowSecurity_Secured_fn
    --Example:
    --FROM  orderheader oh WITH (NOLOCK) 
    --	   LEFT OUTER JOIN dbo.RowSecurity_SecuredRowValues_fn('orderheader', null) rssrv ON (oh.rowsec_rsrv_id = rssrv.rowsec_rsrv_id)
    --	   LEFT OUTER JOIN dbo.RowSecurity_Unsecured_fn_NET('orderheader', null) rsu ON (rsu.IsUnsecured = 1)
    --WHERE (rssrv.rowsec_rsrv_id > 0 or rsu.IsUnsecured = 1)	

	DECLARE @rst_id int

	IF NOT EXISTS	(   SELECT  *
				    FROM	  Generalinfo
				    WHERE	  gi_name = 'RowSecurity'
						  AND gi_string1 = 'Y'
					) BEGIN
		--Row Security not enabled
		INSERT	@table (IsUnsecured)
		SELECT	1

		RETURN
	END

	SELECT	@rst_id = rst.rst_id
	FROM	  	RowSecTables rst
	WHERE	rst.rst_table_name = @TableName

	IF NOT EXISTS	(   SELECT  *
				    FROM	  RowSecColumns rsc
						  INNER JOIN RowSecTables rst on rst.rst_id = rsc.rst_id
				    WHERE	  rst.rst_id = @rst_id
						  AND rsc.rsc_sequence > 0
						  AND rst.rst_enabled = 1
				) BEGIN
		--Security not set up on this table.  Return not enabled
		INSERT	@table (IsUnsecured)
		SELECT	1
	END
	RETURN 
END

GO
GRANT REFERENCES ON  [dbo].[RowSecurity_Unsecured_fn_NET] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecurity_Unsecured_fn_NET] TO [public]
GO
