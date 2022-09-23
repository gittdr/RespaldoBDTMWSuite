SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--Crear stored procedure para generar los inserts de las casetas de un viaje

--execute sp_insertaCasetas_Billing 205396
--drop procedure sp_insertaCasetas_Billing
CREATE PROCEDURE [dbo].[sp_insertaCasetas_Billing]
	-- Add the parameters for the stored procedure here
	@ord int
	--@usuario varchar(20)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--Variables para almacenar datos del stored procedure y calculos
	Declare
	@lgh int,
	@name varchar(100),
	@ejes int,
	@efectivo float,
	@iave float,
	@orden int,
	@segmento int,
	@movimiento int,
	@stp_secuence int,
	@origen int,
	@destino int,
	@revtype1 varchar(100),
	@revtype2 varchar(100),
	@revtype3 varchar(100),
	@revtype4 varchar(100),
	@lgh_type1 varchar(50),
	@lgh_type2 varchar(50),
	@lgh_type3 varchar(50),
	@lgh_type4 varchar(50),
	@stp_loadstatus varchar (20),
	@cht_itemcode varchar (20),
	@pyt_itemcode varchar (50),
	@ejes_totales int,
	@idCaseta int,
	@totalEfectivo float,
	@totalIave float,
	@casetasEfectivo varchar (5000),
	@casetasIave varchar (5000),
	@pyd_number integer,
	@cont1 int,
	@cont2 int,
	@casetaEfect float,
	@casetaIave float,
	@status varchar (20),
	@bandera int,
	@bandera2 int,
@i_totalmsgs4  integer,
	@ivh_hdrnumber int,
	@ivd_rate_charge  money,
	@ivd_unit varchar(6),
	@cur_code varchar(6),
	@ivd_glnum char(32),
	@ivd_rateunit varchar(6),
	@ivd_billto varchar(8),
	@ivd_sequence int	
	
	--Inicializa contadores
	select @cont1 = 0
	select @cont2 = 0
	select @bandera = 0
	select @bandera2 = 0

	--Tabla temporal para almacenar los datos del sp
	create table #tblCasetas (
	nombre varchar(100),
	ejes int,
	efectivo float,
	iave float,
	orden int,
	segmento int,
	movimiento int,
	stp_secuence int,
	origen int,
	destino int,
	revtype1 varchar(100),
	revtype2 varchar(100),
	revtype3 varchar(100),
	revtype4 varchar(100),
	lgh_type1 varchar(50),
	lgh_type2 varchar(50),
	lgh_type3 varchar(50),
	lgh_type4 varchar(50),
	stp_loadstatus varchar (20),
	cht_itemcode varchar (20),
	pyt_itemcode varchar (50),
	ejes_totales int,
	idCaseta int
	)
	
	--Verifica segmentos de la orden
	Declare segmentos cursor for select  lgh_number from legheader where ord_hdrnumber = @ord
	open segmentos
	fetch segmentos into @lgh
	while @@FETCH_STATUS = 0
		begin
			
			--Llenado de la tabla temporal
			insert into #tblCasetas execute dbo.d_get_tolls_spnv   @tollfilter = 'L', @number = @lgh

			--Inicializamos los totales a 0
			select @totalEfectivo = 0
			select @totalIave = 0 

			--Inicializamos los mensajes a vacio
			select @casetasEfectivo = 'Casetas: '
			select @casetasIave = 'Casetas: '

			--Verifica si hay paydetails de casetas y que su estatus sea en onHold para Casetas en Efectivo
			Declare existeEfectivo cursor for select pyd_number, pyd_status  from paydetail where lgh_number = @lgh and pyt_itemcode = 'CASEFE'
			open existeEfectivo
			fetch existeEfectivo into @pyd_number,@status
			while @@FETCH_STATUS = 0
				begin
					if @status = 'REL'
						begin
							select @bandera = @bandera + 1
						end

					FETCH NEXT FROM existeEfectivo INTO @pyd_number,@status
					
				end
			CLOSE existeEfectivo 
			DEALLOCATE existeEfectivo

			--Verifica si hay paydetails de casetas y que su estatus sea en onHold para Casetas IAVE
			Declare existeIave cursor for select pyd_number, pyd_status  from paydetail where lgh_number = @lgh and pyt_itemcode = 'CASIAV'
			open existeIave
			fetch existeIave into @pyd_number,@status
			while @@FETCH_STATUS = 0
				begin
					if @status = 'REL'
						begin
							select @bandera2 = @bandera2 + 1
						end
					FETCH NEXT FROM existeIave INTO @pyd_number,@status

				end
			CLOSE existeIave 
			DEALLOCATE existeIave
			--select @bandera
			if 0 = 0
				begin
					
					-- Insert statements for procedure here
					--Cursor para recorrer los registros
					DECLARE casetas CURSOR FOR select * from #tblCasetas
					
					OPEN casetas

					FETCH casetas INTO 	@name,@ejes,@efectivo,@iave,@orden,	@segmento,@movimiento,@stp_secuence,@origen,@destino,@revtype1,@revtype2,@revtype3,@revtype4,@lgh_type1,@lgh_type2,@lgh_type3,@lgh_type4,@stp_loadstatus,@cht_itemcode,@pyt_itemcode,@ejes_totales,	@idCaseta

					WHILE @@FETCH_STATUS = 0
						
						BEGIN
						
							--Verifica si la caseta es en efectivo o Iave
								if @pyt_itemcode = 'CASEFE'
								begin
									--print 'Efectivo:  '+ cast(@name as nvarchar(100))
									--print '$:  '+ cast(@totalEfectivo as nvarchar(100))
								
								--Obtener el valor de la primera caseta	iave	
								if @cont1 = 0
									begin
										select @casetaEfect = @efectivo
										select @cont1 = 1
									end
 
										
									select @totalEfectivo = @totalEfectivo + @efectivo
									select @casetasEfectivo = @casetasEfectivo + @name + ', '
								end
								else 
								begin
									--print 'Iave:  '+ cast(@name as nvarchar(100))
									--print '$:  '+ cast(@totalIave as nvarchar(100))

									--Obtener el valor de la primera caseta	efectivo
									if @cont2 = 0
									begin
										select @casetaIave = @iave
										select @cont2 = 1
									end

									select @totalIave = @totalIave + @iave
									select @casetasIave = @casetasIave + @name + ', '
								end
								--print 'CasetasPrueba:  '+ cast(@casetasIave as nvarchar(100))
								--print 'Casetasprueba$:  '+ cast(@casetasEfectivo as nvarchar(100))
								--Agregar la caseta al historio
								--delete  toll_history WHERE lgh_number = @lgh and toll_ident = @idCaseta
							--	INSERT INTO toll_history ( lgh_number, toll_ident, th_cash_toll, th_card_toll ) VALUES ( @lgh, @idCaseta, @efectivo, @iave )

							FETCH NEXT FROM casetas INTO @name,@ejes,@efectivo,@iave,@orden,	@segmento,@movimiento,@stp_secuence,@origen,@destino,@revtype1,@revtype2,@revtype3,@revtype4,@lgh_type1,@lgh_type2,@lgh_type3,@lgh_type4,@stp_loadstatus,@cht_itemcode,@pyt_itemcode,@ejes_totales,	@idCaseta
						END

					CLOSE casetas 
					DEALLOCATE casetas	


						delete from #tblCasetas
				end

		FETCH NEXT FROM segmentos INTO @lgh

		end
	CLOSE segmentos 
	DEALLOCATE segmentos
END

	--Inserta en Invoice Detail
		/*	execute @i_totalmsgs4 = tmwSuite..getsystemnumber N'INVDET',NULL
			
				if (select max(ivh_hdrnumber)  from invoicedetail where ord_hdrnumber = @ord )<>0
				begin
					select @ivh_hdrnumber = (select max(ivh_hdrnumber)  from invoicedetail where ord_hdrnumber = @ord )
				end
			else
				begin
				execute @ivh_hdrnumber = TMWSuite..getsystemnumber N'INVHDR',NULL
				select @ivh_hdrnumber = @ivh_hdrnumber-1
				end

			if exists(select pyt_itemcode from  paydetail where ord_hdrnumber = @ord and pyt_itemcode in ('casiav'))
				begin
					select @totalIave = (@totalIave * 1.16)
					select @ivd_rate_charge = (@totalIave + @totalEfectivo)
				end
			else 
				begin
					select @ivd_rate_charge = (@totalIave + @totalEfectivo)
				end

			
			select @ivd_unit = (select cht_basisunit from chargetype where cht_itemcode = 'CAS')
			select @cur_code = (select distinct pyd_currency from  paydetail where ord_hdrnumber = @ord and pyt_itemcode in ('CASEFE', 'casiav'))

			select @ivd_glnum = (select cht_glnum from chargetype where cht_itemcode = 'CAS')

			select @ivd_rateunit = (select cht_rateunit from chargetype where cht_itemcode = 'CAS')

			select @ivd_billto = (select ord_company from orderheader where ord_hdrnumber = @ord)

			select @ivd_sequence = (select max(ivd_sequence)+1  from invoicedetail where ord_hdrnumber = @ord)


			INSERT INTO invoicedetail ( ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity, ivd_rate, ivd_charge , ivd_taxable1, ivd_taxable2, ivd_taxable3, ivd_taxable4, ivd_unit, cur_code, 
			ivd_glnum, ord_hdrnumber, ivd_type, ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr, 
			ivd_sequence, cmp_id, ivd_distance, ivd_distunit, ivd_wgt, ivd_wgtunit, ivd_count, 
			ivd_reftype, ivd_volume, ivd_volunit, ivd_countunit, cht_itemcode, cmd_code, ivd_sign, 

			cht_basisunit, ivd_fromord, cht_rollintolh, ivd_quantity_type, cht_class, ivd_charge_type, 
			ivd_rate_type, cht_lh_min, cht_lh_rev, cht_lh_stl, cht_lh_rpt, 
			ivd_ordered_volume, ivd_ordered_loadingmeters, ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_revtype1, ivd_artaxauth, fgt_supplier, ivd_loaded_distance, ivd_empty_distance, ivd_maskfromrating, ivd_car_key, ivd_showas_cmpid ) 
			VALUES ( @ivh_hdrnumber, @i_totalmsgs4, 'Casetas', 1.000000, @ivd_rate_charge, @ivd_rate_charge, 
			'Y', 'N', 'N', 'Y', @ivd_unit, @cur_code, @ivd_glnum, @ord, 'LI', @ivd_rateunit, @ivd_billto, 0, 0, 
			@ivd_sequence, 'UNKNOWN', 0, null, null, null, null, 
			'UNK', null, null, null, 'CAS', 'UNKNOWN', 1, 

			'FLT', 'Y', 0, 0, 'UNK', 0,
			0, 'N', 'N', 'N', 'N',
			0, 0, 0, 0, 0, 
			'CEN', '', 'UNKNOWN', 0, 0, 'N', 0, 'UNKNOWN' )
			--ivd_rate_type smallint,*/
--
--						print @totalEfectivo 
--						print @casetasEfectivo 
--						print @totalIave 
--						print @casetasIave 

/*print @ivh_hdrnumber
print @i_totalmsgs4
print @ord
print @ivd_rate_charge
print @ivd_unit
print @cur_code
print @ivd_glnum
print @ivd_rateunit
print @ivd_billto
print @ivd_sequence*/












GO
