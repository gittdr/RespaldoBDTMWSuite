SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspFiltrarTipoUsuario]
@nombre varchar(100),
@descripcion varchar(300)
as
begin

if @nombre=''
select IIDTIPOUSUARIO,NOMBRE,DESCRIPCION
from TipoUsuario
where BHABILITADO=1
else
select IIDTIPOUSUARIO,NOMBRE,DESCRIPCION
from TipoUsuario
where BHABILITADO=1 and NOMBRE like '%'+@nombre+'%' or DESCRIPCION like '%'+@descripcion+'%' 

end
GO
