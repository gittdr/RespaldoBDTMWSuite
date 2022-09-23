SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_obtener_Invoice_header] (@leg varchar(1000))
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
		select ivh_invoicenumber from invoiceheader where ivh_hdrnumber = @leg
END
GO
