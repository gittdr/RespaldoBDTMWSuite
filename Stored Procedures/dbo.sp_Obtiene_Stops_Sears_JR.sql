SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--  exec sp_Obtiene_Stops_Sears_JR '06-01-2018', '09-30-2018'

CREATE  PROCEDURE [dbo].[sp_Obtiene_Stops_Sears_JR] @as_billto as varchar(10), @adt_Fechainicial as date, @adt_Fechafinal as date
AS

DECLARE	
	@V_NoOrden		 Integer,
	@Vi_secuencia_P	 Integer,
	@Vi_secuencia_D	 Integer,
	@Vi_stop_P	 Integer,
	@Vi_stop_D	 Integer,
	@Vs_Id_Cmp_P Varchar(8),
	@Vs_Nom_Cmp_P Varchar(100),
	@Vs_Cd_Cmp_P Varchar(30),
	@Vs_Id_Cmp_D Varchar(8),
	@Vs_Nom_Cmp_D Varchar(100),
	@Vs_Cd_Cmp_D Varchar(30),
	@dt_fecini	 datetime,
	@dt_fecfin	 datetime,
	@ds_fecini	 varchar(16),
	@ds_fecfin	 varchar(16)


DECLARE @TT_ordenes TABLE(
		 TT_NoOrden Integer Not null,
		 TT_idcmp_P varchar (8),
		 TT_Nomcmp_P varchar(100),
		 TT_Cdcmp_p  varchar(30),
		 TT_idcmp_D varchar (8),
		 TT_Nomcmp_D varchar(100),
		 TT_Cdcmp_D  varchar(30)		 
		 )

SET NOCOUNT ON
select @ds_fecini = cast( @adt_Fechainicial as varchar(10))
select @ds_fecfin = cast( @adt_Fechafinal   as varchar(10))
select @ds_fecini = @ds_fecini + ' 00:00'
select @ds_fecfin = @ds_fecfin + ' 23:59'

select @dt_fecini = CONVERT(DateTime,@ds_fecini)
select @dt_fecfin = convert(DateTime,@ds_fecfin)


--print @dt_fecini 
--print @dt_fecfin


BEGIN --1 Principal


-- Llena la tabla temporal de ordenes de sears.
INSERT Into @TT_Ordenes(TT_NoOrden)
		select ord_hdrnumber from orderheader where ord_status = 'CMP' and ord_billto = @as_billto and ord_startdate between @adt_Fechainicial and @adt_Fechafinal  

-- Si hay movimientos en la tabla continua
	If Exists ( Select count(*) From  @TT_Ordenes )
	BEGIN --3 Si hay movimientos de posiciones
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Ordenes_Cursor CURSOR FOR 
		SELECT TT_NoOrden
		FROM @TT_Ordenes 
	
		OPEN Ordenes_Cursor 
		FETCH NEXT FROM Ordenes_Cursor INTO @V_NoOrden

		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3
				
			--obtiene el primer stop del pick up
			select @Vi_secuencia_P = min(stp_mfh_sequence) from stops where ord_hdrnumber = @V_NoOrden  and stp_type = 'PUP' 

			select @Vi_stop_P = stp_number from stops where ord_hdrnumber = @V_NoOrden  and stp_type = 'PUP' and stp_mfh_sequence = @Vi_secuencia_P

			select @Vs_Id_Cmp_P = stp.cmp_id, @Vs_Cd_Cmp_P = cty.cty_nmstct, @Vs_Nom_Cmp_P = cmp.cmp_name from stops as stp , city as cty, company as cmp 
			where ord_hdrnumber = @V_NoOrden and stp_city = cty_code and stp.cmp_id = cmp.cmp_id  and stp.stp_number = @Vi_stop_P
			 
	
			-- obtiene el ultimo DROP que no sea igual a la compañia del primer pickup
			select @Vi_secuencia_D = max(stp_mfh_sequence) from stops where ord_hdrnumber = @V_NoOrden  and stp_type = 'DRP' and cmp_id <> 'SEARSATZ'

			select @Vi_stop_D = stp_number from stops where ord_hdrnumber = @V_NoOrden  and stp_type = 'DRP' and stp_mfh_sequence = @Vi_secuencia_D

			select @Vs_Id_Cmp_D = stp.cmp_id, @Vs_Cd_Cmp_D = cty.cty_nmstct, @Vs_Nom_Cmp_D = cmp.cmp_name from stops as stp , city as cty, company as cmp 
			where ord_hdrnumber = @V_NoOrden and stp_city = cty_code and stp.cmp_id = cmp.cmp_id  and stp.stp_number = @Vi_stop_D


			Update @TT_ordenes Set 
				TT_idcmp_P	= @Vs_Id_Cmp_P,
				TT_Nomcmp_P = @Vs_Nom_Cmp_P,
				TT_Cdcmp_p  = @Vs_Cd_Cmp_P,
				TT_idcmp_D  = @Vs_Id_Cmp_D,
				TT_Nomcmp_D = @Vs_Nom_Cmp_D,
				TT_Cdcmp_D	= @Vs_Cd_Cmp_D
		 Where TT_NoOrden	= @V_NoOrden
			

		FETCH NEXT FROM Ordenes_Cursor INTO @V_NoOrden

	END --3 curso de los movimientos 
	CLOSE Ordenes_Cursor 
	DEALLOCATE Ordenes_Cursor 
END -- 2 si hay movimientos del RC

 select * from @TT_ordenes

END --1 Principal
GO
