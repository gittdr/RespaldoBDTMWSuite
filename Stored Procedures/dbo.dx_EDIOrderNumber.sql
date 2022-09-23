SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  PROCEDURE [dbo].[dx_EDIOrderNumber]
	@p_OrderHeaderNumber VARCHAR(50)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_EDIOrderNumber

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

/* old code
	Select ord_refnum 
	FROM dbo.orderheader 
	WHERE ord_hdrnumber = @p_OrderHeaderNumber
*/

	DECLARE @v_ordhdr INT
	SELECT @v_ordhdr = ord_hdrnumber
	  FROM orderheader
	 WHERE ord_number = @p_OrderHeaderNumber
	IF ISNULL(@v_ordhdr, 0) > 0
	BEGIN
		IF (SELECT COUNT(1) FROM dx_archive_header WHERE dx_orderhdrnumber = @v_ordhdr AND dx_importid = 'dx_204') > 0
			SELECT TOP 1 dx_ordernumber
			  FROM dx_archive_header
			 WHERE dx_orderhdrnumber = @v_ordhdr
			   AND dx_importid = 'dx_204'
			   AND ISNULL(dx_ordernumber,'') > ''
			 ORDER BY dx_sourcedate DESC
		ELSE
		BEGIN
			IF (SELECT COUNT(1) FROM referencenumber where ref_table = 'orderheader' and ref_tablekey = @v_ordhdr and ref_sid = 'Y') > 0
				SELECT TOP 1 ref_number
				  FROM referencenumber
				 WHERE ref_table = 'orderheader'
				   AND ref_tablekey = @v_ordhdr
				   AND ref_sid = 'Y'
			ELSE
				SELECT ord_refnum
				  FROM orderheader
				 WHERE ord_hdrnumber = @p_OrderHeaderNumber
		END
	END

GO
GRANT EXECUTE ON  [dbo].[dx_EDIOrderNumber] TO [public]
GO
