SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*******************************************************************************************************************  
  Object Description:
  This function returns a table containing the lowest-level invoice header status for each of the given orders. If a 
  given order has no invoice, there will be no row for that order in the result table.

  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  -------------  ----------------------------------------
  04/11/2017   Cory Sellers     NSUITE-201079  Initial Release

********************************************************************************************************************/

CREATE FUNCTION [dbo].[GetMininumInvoiceHdrStatusesForOrders_fn] (
@orderHdrNumbers TableVarOrdHdrNumberList READONLY
) 
RETURNS @invoiceHdrStatuses TABLE(
	ordHdrNumber int,
	minimumInvoiceStatus varchar(6))		
AS 
BEGIN

	INSERT INTO
		@invoiceHdrStatuses
	SELECT
		ord_hdrnumber, MIN(ivh_invoicestatus)
	FROM
		invoiceheader
	JOIN
		@orderHdrNumbers ordNums
	ON
		ordNums.orderHdrNumber = invoiceheader.ord_hdrnumber
	GROUP BY
		ord_hdrnumber

	RETURN
END

GO
GRANT SELECT ON  [dbo].[GetMininumInvoiceHdrStatusesForOrders_fn] TO [public]
GO
