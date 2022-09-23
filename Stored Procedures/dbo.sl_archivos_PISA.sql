SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sl_archivos_PISA](@accion varchar(20))
as

BEGIN
	IF(@accion = '1')
	BEGIN
				-- aqui se leen los archivos
			INSERT INTO RCSAYER(usuario,narchivo)
			SELECT 'PISA' as Usuario,idEnvio from TESTPISAUPLOAD
			  where idenvio not in (select narchivo from RCSAYER where usuario = 'PISA')
			  group by idEnvio
	END

END



GO
