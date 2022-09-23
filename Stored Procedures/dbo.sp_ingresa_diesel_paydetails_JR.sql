SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--SP que sirve para obtener los billtos y las ordenes que tengan tarifa


--  exec sp_ingresa_diesel_paydetails_JR

CREATE PROCEDURE [dbo].[sp_ingresa_diesel_paydetails_JR]

AS
DECLARE	
	@V_unidad		Varchar(8),
	@V_proveedor	Varchar(10),
	@Vi_Folio		varchar(36),
	@V_estacion	    Varchar(100),
	@V_Monto		Money,
	@V_descripcion  Varchar(75),
	@Vi_orden		Integer,
	@Vi_movimiento	Integer,
	@Vi_legheader	Integer,
	@Vi_consecpaydetail Integer,
	@Vd_fecha		datetime,
	@vm_cantidad	Money,
	@vm_costo		Money

	
DECLARE @TTDatosACargar TABLE(
		Tfp_id	Varchar(36) NULL,
		Tfp_cac_id	Varchar(10) Null,
		Tfp_amount		Money NULL,
		Ttrc_number	Varchar(8) null,
		Tfp_date	Datetime null,
		Tfp_quantity Money null,
		Tfp_cost_per Money null)
		

SET NOCOUNT ON

BEGIN --1 Principal
	-- Inserta en la tabla temporal la información que haya en la de paso TPosicion
		INSERT Into @TTDatosACargar
		select fp_id, fp_cac_id, fp_amount, trc_number,fp_date,fp_quantity, fp_cost_per from fuelpurchased where fp_id not in (select pp_consecutivo from purchased_paydetail) and  fp_date >= '2018-12-01'
		
		-- Se declara un curso para ir leyendo la tabla de paso
		DECLARE Posiciones_Cursor CURSOR FOR 
		SELECT Tfp_id, Tfp_cac_id, Tfp_amount,Ttrc_number, Tfp_date, Tfp_quantity, Tfp_cost_per 
		FROM @TTDatosACargar 
	
		OPEN Posiciones_Cursor 
		FETCH NEXT FROM Posiciones_Cursor INTO @Vi_Folio, @V_proveedor, @V_Monto, @V_unidad, @Vd_fecha, @vm_cantidad, @vm_costo
		--Mientras la lectura sea correcta y el contador sea menos al total de registros
		WHILE (@@FETCH_STATUS = 0 )
		BEGIN -- del cursor Unidades_Cursor --3

				--Busca el maximo legheader para asignarselo a este paydetail...
				select @Vi_legheader = IsNull(max(lgh_number),0) from legheader where lgh_tractor = @V_unidad and lgh_startdate <= @Vd_fecha
				IF @Vi_legheader > 0
					select @Vi_movimiento = mov_number, @Vi_orden = ord_hdrnumber from legheader where lgh_tractor = @V_unidad and lgh_number = @Vi_legheader
				ELSE
					begin
						select @Vi_movimiento	= 0
						select @Vi_orden		= 0
						select @Vi_legheader	= 675613
					end




				-- Forma la descripcion
				select @V_descripcion	=	Left(@V_unidad +' - '+@V_proveedor+'-'+cast(@Vd_fecha as varchar(16)),75)

				-- OBTIENE EL CONSECUTIVO
				execute @Vi_consecpaydetail = getsystemnumber_gateway N'PYDNUM' , NULL , 1 

				-- Hace el insert de los datos a la tabla  de paso
				insert purchased_paydetail(pp_consecutivo, pp_paydetail)
				values(@Vi_Folio, @Vi_consecpaydetail)
					




			--Hace el insert de los datos .
								Insert paydetail
								(pyd_number, 	pyh_number,			lgh_number, 			asgn_number, 
								asgn_type, 				asgn_id, 			ivd_number, 			pyd_prorap, 			pyd_payto, 
								pyt_itemcode, 			mov_number, 		pyd_description, 		pyr_ratecode, 			pyd_quantity, 
								pyd_rateunit, 			pyd_unit, 			pyd_rate, 				pyd_amount, 			pyd_pretax, 
								pyd_glnum, 				pyd_currency, 		pyd_currencydate, 	pyd_status, 			pyd_refnumtype, 
								pyd_refnum, 			pyh_payperiod, 	pyd_workperiod, 		lgh_startpoint, 		lgh_startcity, 
								lgh_endpoint, 			lgh_endcity, 		ivd_payrevenue, 		pyd_revenueratio, 	pyd_lessrevenue, 
								pyd_payrevenue, 		pyd_transdate, 	pyd_minus, 				pyd_sequence, 			std_number, 
								pyd_loadstate, 		pyd_xrefnumber, 	ord_hdrnumber, 		pyt_fee1,	 			pyt_fee2, 
								pyd_grossamount,		pyd_adj_flag, 		pyd_updatedby, 		psd_id, 					pyd_transferdate, 
								pyd_exportstatus, 	pyd_releasedby, 	cht_itemcode, 			pyd_billedweight, 	tar_tarriffnumber, 
								psd_batch_id, 			pyd_updsrc, 		pyd_updatedon, 		pyd_offsetpay_number,pyd_credit_pay_flag, 
								pyd_ivh_hdrnumber,	psd_number, 		pyd_ref_invoice, 		pyd_ref_invoicedate, pyd_ignoreglreset, 
								pyd_authcode, 			pyd_PostProcSource, 	pyd_GPTrans, 		cac_id, 					ccc_id, 
								pyd_hourlypaydate,	pyd_isdefault, 	pyd_maxquantity_used, 	pyd_maxcharge_used, 	pyd_mbtaxableamount, 
								pyd_nttaxableamount, pyd_carinvnum, 	pyd_carinvdate, 		std_number_adj, 		pyd_vendortopay, 
								pyd_vendorpay, 		pyd_remarks, 		stp_number, 			stp_mfh_sequence,		pyd_perdiem_exceeded, 
								pyd_carrierinvoice_aprv, pyd_carrierinvoice_rjct, pyd__aprv_rjct_comment, 			pyd_payment_date, 	pyd_payment_doc_number, 
								pyd_paid_indicator, 	pyd_paid_amount, 	pyd_createdby, 		pyd_createdon, 		stp_number_pacos, 
								pyd_expresscode, 		pyd_gst_amount, 	pyd_gst_flag, 			pyd_mileagetable, 	bill_override, 
								not_billed_reason, 	pyd_reg_time_qty,	pyt_otflag, 			pyd_ap_check_date, 	pyd_ap_check_number, 
								pyd_ap_check_amount, pyd_ap_vendor_id,	pyd_ap_updated_by)
								Values(
								@Vi_consecpaydetail,	0,					@Vi_legheader,			0,
								'TPR',						@V_proveedor,		0,								'A',			'UNKNOWN',
								'VALEEL',					@Vi_movimiento,		@V_descripcion,	Null,			@vm_cantidad,
								'FLT',						'FLT',			@vm_costo,				@V_Monto,		'Y',
								Null,							'MX$',			getdate(),		'PND',				Null,
								Null,							'2049-12-31 23:59', 	'2049-12-31 23:59', 			Null,			Null,
								Null,							Null,				.0000,			0.0,					.0000,
								.0000,						getdate(),		-1,					1,						Null,
								'NA',							0,					@Vi_orden,					.0000,			.0000,
								.0000,						'N',				'AUTO', 	Null,					Null,
								Null,							Null,				Null,				Null,					Null,
								Null, 						Null,				getdate(),		Null,					Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				Null,				Null,					'UNKNOWN',	
								Null,							@Vi_Folio,			Null,				Null,					Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				'AUTO',				@Vd_fecha,				Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				Null,				Null,					Null,		
								Null,							Null,				Null);
			


		FETCH NEXT FROM Posiciones_Cursor INTO   @Vi_Folio, @V_proveedor, @V_Monto, @V_unidad, @Vd_fecha, @vm_cantidad, @vm_costo
		
	
	END --3 curso de los movimientos 

	CLOSE Posiciones_Cursor 
	DEALLOCATE Posiciones_Cursor 


END --1 Principal


GO
