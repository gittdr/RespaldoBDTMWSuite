SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltradoSucursal]
@nombresucursal varchar(100)
as
begin

if @nombresucursal=''
select IIDSUCURSAL,NOMBRE,DIRECCION
from Sucursal
where BHABILITADO=1
else
select IIDSUCURSAL,NOMBRE,DIRECCION
from Sucursal
where BHABILITADO=1 and NOMBRE like '%'+@nombresucursal+'%'

end
GO
