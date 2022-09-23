SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[uspGuardarPagina]
@iidpagina int,
@mensaje varchar(100),
@controlador varchar(100),
@accion  varchar(100)
as
begin
   --insertar
   if @iidpagina=0
   begin
     insert into Pagina(MENSAJE,CONTRALADOR,ACCION,BHABILITADO)
	 values(@mensaje,@controlador,@accion,1)
   end
   --actualizar
   else
   begin
        update Pagina
		set MENSAJE=@mensaje,CONTRALADOR=@controlador,ACCION=@accion
		where IIDPAGINA=@iidpagina
   end

end
GO
