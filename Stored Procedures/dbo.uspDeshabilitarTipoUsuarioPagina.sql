SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[uspDeshabilitarTipoUsuarioPagina]
@iidtipousuario int
as 
begin
update PaginaTipoUsuario
set BHABILITADO=0
where IIDTIPOUSUARIO=@iidtipousuario
end
GO
