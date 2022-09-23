SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_Comentarios_cfdi_orden] @orden varchar(50)
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	
	BEGIN
	 select * from [dbo].[comentarios_cfdi_jr]  where cc_ord_hdrnumber = (select ord_hdrnumber 
					FROM invoiceheader 
					WHERE  ivh_hdrnumber = 
								(Select MAX(ivh_hdrnumber) from invoiceheader where ivh_mbnumber=
																			(Select ivh_mbnumber FROM invoiceheader WHERE ord_hdrnumber = @orden)))
	 union
	  select * from [dbo].[comentarios_cfdi_jr]  where cc_ord_hdrnumber = @orden

	END
		

END



GO
