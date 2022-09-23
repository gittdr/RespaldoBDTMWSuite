SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspGuardarPaginaTipoUsuario]
@iidtipousuario int,
@iidpagina int
as
begin
declare @cantidad int
select @cantidad = count(*)
from PaginaTipoUsuario
where IIDTIPOUSUARIO=@iidtipousuario and IIDPAGINA = @iidpagina

if @cantidad=0
insert into PaginaTipoUsuario(IIDPAGINA,IIDTIPOUSUARIO,BHABILITADO)
values(@iidpagina,@iidtipousuario,1)
else
update PaginaTipoUsuario
set BHABILITADO=1
where IIDTIPOUSUARIO=@iidtipousuario and IIDPAGINA = @iidpagina
end
GO
