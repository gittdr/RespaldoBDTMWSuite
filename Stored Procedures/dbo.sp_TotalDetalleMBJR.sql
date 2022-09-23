SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_TotalDetalleMBJR]  @NumeroMB integer

AS
	SET nocount on
	select Isnull(sum(ivd_charge),0) from invoicedetail where ivh_hdrnumber in (select ivh_invoicenumber from invoiceheader where ivh_mbnumber =@NumeroMB and left(ivh_invoicenumber,1) <> 'S' );
RETURN 
GO
