SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_get_invoice] (@rorder varchar(100))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
    select ivh_invoicenumber, ivh_billto, ivh_totalcharge from invoiceheader where ord_hdrnumber = @rorder
END
GO
