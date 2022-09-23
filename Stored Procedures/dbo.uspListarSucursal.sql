SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspListarSucursal]
as
begin
select IIDSUCURSAL,NOMBRE,DIRECCION
from Sucursal
where BHABILITADO=1

end
GO
