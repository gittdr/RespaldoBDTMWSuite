SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspGuardarSucursal]
@iidsucursal int,
@nombre varchar(100),
@direccion varchar(300),
@fotosucursal varbinary(max),
@nombrefotosucursal varchar(100)
as
begin

if @iidsucursal=0
 insert into Sucursal(NOMBRE,DIRECCION,BHABILITADO,FOTOSUCURSAL,
 NOMBREFOTOSUCURSAL
 )
 values(@nombre,@direccion,1,@fotosucursal,@nombrefotosucursal)
else
update Sucursal
set NOMBRE=@nombre,DIRECCION=@direccion,
FOTOSUCURSAL=@fotosucursal,NOMBREFOTOSUCURSAL=@nombrefotosucursal
where IIDSUCURSAL=@iidsucursal

end
GO
