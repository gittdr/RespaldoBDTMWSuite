SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarTipoUsuario]
@iidtipousuario int,
@nombre varchar(100),
@descripcion varchar(300)
as 
begin

if @iidtipousuario=0
begin
insert into TipoUsuario(NOMBRE,DESCRIPCION,BHABILITADO)
values(@nombre,@descripcion,1)
return @@identity
end
else 

update TipoUsuario
set NOMBRE=@nombre,DESCRIPCION=@descripcion
where IIDTIPOUSUARIO=@iidtipousuario
end
GO
