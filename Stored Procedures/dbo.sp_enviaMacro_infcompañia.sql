SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--exec sp_enviaMacro_infcompañia 'SAYER', 926
--drop proc  [dbo].[sp_enviaMacro_infcompañia] 
CREATE PROCEDURE [dbo].[sp_enviaMacro_infcompañia]  @compañia VARCHAR(10), @unidad varchar(8)
AS
BEGIN --1 Principal

--Valida que la unidad ya este en la tabla NWVehicles...
If Exists (select displayName from QSP..NWVehicles where displayName = @unidad )
	Begin -- 1.1
		--Valida que la compañia exista...
				If Exists (select cmp_name from company where cmp_id = @compañia )
				BEGIN --2 existe la compañia
					-- Inserta el mensaje en la tabla de envia mensajes con la inf de la compañia
						INSERT Into QSP..NWEnviaMensajes (cuenta, unidad, macro, mensaje, detmacro,fechainsersion)
						(SELECT 5,@unidad, null, '**RESP SOLICITUD DATOS COMPANIA:'+CMP_NAME+' **DIRECCION: '+CMP_adDress1+''+ISNULL(cMP_aDDRESS2,'') +' CONTACTO:'+ISNULL(CMP_CONTACT,'')
							+'**TELEFONO:'+ISNULL(CMP_PRIMARYPHONE,'') 
							+' **INSTRUCCIONES: ' + cast((ISNULL(CMP_DIRECTIONS,''))AS VARCHAR (50)), null, getdate() 
							FROM COMPANY
							WHERE CMP_id = @compañia)

						select cmp_name, 'Macro enviada', @unidad from tmwSuite..company  where CMP_id = @compañia			
				END	--2 existe la compañia
				select @compañia, 'No existe la compañia, macro no enviada' from tmwSuite..company  where CMP_id = 'TDRMEXIC'
	END -- 1.1 valida si existe la unidad
		select @unidad, 'No tiene sistema QFS, macro no enviada ' from tmwSuite..tractorprofile  where trc_number = @unidad

END --1 Principal



--select displayName from QSP..NWVehicles where displayName = @unidad
GO
