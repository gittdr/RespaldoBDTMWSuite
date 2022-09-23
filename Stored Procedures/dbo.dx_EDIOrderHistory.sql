SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_EDIOrderHistory]
	@p_OrderNumber VARCHAR(30),
	@p_Direction VARCHAR(4),
	@p_OrdHdrNumber VARCHAR(12)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIOrderHistory

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

 DECLARE @ord_hdrnumber int
 
 SELECT @ord_hdrnumber = ord_hdrnumber
 FROM  orderheader
 WHERE ord_hdrnumber = @p_OrdHdrNumber
 
	IF @p_Direction = 'ASC' 
		BEGIN
			SELECT 
				dx_ident, dx_importid, dx_sourcename,dx_sourcedate, dx_actiondate, dx_hist_seq, 
				dx_origin, dx_command, dx_commandstring, dx_returncode, dx_orderhdrnumber, 
				dx_ordernumber , dx_docnumber 
			FROM 
				dx_History 
			WHERE 
				dx_ordernumber = @p_OrderNumber
				AND dx_orderhdrnumber = @ord_hdrnumber
			ORDER BY
					dx_hist_seq ASC
		END
	ELSE
		BEGIN
			SELECT 
				dx_ident, dx_importid, dx_sourcename,dx_sourcedate, dx_actiondate, dx_hist_seq, 
				dx_origin, dx_command, dx_commandstring, dx_returncode, dx_orderhdrnumber, 
				dx_ordernumber , dx_docnumber 
			FROM 
				dx_History 
			WHERE 
				dx_ordernumber = @p_OrderNumber
				AND dx_orderhdrnumber = @ord_hdrnumber
			ORDER BY
					dx_hist_seq DESC
		END



GO
GRANT EXECUTE ON  [dbo].[dx_EDIOrderHistory] TO [public]
GO
