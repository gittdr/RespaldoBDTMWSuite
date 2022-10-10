SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[sl_archivos_PISA](@accion varchar(20), @idRuta varchar(20))
as

BEGIN
	IF(@accion = '1')
	BEGIN
				-- aqui se leen los archivos
			SELECT 'PISA' as Usuario,idEnvio from TESTPISAUPLOAD
			  where idenvio not in (select narchivo from RCSAYER where usuario = 'PISA')  and idenvio = '6422762'
			  group by idEnvio
	END
	ELSE IF(@accion = '2')
	BEGIN
				-- aqui se leen los archivos
			SELECT top 1 'PISA' as Usuario, [idenvio], [rfcvendedora],[razonsocialremitente], [rfccliente], [razonsocialcliente], [secuencia]
			,LEFT([fechahorallegada],4) +'/'+ RIGHT(LEFT([fechahorallegada],6),2) +'/'+  RIGHT(LEFT([fechahorallegada],8),2)+' '+RIGHT(LEFT([fechahorallegada],11),2)+':'+RIGHT(LEFT([fechahorallegada],13),2)+':'+RIGHT(LEFT([fechahorallegada],15),2) as fechahorallegada
				,LEFT([fechahorasalida],4) +'/'+ RIGHT(LEFT([fechahorasalida],6),2) +'/'+  RIGHT(LEFT([fechahorasalida],8),2)+' '+RIGHT(LEFT([fechahorasalida],11),2)+':'+RIGHT(LEFT([fechahorasalida],13),2)+':'+RIGHT(LEFT([fechahorasalida],15),2) as fechahorasalida
				,[pesoenkg], [numpiezas], [unidadpeso], [secuenciaorigen], [municipio1], 
				[calle1], [estado1], [pais1], [colonia1], [codigopostal1], [secuenciadestino], [municipio2], [calle2],
				[estado2], [pais2], [colonia2], [codigopostal2]
			 from TESTPISAUPLOAD
			  where idenvio = @idRuta
			  
	END
	ELSE IF(@accion = '3')
	BEGIN
				-- aqui se leen los archivos
			SELECT Distinct 'PISA' as Usuario, [idenvio], [rfcvendedora],[razonsocialremitente], [rfccliente], [razonsocialcliente], [secuencia]
				,LEFT([fechahorallegada],4) +'/'+ RIGHT(LEFT([fechahorallegada],6),2) +'/'+  RIGHT(LEFT([fechahorallegada],8),2)+' '+RIGHT(LEFT([fechahorallegada],11),2)+':'+RIGHT(LEFT([fechahorallegada],13),2)+':'+RIGHT(LEFT([fechahorallegada],15),2) as fechahorallegada
				,LEFT([fechahorasalida],4) +'/'+ RIGHT(LEFT([fechahorasalida],6),2) +'/'+  RIGHT(LEFT([fechahorasalida],8),2)+' '+RIGHT(LEFT([fechahorasalida],11),2)+':'+RIGHT(LEFT([fechahorasalida],13),2)+':'+RIGHT(LEFT([fechahorasalida],15),2) as fechahorasalida
				,[codigopostal2] --CAST([fechahorasalida] AS DATE)
			 from TESTPISAUPLOAD
			  where idenvio = @idRuta
			  
	END
	ELSE IF(@accion = '4')
	BEGIN
				-- aqui se leen los archivos
			SELECT claveprodservicio,secuencia
			 from TESTPISAUPLOAD
			  where idenvio = @idRuta
			  
	END
	ELSE IF(@accion = '5')
	BEGIN
				-- aqui se leen los archivos
			SELECT claveprodservicio,claveunidad, numpiezas,claveunidad,'',descripcion,unidadpeso,'',pesoenkg, secuencia
			 from TESTPISAUPLOAD
			  where idenvio = @idRuta
			
	END
	
END



GO
