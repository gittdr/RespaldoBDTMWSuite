SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_EDIRecordKeys]
	@p_OrderNumber VARCHAR(50),
	@p_OrdHdrNumber VARCHAR(12)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIRecordKeys

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	DECLARE @v_OrderHdr INT
	/*SELECT @v_OrderHdr = MAX(dx_orderhdrnumber)
	  FROM dx_archive (NOLOCK)
	 WHERE dx_ordernumber = @p_OrderNumber
	*/
	SELECT @v_OrderHdr = ord_hdrnumber
	FROM	orderheader 
	WHERE	ord_hdrnumber = @p_OrdHdrNumber
	
	SELECT  
		DISTINCT dx_sourcedate, 
		dx_Importid, 
		dx_docnumber 
	FROM 
		dx_archive 
	WHERE dx_ordernumber =  @p_OrderNumber
	  AND dx_orderhdrnumber = @v_OrderHdr
	ORDER BY dx_sourcedate DESC

GO
GRANT EXECUTE ON  [dbo].[dx_EDIRecordKeys] TO [public]
GO
