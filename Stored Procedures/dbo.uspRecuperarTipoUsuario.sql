SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspRecuperarTipoUsuario]
@iidtipousuario int
as
begin
select * from TipoUsuario
where IIDTIPOUSUARIO=@iidtipousuario

select IIDPAGINA from PaginaTipoUsuario
where IIDTIPOUSUARIO=@iidtipousuario and BHABILITADO=1
end
GO
