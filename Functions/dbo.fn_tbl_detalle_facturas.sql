SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create FUNCTION [dbo].[fn_tbl_detalle_facturas]
     (
     
     )
RETURNS table
AS
RETURN (

select * from VISTA_Fe_detail
       )

GO
