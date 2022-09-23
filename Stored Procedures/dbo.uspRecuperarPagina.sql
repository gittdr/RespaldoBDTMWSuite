SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspRecuperarPagina]
@iidpagina int
as
begin
select IIDPAGINA,MENSAJE, CONTRALADOR, ACCION
from Pagina
where IIDPAGINA=@iidpagina
end
GO
