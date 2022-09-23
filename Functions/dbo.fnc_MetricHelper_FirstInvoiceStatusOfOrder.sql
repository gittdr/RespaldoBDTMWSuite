SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_FirstInvoiceStatusOfOrder]
	(@Ord_hdrnumber int)

RETURNS Varchar(6)
AS
BEGIN


Declare @Ivh_status Varchar(6)
Set @Ivh_status=NULL
IF @Ord_hdrnumber>0 
BEGIN
	Set @Ivh_status =(Select Min(ivh_invoicestatus) from invoiceheader (NOLOCK) where ord_hdrnumber=@Ord_hdrnumber)
END

Return @Ivh_status
--select * from paydetail

END
GO
