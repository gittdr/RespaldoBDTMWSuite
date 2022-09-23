SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--Crear stored procedure para generar los inserts de las casetas de un viaje

--execute sp_insertaCasetas 205658, 'NADD'
--drop procedure sp_insertaCasetas
CREATE PROCEDURE [dbo].[sp_insertaCasetas]
	-- Add the parameters for the stored procedure here
	@ord int,
	@usuario varchar(20)	
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
	@driver varchar(100),
	@pyd_prorap varchar (5),
	@pyt_itemcode_iave varchar (20),
	@pyt_rateunit varchar (20),
	@pyt_unit varchar (20),
	@pyt_pretax varchar (20),
	@pyt_minus varchar (500),
	@pyt_minus_valor int,
	@pyt_fee1 float,
	@pyt_fee2 float,
	@cont1 int,
	@cont2 int,
	@casetaEfect float,
	@casetaIave float,
	@status varchar (20),
	@bandera int,
	@bandera2 int,
	@Carrier varchar(10)	
	
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
		begin --1

-- Obtiene los datos del carrier y del operador

			select  @Carrier = lgh_carrier from legheader where lgh_number = @lgh
			IF @Carrier = 'UNKNOWN' 
			Begin -- 2 jr
					--Llenado de la tabla temporal
					delete from  toll_history WHERE lgh_number = @lgh
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
										INSERT INTO toll_history ( lgh_number, toll_ident, th_cash_toll, th_card_toll ) VALUES ( @lgh, @idCaseta, @efectivo, @iave )

									FETCH NEXT FROM casetas INTO @name,@ejes,@efectivo,@iave,@orden,	@segmento,@movimiento,@stp_secuence,@origen,@destino,@revtype1,@revtype2,@revtype3,@revtype4,@lgh_type1,@lgh_type2,@lgh_type3,@lgh_type4,@stp_loadstatus,@cht_itemcode,@pyt_itemcode,@ejes_totales,	@idCaseta
								END

							CLOSE casetas 
							DEALLOCATE casetas	

							--Realiza el insert de los paydetail
							
							--select @totalEfectivo
							--select @totalIave

							--select @casetasEfectivo
							--select @casetasIave
							
							--Verifica que el total Iave sea diferente de 0

							if @totalIave <> 0 and @bandera2 = 0
								begin
									delete from paydetail where lgh_number = @lgh and pyt_itemcode = 'CASIAV'
									--Datos para el insert de casetas IAVE
									--Consecutivo
									execute @pyd_number = tmwsuite..getsystemnumber_gateway N'PYDNUM' , NULL , 1 
									select @driver = (select lgh_driver1 from legheader where lgh_number = @lgh)
									select @pyd_prorap = (select mpp_actg_type from manpowerprofile where mpp_id = @driver)
									select @pyt_itemcode_iave = (select distinct pyt_itemcode from tollbooth  where tb_ident > 0 and tb_vendor_name = 'IAVE')
									select @pyt_rateunit = (SELECT  pyt_rateunit FROM paytype WHERE pyt_itemcode ='CASIAV')
									select @pyt_unit =(SELECT  pyt_unit FROM paytype WHERE pyt_itemcode ='CASIAV')
									select @pyt_pretax = (SELECT  pyt_pretax FROM paytype WHERE pyt_itemcode ='CASIAV')
									select @pyt_minus = (SELECT  pyt_minus FROM paytype WHERE pyt_itemcode ='CASIAV') 
									select @pyt_fee1 = (SELECT  pyt_fee1 FROM paytype WHERE pyt_itemcode ='CASIAV') 
									select @pyt_fee2 = (SELECT  pyt_fee2  FROM paytype WHERE pyt_itemcode ='CASIAV')

									--Verifica el campo minus N = 1 o Y = -1

									if @pyt_minus = 'N'
										begin
											select @pyt_minus_valor = 1
										end
									else
										begin
											select @pyt_minus_valor = -1
										end 
									
									--Paydetail casetas IAVE
									INSERT INTO paydetail 
									( pyd_number, pyh_number, lgh_number, asgn_number, asgn_type, asgn_id, ivd_number, pyd_prorap, pyd_payto, pyt_itemcode 
									 ,pyd_description, pyd_quantity, 
									pyd_rateunit, pyd_unit, pyd_pretax, pyd_status, pyh_payperiod, ivd_payrevenue, mov_number, pyd_minus, pyd_workperiod, pyd_sequence, pyd_rate, pyd_amount, pyd_revenueratio, 
									pyd_lessrevenue, pyd_payrevenue, pyd_loadstate, pyd_transdate, pyd_xrefnumber, ord_hdrnumber, pyt_fee1, pyt_fee2, pyd_grossamount, pyd_adj_flag, pyd_maxquantity_used, 
									pyd_maxcharge_used, pyd_vendortopay, pyd_gst_flag 
									) VALUES 
									( @pyd_number, 0, @lgh, 0, 'TPR', 'PROVEEDO', 0, @pyd_prorap, 'UNKNOWN',@pyt_itemcode_iave, substring(@casetasIave,1,74), 1.0000 
									,@pyt_rateunit, @pyt_unit, @pyt_pretax, 'HLD', {ts '2049-12-31 23:59:00.000'}, 0.0000, @movimiento, @pyt_minus_valor, {ts '2049-12-31 23:59:00.000'}, 1, @totalIave, @totalIave, 0.0000, 
									0.0000, 0.0000, 'NA', current_timestamp, 0, @ord, @pyt_fee1,@pyt_fee2, @casetaIave, 'N', 'N', 
									'N', 'UNKNOWN', 0 
									)


									
									update paydetail set pyd_createdby = @usuario where pyd_number = @pyd_number
								end

							--Verifica que el total efectivo sea diferente de 0

							if @totalEfectivo <> 0 and @bandera = 0
								begin
									delete from paydetail where lgh_number = @lgh and pyt_itemcode = 'CASEFE'
									--Paydetail casetas efectivo	

									--Datos para el insert de casetas en Efectivo
									--Consecutivo
									execute @pyd_number = tmwSuite..getsystemnumber_gateway N'PYDNUM' , NULL , 1 
									select @driver = (select lgh_driver1 from legheader where lgh_number = @lgh)
									select @pyd_prorap = (select mpp_actg_type from manpowerprofile where mpp_id = @driver)
									select @pyt_itemcode_iave = (select distinct pyt_itemcode from tollbooth  where tb_ident > 0 and tb_vendor_name = 'EFECTIVO' and pyt_itemcode <> 'UNK')
									select @pyt_rateunit = (SELECT  pyt_rateunit FROM paytype WHERE pyt_itemcode ='CASEFE')
									select @pyt_unit =(SELECT  pyt_unit FROM paytype WHERE pyt_itemcode ='CASEFE')
									select @pyt_pretax = (SELECT  pyt_pretax FROM paytype WHERE pyt_itemcode ='CASEFE')
									select @pyt_minus = (SELECT  pyt_minus FROM paytype WHERE pyt_itemcode ='CASEFE') 
									select @pyt_fee1 = (SELECT  pyt_fee1 FROM paytype WHERE pyt_itemcode ='CASEFE') 
									select @pyt_fee2 = (SELECT  pyt_fee2  FROM paytype WHERE pyt_itemcode ='CASEFE')

									--Verifica el campo minus N = 1 o Y = -1

									if @pyt_minus = 'N'
										begin
											select @pyt_minus_valor = 1
										end
									else
										begin
											select @pyt_minus_valor = -1
										end

									INSERT INTO paydetail ( pyd_number, pyh_number, lgh_number, asgn_number, asgn_type, asgn_id, ivd_number, pyd_prorap, pyd_payto, pyt_itemcode, pyd_description, pyd_quantity, 
									pyd_rateunit, pyd_unit, pyd_pretax, pyd_status, pyh_payperiod, ivd_payrevenue, mov_number, pyd_minus, pyd_workperiod, pyd_sequence, pyd_rate, pyd_amount, pyd_revenueratio, 
									pyd_lessrevenue, pyd_payrevenue, pyd_loadstate, pyd_transdate, pyd_xrefnumber, ord_hdrnumber, pyt_fee1, pyt_fee2, pyd_grossamount, pyd_adj_flag, pyd_maxquantity_used, 
									pyd_maxcharge_used, pyd_vendortopay, pyd_gst_flag 
									 ) VALUES ( @pyd_number, 0, @lgh, 0, 'DRV', @driver, 0, @pyd_prorap, 'UNKNOWN',@pyt_itemcode_iave,substring(@casetasEfectivo,1,74), 1.0000,
									@pyt_rateunit, @pyt_unit, @pyt_pretax, 'HLD', {ts '2049-12-31 23:59:00.000'}, 0.0000, @movimiento,@pyt_minus_valor, {ts '2049-12-31 23:59:00.000'}, 1, @totalEfectivo, @totalEfectivo, 0.0000,
									0.0000, 0.0000, 'NA', current_timestamp, 0, @ord, @pyt_fee1,@pyt_fee2, @casetaEfect, 'N', 'N', 'N', 'UNKNOWN', 0 
									)

									
									update paydetail set pyd_createdby = @usuario where pyd_number = @pyd_number
								end
								select @totalEfectivo = 0
								select @casetasEfectivo = ''
								select @totalIave = 0
								select @casetasIave = ''
								delete from #tblCasetas
						end
				end -- 2 jr
					FETCH NEXT FROM segmentos INTO @lgh
			
		end -- 1
	CLOSE segmentos 
	DEALLOCATE segmentos
END











GO
