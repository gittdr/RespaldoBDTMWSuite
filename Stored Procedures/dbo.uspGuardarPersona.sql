SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarPersona]
@iidpersona int,
@nombre varchar(100),
@appaterno varchar(100),
@apmaterno varchar(100),
@correo varchar(100),
@direccion varchar(300),
@iidsexo int,
@numerotelefonico varchar(9),
@bempleado int,
@iidsucursal int
as 
begin

if @iidpersona=0
begin
insert into Persona(NOMBRE,APPATERNO,APMATERNO,CORREO,DIRECCION,IIDSEXO,BHABILITADO,NUMEROTELEFONICO,BEMPLEADO,IIDSUCURSAL)
values(@nombre,@appaterno,@apmaterno,@correo,@direccion,@iidsexo,1,@numerotelefonico,@bempleado,@iidsucursal)
return @@identity
end
else 

update Persona
set NOMBRE=@nombre,APPATERNO=@appaterno,APMATERNO=@apmaterno,CORREO=@correo,DIRECCION=@direccion,IIDSEXO=@iidsexo,NUMEROTELEFONICO=@numerotelefonico,BEMPLEADO=@bempleado,IIDSUCURSAL=@iidsucursal
where IIDPERSONA=@iidpersona
end
GO
