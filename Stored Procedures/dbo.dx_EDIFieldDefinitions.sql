SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIFieldDefinitions]
	@p_OrderImportID VARCHAR(8),
	@p_RecordTypeName VARCHAR(8)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIFieldDefinitions

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	SELECT 
		dx_ident,dx_importid,dx_recordtype_name,dx_fielddefstart,dx_fielddeflength,
		dx_fielddeftype,dx_fielddefname, dx_sourcefield , dx_dbtype
	FROM 
		dx_FieldDefinitions 
	WHERE 
			(dx_importid = @p_OrderImportID) 
		AND 
			(dx_recordtype_name LIKE @p_RecordTypeName + '%' ) 
	ORDER BY 
		dx_fielddefstart  ASC
GO
GRANT EXECUTE ON  [dbo].[dx_EDIFieldDefinitions] TO [public]
GO
