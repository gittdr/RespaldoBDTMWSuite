SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_filtra_facturas]
     (
      @StoreID int
     )
RETURNS table
AS
RETURN (

	select ord_number  
	from invoiceheader 
	where ivh_mbnumber = @StoreID
       )

GO
