SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--select mt_type,mt_origintype,mt_origin,mt_destinationtype,mt_destination,mt_miles,mt_hours,mt_updatedby,mt_updatedon,timestamp,mt_verified,mt_old_miles,mt_source,mt_Authorized,mt_AuthorizedBy,mt_AuthorizedDate,mt_route,mt_identity,mt_haztype,mt_tolls_cost,mt_verified_date,mt_lastused 
--from mileagetable where mt_type = 7 and mt_origin = 'SAYACA' and   mt_destination = 'SAYER'

--  exec sp_act_kms_sayer_jr 'SAYJUA', 'SAYER',1633,4285.00
--  exec sp_act_kms_sayer_jr 'SAYER', 'SAYJUA',1633,4285.00


create PROCEDURE [dbo].[sp_act_kms_sayer_jr] @as_cmporigen as varchar(10), @as_cmpdestino as varchar(10), @af_kms as dec(6,2), @am_casetas as money
AS

DECLARE	
	@vi_existekms	 Integer,
	@Vi_existecmpO	 Integer,
	@Vi_existecmpD	 Integer,
	@vi_bandera		 integer


SET NOCOUNT ON


BEGIN --1 Principal
select @vi_bandera	 = 0
	Begin Tran

	-- Revisamos que las compañias sean validas
	select @Vi_existecmpO = count(*) from company where cmp_id = @as_cmporigen
	IF @Vi_existecmpO = 0
	begin
		
		insert actualiza_kms_sayer_log (origen, destino, motivo)
		values (@as_cmporigen, @as_cmpdestino,'Origen no dado de alta' )
		select @vi_bandera = 1
	end

	select @Vi_existecmpD = count(*) from company where cmp_id = @as_cmpdestino
	IF @Vi_existecmpD = 0
	begin
		
		insert actualiza_kms_sayer_log (origen, destino, motivo)
		values (@as_cmporigen, @as_cmpdestino,'Destino no dado de alta' )
		select @vi_bandera = 1
	end


	if @vi_bandera = 0
	BEGIN -- compañias
		-- revisa si existe o no el kms
		select @vi_existekms = count(*) from mileagetable where mt_type = 7 and mt_origin = @as_cmporigen and   mt_destination = @as_cmpdestino

		-- Si hay kms registrados en la tabla Actualiza
			If @vi_existekms > 0
				BEGIN --3 Se hace un update
					Update mileagetable Set mt_miles = @af_kms, mt_tolls_cost = @am_casetas  where mt_type = 7 and mt_origin = @as_cmporigen and   mt_destination = @as_cmpdestino

					insert actualiza_kms_sayer_log (origen, destino, motivo) values (@as_cmporigen, @as_cmpdestino,'Kms Actualizados' )

				END
			ELSE
				BEGIN
					insert mileagetable (mt_type,mt_origintype,mt_origin,mt_destinationtype,mt_destination,mt_miles,mt_hours,mt_updatedby,mt_updatedon, mt_tolls_cost) 
					VALUES (7, 'O', @as_cmporigen, 'O',@as_cmpdestino,@af_kms,(@af_kms/50),'JRSAYER', getdate(),@am_casetas)

					
					insert actualiza_kms_sayer_log (origen, destino, motivo) values (@as_cmporigen, @as_cmpdestino,'Kms Insertados' )
				END -- 2 si hay movimientos del RC
	END -- Fin compañias
				commit tran;

END --1 Principal

GO
