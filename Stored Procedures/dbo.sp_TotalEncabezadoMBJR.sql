SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[sp_TotalEncabezadoMBJR]  @NumeroMB integer

AS
	SET nocount on
	select isNull(sum(ivh_totalcharge),0) from invoiceheader where ivh_mbnumber = @NumeroMB;
RETURN 
GO
