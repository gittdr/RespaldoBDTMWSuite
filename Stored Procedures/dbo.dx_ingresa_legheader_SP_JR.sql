SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- Procedimiento para leer las invoices que estan en Ready to Print 
-- y 

--DROP PROCEDURE sp_ingresa_legheader_DX_JR
--GO

--exec sp_ingresa_legheader_DX_JR 570212

CREATE PROCEDURE [dbo].[dx_ingresa_legheader_SP_JR] @ai_NoOrden int, @as_Driver varchar(100),	@as_Unidad varchar(100),	@as_Rem1 varchar(100),
 @as_Lgh_type1 varchar (100)
AS
BEGIN 
DECLARE	
	@Vi_num_movimiento	 int,
	@Vi_legheader		 int,
	@Vi_stp_number_start int,
	@Vi_stp_number_end	 int,
	@Vi_stp_number		 int,
	@Vd_lgh_startdate	 datetime,
	@Vi_lgh_startcity	 int,
	@Vs_cmp_id_start	 varchar(100),
	@Vd_lgh_enddate		 datetime,
	@Vi_lgh_endcity		 int,
	@Vs_cmp_id_end		 varchar(100),
	@Vs_lgh_startstate	 varchar(100),
	@Vs_lgh_endstate	 varchar(100),
	@Vs_ord_billto		 varchar(100),
	@Vs_ord_revtype1	 varchar(100),
	@Vs_ord_revtype2	 varchar(100),
	@Vs_ord_revtype3	 varchar(100),
	@Vs_ord_revtype4	 varchar(100),
	@Vd_lgh_createdon	 datetime,
	@lgh_outstatus varchar(100)
	
SET NOCOUNT ON
		IF @as_Driver = '' 
			SELECT @as_Driver = 'UNKNOWN'
		IF @as_Unidad = '' 
			SELECT @as_Unidad = 'UNKNOWN'
		IF @as_Rem1 = '' 
			SELECT @as_Rem1   = 'UNKNOWN'
		IF @as_Lgh_type1 = '' 
			SELECT @as_Lgh_type1   = 'UNK'
		
		--SELECT @as_Driver	= ISNULL(@as_Driver,'UNKNOWN')
		--SELECT @as_Unidad	= ISNULL(@as_Unidad,'UNKNOWN')
		--SELECT @as_Rem1		= ISNULL(@as_Rem1,'UNKNOWN')
		
-- obtenemos el mov_number y demas datos de la orden

IF Exists (Select count(*) FROM orderheader WHERE ord_hdrnumber = @ai_NoOrden)
BEGIN
		select  @Vi_num_movimiento = mov_number, 
				@Vs_ord_billto	= ord_billto, 
				@Vs_ord_revtype1 = ord_revtype1, 
				@Vs_ord_revtype2 = ord_revtype2, 
				@Vs_ord_revtype3 = ord_revtype3, 
				@Vs_ord_revtype4 = ord_revtype4,
				@Vd_lgh_createdon = ord_bookdate,
				--@as_Driver = ord_driver1
				@as_Unidad = ord_tractor
				

		from orderheader where ord_hdrnumber = @ai_NoOrden

		SET @lgh_outstatus= 'AVL'
		-- Actualiza la tabla de orderheader
		IF (@as_Lgh_type1 in('FULL','SEN'))
		BEGIN 
			set @lgh_outstatus='PLN'
			update orderheader set ord_status = @lgh_outstatus where ord_hdrnumber = @ai_NoOrden
		END
		

		-- se recorre un cursor para actualizar los recursos en la tabla de stops y events
		-----------------------------------------------------------------------------------------
		--DECLARE stops_Cursor CURSOR FOR 
		--select	stp_number from stops where mov_number = @Vi_num_movimiento 
	
		--OPEN stops_Cursor 
		--FETCH NEXT FROM stops_Cursor INTO @Vi_stp_number
		--WHILE @@FETCH_STATUS = 0 
		--BEGIN --2 del cursor stops_Cursor 

		--	SELECT @Vi_stp_number
		--	Update event Set evt_driver1 = @as_Driver , evt_tractor = @as_Unidad , evt_trailer1 = @as_Rem1  where stp_number = @Vi_stp_number
		--	FETCH NEXT FROM stops_Cursor INTO @Vi_stp_number
		
		--END --2

		--CLOSE stops_Cursor 
		--DEALLOCATE stops_Cursor 

		---------------------------------------------------------------------------

	

		-- obtenemos los numeros de stops min y max

		select @Vi_stp_number_start	= min(stp_number) from stops where mov_number = @Vi_num_movimiento
		select @Vi_stp_number_end	= max(stp_number) from stops where mov_number = @Vi_num_movimiento

		-- obtengo los datos del origen

		select	@Vi_legheader		= lgh_number, 
				@Vd_lgh_startdate	= stp_schdtearliest, 
				@Vi_lgh_startcity	= stp_city, 
				@Vs_cmp_id_start	= cmp_id,
				@Vs_lgh_startstate	= stp_state
		from stops where mov_number = @Vi_num_movimiento and stp_number = @Vi_stp_number_start

		
		
		-- obtengo los datos del destino.

		select	@Vd_lgh_enddate		= stp_schdtlatest, 
				@Vi_lgh_endcity		= stp_city, 
				@Vs_cmp_id_end		= cmp_id,
				@Vs_lgh_endstate	= stp_state
		from stops where mov_number = @Vi_num_movimiento and stp_number = @Vi_stp_number_end


		Insert legheader (lgh_number, lgh_startdate, lgh_enddate, lgh_startcity, lgh_endcity, 
							lgh_outstatus, lgh_instatus, mov_number,ord_hdrnumber,stp_number_start, 
							stp_number_end, cmp_id_start, cmp_id_end,lgh_startregion1, lgh_endregion1,
							lgh_startstate, lgh_endstate,lgh_class1 ,lgh_class2, lgh_class3, 
							lgh_class4,
							--lgh_schdtearliest, lgh_schdtlatest, lgh_enddate_arrival,
							lgh_createdby, lgh_createdon,
							lgh_driver1, lgh_tractor, lgh_primary_trailer,lgh_type1)
							
		values (@Vi_legheader,@Vd_lgh_startdate, @Vd_lgh_enddate,@Vi_lgh_startcity,@Vi_lgh_endcity , 
		@lgh_outstatus, 'UNP', @Vi_num_movimiento, @ai_NoOrden, @Vi_stp_number_start, 
		@Vi_stp_number_end, @Vs_cmp_id_start, @Vs_cmp_id_end,'MX','MX',
		@Vs_lgh_startstate, @Vs_lgh_endstate, @Vs_ord_revtype1,@Vs_ord_revtype2,@Vs_ord_revtype3,
		@Vs_ord_revtype4, 
		'DX',@Vd_lgh_createdon,
		@as_Driver, @as_Unidad, @as_Rem1,@as_Lgh_type1)
		return 1
END

Return 0	
END


GO
