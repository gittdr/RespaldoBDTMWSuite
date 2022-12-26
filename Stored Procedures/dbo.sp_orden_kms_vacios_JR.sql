SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Procedimiento para leer las ordenes y obtener los kms de cargado y de vacio

-- exec sp_orden_kms_vacios_JR

CREATE PROCEDURE [dbo].[sp_orden_kms_vacios_JR]
AS
DECLARE	
	@V_idactividad 		uniqueidentifier, 
	@linumorden			Int,
	@limovimiento		Int,
	@li_i				Int,
	@ld_monto			float,
	@li_kmscargados		Int,
	@li_kmstotales		Int,
	@li_kmsvacios		Int,
	@err				Int,
	@v_bandera			Int

DECLARE @TTOrdenes_cmp TABLE(
		tt_noorden      integer not null,
		tt_status		Varchar(6) Null,
		tt_monto		float null)

BEGIN --1 Principal
-- Inserta en la tabla temporal la información que haya en la de actividades...
INSERT Into @TTOrdenes_cmp
Select  ord_hdrnumber,ord_status,ord_totalcharge
	From	orderheader A
	left join orden_kms_orden_Domo B
	on A.ord_hdrnumber = B.orden
	Where B.orden is null and 
	A.ord_hdrnumber in (select ord_hdrnumber from orderheader where ord_bookdate > DATEADD(day, -5, GETDATE())  and ord_status = 'CMP')



   --Select  ord_hdrnumber,ord_status,ord_totalcharge
	--From	orderheader
	--Where ord_bookdate > '01-01-2010' and ord_status = 'CMP'
		-- Si hay movimientos en la tabla continua
		If Exists ( Select count(*) From  @TTOrdenes_cmp )
		BEGIN --2 Si hay ordenes
				DECLARE tto_Cursor CURSOR FOR 
				SELECT tt_noorden,tt_monto
				FROM   @TTOrdenes_cmp
			
				OPEN tto_Cursor 
				FETCH NEXT FROM tto_Cursor INTO  @linumorden, @ld_monto
				WHILE @@FETCH_STATUS = 0 
			BEGIN --3 del cursor ordenes
			--inserta en la tabla fisica

			-- consulta pasa obtener los kilometros
				select @li_kmscargados = sum( stp_ord_mileage ) , @li_kmstotales = sum(stp_lgh_mileage) ,  @li_kmsvacios = (sum(stp_lgh_mileage) - sum( stp_ord_mileage ) ) from stops 
				where lgh_number in ( select lgh_number from legheader where ord_hdrnumber = @linumorden)

				
			-- Ingresa los valores de los kms en la tabla fija
			insert into orden_kms_orden_Domo(orden, kms_totales,kms_cargados,kms_vacios,netototal)
			values(@linumorden,@li_kmstotales,@li_kmscargados,@li_kmsvacios,@ld_monto)

			FETCH NEXT FROM tto_Cursor INTO  @linumorden, @ld_monto
			END --3 curso de los movimientos 
				CLOSE tto_Cursor 
				DEALLOCATE tto_Cursor 
		END -- 2 si hay mensajes
END --1 Principal
GO
