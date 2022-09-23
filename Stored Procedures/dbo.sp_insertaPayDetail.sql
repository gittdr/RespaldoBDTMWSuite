SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





--execute sp_insertaPayDetail 227950, 220669, 100, 201399, "NADD"
--drop procedure sp_insertaPayDetail
CREATE PROCEDURE [dbo].[sp_insertaPayDetail] 
(
@segmento int,
@movNumber int,
@litros float,
@orden int,
@usuario varchar (20)
)
as 

DECLARE @i_totalmsgs1            integer,
	@i_totalmsgs4            integer,
	@msg_error		varchar(30),
	@monto float,
	@precio float,
    @trc varchar(12),
	@ord int

select @ord = (select ord_hdrnumber from legheader where lgh_number = @segmento)
select @trc = (select lgh_tractor from legheader where lgh_number = @segmento)

if @ord = @orden
begin

	execute @i_totalmsgs4 = tmwSuite..getsystemnumber_gateway N'PYDNUM' , NULL , 1 
	--// SELECT @msg_error = (@i_totalmsgs4)

	delete from paydetail where lgh_number = @segmento and pyt_itemcode in ('VALECO','VALEEL')

	delete from paydetail where lgh_number = @segmento and pyt_itemcode in ('VALECO','VALEEL')

	select @precio = (SELECT top 1 averagefuelprice.afp_price FROM averagefuelprice WHERE ( averagefuelprice.afp_tableid = '4' ) order by afp_date desc)
	select @monto = @precio * @litros

  --Modificado por Emolvera 01/02/2014 para que los tractos que tengan como accesorio una tarjeta de diesel electronica TDE inserte el pay detail VALEEL
	if @trc in (select tca_tractor from tractoraccesories where tca_type = 'TDE')
	 begin
  		INSERT INTO paydetail ( pyd_number , pyh_number , lgh_number , asgn_number , asgn_type , asgn_id , ivd_number , pyd_prorap , pyd_payto , pyt_itemcode , mov_number , pyd_description , 
		pyr_ratecode , pyd_quantity , pyd_rateunit , pyd_unit , pyd_rate , pyd_amount , pyd_pretax , pyd_glnum , pyd_currency , pyd_currencydate , pyd_status , pyd_refnumtype , pyd_refnum , 
		pyh_payperiod , pyd_workperiod , lgh_startpoint , lgh_startcity , lgh_endpoint , lgh_endcity , ivd_payrevenue , pyd_revenueratio , pyd_lessrevenue , pyd_payrevenue , pyd_transdate , 
		pyd_minus , pyd_sequence , std_number , pyd_loadstate , pyd_xrefnumber , ord_hdrnumber , pyt_fee1 , pyt_fee2 , pyd_grossamount , pyd_adj_flag , pyd_updatedby , psd_id , pyd_transferdate , 
		pyd_exportstatus , pyd_releasedby , cht_itemcode , pyd_billedweight , tar_tarriffnumber , psd_batch_id , pyd_updsrc , pyd_updatedon , pyd_offsetpay_number , pyd_credit_pay_flag , 
		pyd_ivh_hdrnumber) SELECT @i_totalmsgs4 , 0 , @segmento , 0 , 'TPR' , 'PROVEEDO' , 0 , 'A' , 'UNKNOWN' , 'VALEEL' , @movNumber , pyt.pyt_description , null , @litros , pyt.pyt_rateunit , pyt.pyt_unit 
		, @precio , @monto , pyt.pyt_pretax , CASE 'A' WHEN 'A' THEN pyt.pyt_ap_glnum ELSE pyt.pyt_pr_glnum END , 'MX$' , current_timestamp , 'HLD' , null , null , {ts '2049-12-31 23:59:00.000'} , {ts 
		'2049-12-31 23:59:00.000'} , null , null , null , null , 0.00 , 0.00 , 0.00 , 0.00 , current_timestamp , CASE pyt.pyt_minus WHEN 'Y' THEN - 1 ELSE 1 END , 1 , null , 'NA' , 0 , @orden , 
		isnull ( pyt.pyt_fee1 , 0.00 ) , isnull ( pyt.pyt_fee2 , 0.00 ) , 0.00 , 'N' , @usuario, null , null , null , null , null , null , '' , null , null , current_timestamp , null , null , null
		FROM paytype pyt WHERE pyt.pyt_itemcode ='VALEEL' 
	 end  
	else
	 begin


		INSERT INTO paydetail ( pyd_number , pyh_number , lgh_number , asgn_number , asgn_type , asgn_id , ivd_number , pyd_prorap , pyd_payto , pyt_itemcode , mov_number , pyd_description , 
		pyr_ratecode , pyd_quantity , pyd_rateunit , pyd_unit , pyd_rate , pyd_amount , pyd_pretax , pyd_glnum , pyd_currency , pyd_currencydate , pyd_status , pyd_refnumtype , pyd_refnum , 
		pyh_payperiod , pyd_workperiod , lgh_startpoint , lgh_startcity , lgh_endpoint , lgh_endcity , ivd_payrevenue , pyd_revenueratio , pyd_lessrevenue , pyd_payrevenue , pyd_transdate , 
		pyd_minus , pyd_sequence , std_number , pyd_loadstate , pyd_xrefnumber , ord_hdrnumber , pyt_fee1 , pyt_fee2 , pyd_grossamount , pyd_adj_flag , pyd_updatedby , psd_id , pyd_transferdate , 
		pyd_exportstatus , pyd_releasedby , cht_itemcode , pyd_billedweight , tar_tarriffnumber , psd_batch_id , pyd_updsrc , pyd_updatedon , pyd_offsetpay_number , pyd_credit_pay_flag , 
		pyd_ivh_hdrnumber) SELECT @i_totalmsgs4 , 0 , @segmento , 0 , 'TPR' , 'PROVEEDO' , 0 , 'A' , 'UNKNOWN' , 'VALECO' , @movNumber , pyt.pyt_description , null , @litros , pyt.pyt_rateunit , pyt.pyt_unit 
		, @precio , @monto , pyt.pyt_pretax , CASE 'A' WHEN 'A' THEN pyt.pyt_ap_glnum ELSE pyt.pyt_pr_glnum END , 'MX$' , current_timestamp , 'HLD' , null , null , {ts '2049-12-31 23:59:00.000'} , {ts 
		'2049-12-31 23:59:00.000'} , null , null , null , null , 0.00 , 0.00 , 0.00 , 0.00 , current_timestamp , CASE pyt.pyt_minus WHEN 'Y' THEN - 1 ELSE 1 END , 1 , null , 'NA' , 0 , @orden , 
		isnull ( pyt.pyt_fee1 , 0.00 ) , isnull ( pyt.pyt_fee2 , 0.00 ) , 0.00 , 'N' , @usuario, null , null , null , null , null , null , '' , null , null , current_timestamp , null , null , null
		FROM paytype pyt WHERE pyt.pyt_itemcode ='VALECO' 
	end

	print 'usuario: '+ cast(@usuario as nvarchar(30))

	--Insert tmwDes..paydetail
	--			(		pyd_number, 	pyh_number,			lgh_number, 			asgn_number, 
	--			asgn_type, 				asgn_id, 			ivd_number, 			pyd_prorap, 			pyd_payto, 
	--			pyt_itemcode, 			mov_number, 		pyd_description, 		pyr_ratecode, 			pyd_quantity, 
	--			pyd_rateunit, 			pyd_unit, 			pyd_rate, 				pyd_amount, 			pyd_pretax, 
	--			pyd_glnum, 				pyd_currency, 		pyd_currencydate, 	pyd_status, 			pyd_refnumtype, 
	--			pyd_refnum, 			pyh_payperiod, 	pyd_workperiod, 		lgh_startpoint, 		lgh_startcity, 
	--			lgh_endpoint, 			lgh_endcity, 		ivd_payrevenue, 		pyd_revenueratio, 	pyd_lessrevenue, 
	--			pyd_payrevenue, 		pyd_transdate, 	pyd_minus, 				pyd_sequence, 			std_number, 
	--			pyd_loadstate, 		pyd_xrefnumber, 	ord_hdrnumber, 		pyt_fee1,	 			pyt_fee2, 
	--			pyd_grossamount,		pyd_adj_flag, 		pyd_updatedby, 		psd_id, 					pyd_transferdate, 
	--			pyd_exportstatus, 	pyd_releasedby, 	cht_itemcode, 			pyd_billedweight, 	tar_tarriffnumber, 
	--			psd_batch_id, 			pyd_updsrc, 		pyd_updatedon, 		pyd_offsetpay_number,pyd_credit_pay_flag, 
	--			pyd_ivh_hdrnumber,	psd_number, 		pyd_ref_invoice, 		pyd_ref_invoicedate, pyd_ignoreglreset, 
	--			pyd_authcode, 			pyd_PostProcSource, 	pyd_GPTrans, 		cac_id, 					ccc_id, 
	--			pyd_hourlypaydate,	pyd_isdefault, 	pyd_maxquantity_used, 	pyd_maxcharge_used, 	pyd_mbtaxableamount, 
	--			pyd_nttaxableamount, pyd_carinvnum, 	pyd_carinvdate, 		std_number_adj, 		pyd_vendortopay, 
	--			pyd_vendorpay, 		pyd_remarks, 		stp_number, 			stp_mfh_sequence,		pyd_perdiem_exceeded, 
	--			pyd_carrierinvoice_aprv, pyd_carrierinvoice_rjct, pyd__aprv_rjct_comment, 			pyd_payment_date, 	pyd_payment_doc_number, 
	--			pyd_paid_indicator, 	pyd_paid_amount, 	pyd_createdby, 		pyd_createdon, 		stp_number_pacos, 
	--			pyd_expresscode, 		pyd_gst_amount, 	pyd_gst_flag, 			pyd_mileagetable, 	bill_override, 
	--			not_billed_reason, 	pyd_reg_time_qty,	pyt_otflag, 			pyd_ap_check_date, 	pyd_ap_check_number, 
	--			pyd_ap_check_amount, pyd_ap_vendor_id,	pyd_ap_updated_by)
	--			Values(
	--			@i_totalmsgs4,	0,					@segmento,			0,
	--			'TPR',						'PROVEEDO',		0,								'A',			'UNKNOWN',
	--			'VALECO',					@movNumber,		'%Vale de Combustible',	Null,			@litros,
	--			'FLT',						'FLT',			@precio,				@monto,		'Y',
	--			Null,							'MX$',			getdate(),					'HLD',				Null,
	--			Null,							'2049-12-31 23:59', 	'2049-12-31 23:59', 			Null,			Null,
	--			Null,							Null,				.0000,			0.0,					.0000,
	--			.0000,						getdate(),		1,					1,						Null,
	--			'NA',							0,					@orden,					.0000,			.0000,
	--			.0000,						'N',				'NADD', 	Null,					Null,
	--			Null,							Null,				Null,				Null,					Null,
	--			Null, 						Null,				getdate(),		Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					'UNKNOWN',	
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				'NADD',	getdate(),			Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null);

	print 'usuario: '+ cast(@usuario as nvarchar(30))
	Return @i_totalmsgs4

end
else
begin

	execute @i_totalmsgs4 = tmwSuite..getsystemnumber_gateway N'PYDNUM' , NULL , 1 
	--// SELECT @msg_error = (@i_totalmsgs4)

	delete from paydetail where lgh_number = @segmento and pyt_itemcode in ('VALECO','VALEEL')

	delete from paydetail where lgh_number = @segmento and pyt_itemcode in ('VALECO','VALEEL')

	select @precio = (SELECT top 1 averagefuelprice.afp_price FROM averagefuelprice WHERE ( averagefuelprice.afp_tableid = '4' ) order by afp_date desc)
	select @monto = @precio * @litros


    --Modificado por Emolvera 01/02/2014 para que los tractos que tengan como accesorio una tarjeta de diesel electronica TDE inserte el pay detail VALEEL
	if @trc in (select tca_tractor from tractoraccesories where tca_type = 'TDE')
	 begin
  		INSERT INTO paydetail ( pyd_number , pyh_number , lgh_number , asgn_number , asgn_type , asgn_id , ivd_number , pyd_prorap , pyd_payto , pyt_itemcode , mov_number , pyd_description , 
		pyr_ratecode , pyd_quantity , pyd_rateunit , pyd_unit , pyd_rate , pyd_amount , pyd_pretax , pyd_glnum , pyd_currency , pyd_currencydate , pyd_status , pyd_refnumtype , pyd_refnum , 
		pyh_payperiod , pyd_workperiod , lgh_startpoint , lgh_startcity , lgh_endpoint , lgh_endcity , ivd_payrevenue , pyd_revenueratio , pyd_lessrevenue , pyd_payrevenue , pyd_transdate , 
		pyd_minus , pyd_sequence , std_number , pyd_loadstate , pyd_xrefnumber , ord_hdrnumber , pyt_fee1 , pyt_fee2 , pyd_grossamount , pyd_adj_flag , pyd_updatedby , psd_id , pyd_transferdate , 
		pyd_exportstatus , pyd_releasedby , cht_itemcode , pyd_billedweight , tar_tarriffnumber , psd_batch_id , pyd_updsrc , pyd_updatedon , pyd_offsetpay_number , pyd_credit_pay_flag , 
		pyd_ivh_hdrnumber) SELECT @i_totalmsgs4 , 0 , @segmento , 0 , 'TPR' , 'PROVEEDO' , 0 , 'A' , 'UNKNOWN' , 'VALEEL' , @movNumber , pyt.pyt_description , null , @litros , pyt.pyt_rateunit , pyt.pyt_unit 
		, @precio , @monto , pyt.pyt_pretax , CASE 'A' WHEN 'A' THEN pyt.pyt_ap_glnum ELSE pyt.pyt_pr_glnum END , 'MX$' , current_timestamp , 'HLD' , null , null , {ts '2049-12-31 23:59:00.000'} , {ts 
		'2049-12-31 23:59:00.000'} , null , null , null , null , 0.00 , 0.00 , 0.00 , 0.00 , current_timestamp , CASE pyt.pyt_minus WHEN 'Y' THEN - 1 ELSE 1 END , 1 , null , 'NA' , 0 , @orden , 
		isnull ( pyt.pyt_fee1 , 0.00 ) , isnull ( pyt.pyt_fee2 , 0.00 ) , 0.00 , 'N' , @usuario, null , null , null , null , null , null , '' , null , null , current_timestamp , null , null , null
		FROM paytype pyt WHERE pyt.pyt_itemcode ='VALEEL' 
	 end  
	else
	 begin

		INSERT INTO paydetail ( pyd_number , pyh_number , lgh_number , asgn_number , asgn_type , asgn_id , ivd_number , pyd_prorap , pyd_payto , pyt_itemcode , mov_number , pyd_description , 
		pyr_ratecode , pyd_quantity , pyd_rateunit , pyd_unit , pyd_rate , pyd_amount , pyd_pretax , pyd_glnum , pyd_currency , pyd_currencydate , pyd_status , pyd_refnumtype , pyd_refnum , 
		pyh_payperiod , pyd_workperiod , lgh_startpoint , lgh_startcity , lgh_endpoint , lgh_endcity , ivd_payrevenue , pyd_revenueratio , pyd_lessrevenue , pyd_payrevenue , pyd_transdate , 
		pyd_minus , pyd_sequence , std_number , pyd_loadstate , pyd_xrefnumber , ord_hdrnumber , pyt_fee1 , pyt_fee2 , pyd_grossamount , pyd_adj_flag , pyd_updatedby , psd_id , pyd_transferdate , 
		pyd_exportstatus , pyd_releasedby , cht_itemcode , pyd_billedweight , tar_tarriffnumber , psd_batch_id , pyd_updsrc , pyd_updatedon , pyd_offsetpay_number , pyd_credit_pay_flag , 
		pyd_ivh_hdrnumber) SELECT @i_totalmsgs4 , 0 , @segmento , 0 , 'TPR' , 'PROVEEDO' , 0 , 'A' , 'UNKNOWN' , 'VALECO' , @movNumber , pyt.pyt_description , null , @litros , pyt.pyt_rateunit , pyt.pyt_unit 
		, @precio , @monto , pyt.pyt_pretax , CASE 'A' WHEN 'A' THEN pyt.pyt_ap_glnum ELSE pyt.pyt_pr_glnum END , 'MX$' , current_timestamp , 'HLD' , null , null , {ts '2049-12-31 23:59:00.000'} , {ts 
		'2049-12-31 23:59:00.000'} , null , null , null , null , 0.00 , 0.00 , 0.00 , 0.00 , current_timestamp , CASE pyt.pyt_minus WHEN 'Y' THEN - 1 ELSE 1 END , 1 , null , 'NA' , 0 , @ord , 
		isnull ( pyt.pyt_fee1 , 0.00 ) , isnull ( pyt.pyt_fee2 , 0.00 ) , 0.00 , 'N' , @usuario, null , null , null , null , null , null , '' , null , null , current_timestamp , null , null , null
		FROM paytype pyt WHERE pyt.pyt_itemcode ='VALECO' 

    end

	print 'usuario: '+ cast(@usuario as nvarchar(30))

	--Insert tmwDes..paydetail
	--			(		pyd_number, 	pyh_number,			lgh_number, 			asgn_number, 
	--			asgn_type, 				asgn_id, 			ivd_number, 			pyd_prorap, 			pyd_payto, 
	--			pyt_itemcode, 			mov_number, 		pyd_description, 		pyr_ratecode, 			pyd_quantity, 
	--			pyd_rateunit, 			pyd_unit, 			pyd_rate, 				pyd_amount, 			pyd_pretax, 
	--			pyd_glnum, 				pyd_currency, 		pyd_currencydate, 	pyd_status, 			pyd_refnumtype, 
	--			pyd_refnum, 			pyh_payperiod, 	pyd_workperiod, 		lgh_startpoint, 		lgh_startcity, 
	--			lgh_endpoint, 			lgh_endcity, 		ivd_payrevenue, 		pyd_revenueratio, 	pyd_lessrevenue, 
	--			pyd_payrevenue, 		pyd_transdate, 	pyd_minus, 				pyd_sequence, 			std_number, 
	--			pyd_loadstate, 		pyd_xrefnumber, 	ord_hdrnumber, 		pyt_fee1,	 			pyt_fee2, 
	--			pyd_grossamount,		pyd_adj_flag, 		pyd_updatedby, 		psd_id, 					pyd_transferdate, 
	--			pyd_exportstatus, 	pyd_releasedby, 	cht_itemcode, 			pyd_billedweight, 	tar_tarriffnumber, 
	--			psd_batch_id, 			pyd_updsrc, 		pyd_updatedon, 		pyd_offsetpay_number,pyd_credit_pay_flag, 
	--			pyd_ivh_hdrnumber,	psd_number, 		pyd_ref_invoice, 		pyd_ref_invoicedate, pyd_ignoreglreset, 
	--			pyd_authcode, 			pyd_PostProcSource, 	pyd_GPTrans, 		cac_id, 					ccc_id, 
	--			pyd_hourlypaydate,	pyd_isdefault, 	pyd_maxquantity_used, 	pyd_maxcharge_used, 	pyd_mbtaxableamount, 
	--			pyd_nttaxableamount, pyd_carinvnum, 	pyd_carinvdate, 		std_number_adj, 		pyd_vendortopay, 
	--			pyd_vendorpay, 		pyd_remarks, 		stp_number, 			stp_mfh_sequence,		pyd_perdiem_exceeded, 
	--			pyd_carrierinvoice_aprv, pyd_carrierinvoice_rjct, pyd__aprv_rjct_comment, 			pyd_payment_date, 	pyd_payment_doc_number, 
	--			pyd_paid_indicator, 	pyd_paid_amount, 	pyd_createdby, 		pyd_createdon, 		stp_number_pacos, 
	--			pyd_expresscode, 		pyd_gst_amount, 	pyd_gst_flag, 			pyd_mileagetable, 	bill_override, 
	--			not_billed_reason, 	pyd_reg_time_qty,	pyt_otflag, 			pyd_ap_check_date, 	pyd_ap_check_number, 
	--			pyd_ap_check_amount, pyd_ap_vendor_id,	pyd_ap_updated_by)
	--			Values(
	--			@i_totalmsgs4,	0,					@segmento,			0,
	--			'TPR',						'PROVEEDO',		0,								'A',			'UNKNOWN',
	--			'VALECO',					@movNumber,		'%Vale de Combustible',	Null,			@litros,
	--			'FLT',						'FLT',			@precio,				@monto,		'Y',
	--			Null,							'MX$',			getdate(),					'HLD',				Null,
	--			Null,							'2049-12-31 23:59', 	'2049-12-31 23:59', 			Null,			Null,
	--			Null,							Null,				.0000,			0.0,					.0000,
	--			.0000,						getdate(),		1,					1,						Null,
	--			'NA',							0,					@orden,					.0000,			.0000,
	--			.0000,						'N',				'NADD', 	Null,					Null,
	--			Null,							Null,				Null,				Null,					Null,
	--			Null, 						Null,				getdate(),		Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					'UNKNOWN',	
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				'NADD',	getdate(),			Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null,				Null,					Null,		
	--			Null,							Null,				Null);

	print 'usuario: '+ cast(@usuario as nvarchar(30))
	update paydetail set pyd_createdby = @usuario where pyd_number = @i_totalmsgs4
	Return @i_totalmsgs4

end


GO
