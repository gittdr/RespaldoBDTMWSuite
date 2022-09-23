SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fnc_MetricHelper_FirstInvoiceXferDateOfOrder]
	(@Ord_hdrnumber int)

RETURNS DateTime
AS
BEGIN


Declare @Ivh_xferDate DateTime
Set @Ivh_xferDate=NULL
IF @Ord_hdrnumber>0 
BEGIN
	Set @Ivh_xferDate =(Select Min(ivh_xferdate) from invoiceheader (NOLOCK) where ord_hdrnumber=@Ord_hdrnumber)
END

Return @Ivh_xferDate
--select * from invoiceheader

END
GO
