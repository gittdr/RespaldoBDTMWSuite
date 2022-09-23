SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dx_OrderInformation]
	@p_OrderHeaderNumber INT,
	@p_OrderNumber VARCHAR(30)
AS

/*******************************************************************************************************************  
  Object Description:
  dx_OrderInformation

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  04/05/2016   John Richardson               Updated existence check per TMW code standards
********************************************************************************************************************/

	SELECT 
		(SELECT gi_string1 FROM generalinfo WHERE gi_name='SCAC') AS Receiver,
		(SELECT dx_trpid FROM
			(
			SELECT TOP 1(dx_sourcedate), dx_trpid FROM dx_archive_header
			WHERE dx_ordernumber = @p_OrderNumber
			AND DX_orderhdrnumber = @p_OrderHeaderNumber
			) AS OrderInfo
		) AS Sender,
		(SELECT ord_startdate FROM orderheader WHERE ord_hdrnumber = @p_OrderHeaderNumber) AS OrderStartDate



GO
GRANT EXECUTE ON  [dbo].[dx_OrderInformation] TO [public]
GO
