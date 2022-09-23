SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[process_inv_acct_status_import]
AS
DECLARE @iasi_tran_id			INTEGER,
	@iasi_invoice_number		VARCHAR(12),
	@iasi_reject_reason_code	VARCHAR(6),
	@iasi_reject_reason		VARCHAR(255),
	@ivh_invoicestatus		VARCHAR(6),
	@process_error			VARCHAR(255),
	@label_count			SMALLINT,
	@Process_successful		SMALLINT,
	@new_crd_ivh_hdrnumber		INTEGER,
	@new_rbil_ivh_hdrnumber		INTEGER,
	@new_crd_invoicenumber		VARCHAR(12),
        @new_rbil_invoicenumber		VARCHAR(12),
	@old_ivh_hdrnumber		INTEGER,
	@ord_hdrnumber			INTEGER,
	@ascii				INTEGER,
	@pochar                         CHAR(1),
	@min_ivdseq			INTEGER,
	@new_ivdnum			INTEGER,
	@userid				VARCHAR(255)

EXECUTE gettmwuser @userid output

CREATE TABLE #tempheader
(
	temp_type			VARCHAR(6) NULL,
	ivh_invoicenumber 		VARCHAR(12) NULL, 
	ivh_billto			VARCHAR(8) NULL,
	ivh_terms 			VARCHAR(3) NULL, 
	ivh_totalcharge 		MONEY NULL,    
	ivh_shipper 			VARCHAR(8) NULL, 
	ivh_consignee 			VARCHAR(8) NULL, 
	ivh_originpoint 		VARCHAR(8) NULL,    
	ivh_destpoint 			VARCHAR(8) NULL, 
	ivh_invoicestatus 		VARCHAR(6) NULL, 
	ivh_origincity 			INTEGER NULL,     
	ivh_destcity 			INTEGER NULL, 
	ivh_originstate 		VARCHAR(6) NULL, 
	ivh_deststate 			VARCHAR(6) NULL,      
	ivh_originregion1 		VARCHAR(6) NULL, 
	ivh_destregion1 		VARCHAR(6) NULL, 
	ivh_supplier 			VARCHAR(8) NULL,       
	ivh_shipdate 			DATETIME NULL, 
	ivh_deliverydate 		DATETIME NULL, 
	ivh_revtype1 			VARCHAR(6) NULL,       
	ivh_revtype2 			VARCHAR(6) NULL, 
	ivh_revtype3 			VARCHAR(6) NULL, 
	ivh_revtype4 			VARCHAR(6) NULL, 
	ivh_totalweight 		FLOAT(15)  NULL, 
	ivh_totalpieces 		FLOAT(15) NULL, 
	ivh_totalmiles 			FLOAT(15) NULL,     
	ivh_currency 			VARCHAR(6) NULL,
	ivh_currencydate 		DATETIME NULL, 
	ivh_totalvolume 		FLOAT(15) NULL,    
	ivh_taxamount1 			MONEY NULL, 
	ivh_taxamount2 			MONEY NULL,       
	ivh_taxamount3 			MONEY NULL, 
	ivh_taxamount4 			MONEY NULL,
	ivh_transtype 			VARCHAR(6) NULL,
	ivh_creditmemo 			CHAR(1) NULL,     
	ivh_applyto 			VARCHAR(12) NULL, 
	ivh_printdate 			DATETIME NULL, 
	ivh_billdate 			DATETIME NULL, 
	ivh_lastprintdate 		DATETIME NULL,   
	ivh_hdrnumber 			INTEGER NULL, 
	ord_hdrnumber 			INTEGER NULL, 
	ivh_originregion2 		VARCHAR(6) NULL,  
	ivh_originregion3 		VARCHAR(6) NULL, 
	ivh_originregion4 		VARCHAR(6) NULL, 
	ivh_destregion2 		VARCHAR(6) NULL,    
	ivh_destregion3 		VARCHAR(6) NULL, 
	ivh_destregion4 		VARCHAR(6) NULL, 
	ivh_mbnumber 			INTEGER NULL, 
	ivh_remark 			VARCHAR(254) NULL, 
	ivh_driver 			VARCHAR(8) NULL, 
	ivh_driver2 			VARCHAR(8) NULL, 
	ivh_tractor 			VARCHAR(8) NULL,
	ivh_trailer 			VARCHAR(13) NULL, 
	mov_number 			INTEGER NULL, 
	ivh_edi_flag 			VARCHAR(30) NULL,
	ivh_freight_miles 		INTEGER NULL, 
	ivh_priority 			VARCHAR(6) NULL,
	ivh_low_temp 			INTEGER NULL,
	ivh_high_temp 			INTEGER NULL,
	ivh_order_by 			VARCHAR(8) NULL,
	tar_tarriffnumber 		VARCHAR(12) NULL, 
	tar_number 			INTEGER NULL, 
	ivh_user_id1 			VARCHAR(20) NULL, 
	ivh_user_id2 			VARCHAR(20) NULL, 
	ivh_ref_number 			VARCHAR(30) NULL,
	ivh_bookyear 			INTEGER NULL,
	ivh_bookmonth 			INTEGER NULL,
	tar_tariffitem 			VARCHAR(12) NULL,
	ivh_mbstatus 			VARCHAR(6) NULL,
	ord_number 			VARCHAR(12) NULL,
	ivh_quantity 			FLOAT(15) NULL,
	ivh_rate 			MONEY  NULL, 
	ivh_charge 			MONEY NULL, 
	cht_itemcode 			VARCHAR(6) NULL,
	ivh_splitbill_flag 		CHAR(1) NULL,
	ivh_company 			VARCHAR(8) NULL,
	ivh_carrier 			VARCHAR(8) NULL,
	ivh_archarge 			MONEY NULL, 
	ivh_arcurrency 			VARCHAR(6) NULL,
	ivh_loadtime 			INTEGER NULL,
	ivh_unloadtime 			INTEGER NULL,
	ivh_drivetime 			INTEGER NULL,
	ivh_totaltime 			INTEGER NULL,
	ivh_rateby 			VARCHAR(1) NULL,
	ivh_unit 			VARCHAR(6) NULL,
	ivh_revenue_date 		DATETIME NULL,
	ivh_batch_id			VARCHAR(10) NULL,
	ivh_stopoffs 			SMALLINT NULL,
	ivh_quantity_type 		INTEGER NULL,
	ivh_charge_type 		SMALLINT NULL,
	ivh_originzipcode 		VARCHAR(10) NULL, 
	ivh_destzipcode 		VARCHAR(10) NULL,
	ivh_ratingquantity 		FLOAT(15) NULL,
	ivh_ratingunit 			VARCHAR(6)null,
	ivh_definition	 		VARCHAR(6) NULL,
	ivh_applyto_definition 		VARCHAR(6) NULL,
	ivh_hideshipperaddr 		CHAR(1) NULL,
	ivh_hideconsignaddr 		CHAR(1) NULL,
	ivh_showshipper 		VARCHAR(8) NULL,
	ivh_showcons 			VARCHAR(8) NULL,
	ivh_mileage_adjustment 		DECIMAL(9,1) NULL,
	ivh_paperworkstatus 		VARCHAR(6) NULL,
	ivh_order_cmd_code 		VARCHAR(8) NULL,
	ivh_allinclusiveCHARge		MONEY	null,
	ivh_reftype 			VARCHAR(6) NULL,
	ivh_attention 			VARCHAR(254) NULL,
	ivh_rate_type 			SMALLINT NULL,
	ivh_paperwork_override 		CHAR(1) NULL,
	ivh_cmrbill_link 		INTEGER NULL,
	inv_revenue_pay_fix 		INTEGER NULL,
	inv_revenue_pay 		MONEY NULL,
	ivh_billto_parent 		VARCHAR(8),
	ivh_block_printing 		CHAR(1) NULL,
	ivh_custdoc 			INTEGER NULL,
	ivh_entryport 			VARCHAR (8) NULL,
	ivh_exitport 			VARCHAR (8) NULL,
	ivh_mileage_adj_pct 		DECIMAL(9,2) NULL,
	ivh_dimfactor 			DECIMAL(12,4) NULL,
	ivh_trlconfiguration 		VARCHAR(6) NULL,
	ivh_charge_type_lh 		SMALLINT NULL,
	ivh_booked_revtype1 		VARCHAR(12) NULL,
	ivh_misc_number			VARCHAR(12) NULL,
	ivh_exchangerate 		DECIMAL(19,4)  NULL ,
	ivh_loaded_distance 		FLOAT NULL, 
	ivh_empty_distance 		FLOAT NULL, 
	ivh_leaseid			INTEGER	NULL,
	ivh_leaseperiodenddate 		DATETIME NULL,
	ivh_gp_gl_postdate 		DATETIME NULL,
	ivh_nomincharges 		CHAR(1) NULL,
	car_key 			INTEGER NULL
)

CREATE TABLE #tempdetail
(
	temp_type			VARCHAR(6) NULL,
	ivh_hdrnumber  			INTEGER NULL,     
	ivd_number  			INTEGER NULL,     
	ivd_description  		VARCHAR(60) NULL,     
	ivd_quantity  			DECIMAL(18,6) NULL,     
	ivd_rate  			MONEY NULL,     
	ivd_charge  			MONEY NULL,     
	ivd_taxable1  			CHAR(1) NULL,     
	ivd_taxable2 			CHAR(1) NULL,     
	ivd_taxable3  			CHAR(1) NULL,     
	ivd_taxable4  			CHAR(1) NULL,     
	ivd_unit  			VARCHAR(6) NULL,     
	cur_code  			VARCHAR(6) NULL,     
	ivd_currencydate 		DATETIME NULL,     
	ivd_glnum  			VARCHAR(32) NULL,     
	ord_hdrnumber  			INTEGER NULL,     
	ivd_type  			VARCHAR(6) NULL,     
	ivd_rateunit  			VARCHAR(6) NULL,     
	ivd_billto  			VARCHAR(8) NULL,     
	ivd_itemquantity 		FLOAT(15) NULL,     
	ivd_subtotalptr  		INTEGER NULL,     
	ivd_sequence  			INTEGER NULL,     
	ivd_invoicestatus 		VARCHAR(6) NULL,     
	mfh_hdrnumber  			INTEGER NULL,     
	ivd_refnum  			VARCHAR(30) NULL,     
	cmp_id   			VARCHAR(8) NULL,     
	ivd_distance  			FLOAT NULL,     
	ivd_distunit  			VARCHAR(6) NULL,     
	ivd_wgt   			DECIMAL(18,6) NULL,  
	ivd_wgtunit  			VARCHAR(6) NULL,     
	ivd_count 			DECIMAL(18,2) NULL,     
	evt_number  			INTEGER NULL,     
	ivd_reftype  			VARCHAR(6) NULL,     
	ivd_volume  			DECIMAL(18,6) NULL,     
	ivd_volunit  			VARCHAR(6) NULL,     
	ivd_orig_cmpid  		VARCHAR(8) NULL,     
	ivd_countunit  			VARCHAR(6) NULL,     
	cht_itemcode  			VARCHAR(6) NULL,     
	cmd_code  			VARCHAR(8) NULL,     
	ivd_sign  			SMALLINT NULL,     
	ivd_length  			MONEY NULL,     
	ivd_lengthunit  		VARCHAR(6) NULL,     
	ivd_width  			MONEY NULL,     
	ivd_widthunit  			VARCHAR(6) NULL,     
	ivd_height  			MONEY NULL,     
	ivd_heightunit  		VARCHAR(6) NULL,    
	stp_number  			INTEGER  NULL,    
	cht_basisunit  			VARCHAR(6) NULL,    
	ivd_remark  			VARCHAR(255) NULL,    
	tar_number  			INTEGER NULL,    
	tar_tariffnumber 		VARCHAR(12) NULL,    
	tar_tariffitem  		VARCHAR(12) NULL,    
	ivd_fromord  			CHAR(1) NULL,    
	cht_rollintolh         	 	INTEGER NULL,    
	fgt_number  			INTEGER NULL,    
	ivd_quantity_type 		INTEGER NULL,    
	cht_class  			VARCHAR(6) NULL,    
	ivd_mileagetable 		CHAR(1) NULL,    
	ivd_charge_type  		SMALLINT NULL,    
	ivd_trl_rent  			VARCHAR(13) NULL,    
	ivd_trl_rent_start 		DATETIME NULL,    
	ivd_trl_rent_end  		DATETIME NULL,    
	ivd_rate_type 			SMALLINT NULL,    
	cht_lh_min 	 		CHAR(1) NULL,    
	cht_lh_rev  			CHAR(1) NULL,    
	cht_lh_stl  			CHAR(1) NULL,    
	cht_lh_prn  			CHAR(1) NULL,    
	cht_lh_rpt  			CHAR(1) NULL,  
	ivd_paylgh_number 		INTEGER NULL,  
	ivd_tariff_type	 		CHAR(1) NULL,  
	ivd_taxid 			VARCHAR(15) NULL,  
	ivd_ordered_volume 		FLOAT NULL,  
	ivd_ordered_loadingmeters 	FLOAT NULL,    
	ivd_ordered_count 		FLOAT NULL,    
	ivd_ordered_weight 		FLOAT NULL,  
	ivd_loadingmeters 		FLOAT NULL,  
	ivd_loadingmeters_unit 		VARCHAR(6)  NULL,  
	ivd_revtype1 			VARCHAR(6) NULL,
	ivd_hide			CHAR(1) NULL,
	ivd_tollcost 			MONEY NULL,
	ivd_ARTaxAuth 			VARCHAR(6) NULL,
	ivd_tax_basis 			MONEY NULL,
	ivd_actual_quantity 		FLOAT NULL,
	ivd_actual_unit 		VARCHAR(6) NULL, 
	fgt_supplier 			VARCHAR(8) NULL,
    	ivd_loaded_distance 		FLOAT NULL,
	ivd_empty_distance 		FLOAT NULL,
	ivd_paid_indicator 		CHAR(1) NULL,
	ivd_paid_amount 		MONEY NULL,
	ivd_leaseassetid 		INTEGER NULL,			
	ivd_maskFromRating 		CHAR(1) NULL,
	ivd_car_key 			INTEGER NULL,
	ivd_showas_cmpid 		VARCHAR(8) NULL
)

DECLARE curs1 CURSOR FOR
   SELECT iasi_tran_id, iasi_invoice_number, iasi_reject_reason_code,
          iasi_reject_reason
     FROM inv_acct_status_import
    WHERE iasi_status IN (0, 9)

OPEN curs1
FETCH NEXT FROM curs1 
 INTO @iasi_tran_id, @iasi_invoice_number, @iasi_reject_reason_code,
      @iasi_reject_reason

WHILE @@FETCH_STATUS = 0
BEGIN
   --Check for error conditions
   SET @process_successful = 1
   SELECT @ivh_invoicestatus = ivh_invoicestatus
     FROM invoiceheader
    WHERE ivh_invoicenumber = @iasi_invoice_number

   IF @ivh_invoicestatus IS NULL
   BEGIN
      SET @process_successful = 0
      SET @process_error = 'Inovice does not exist'
      GOTO PROCESS_ERROR
   END

   IF @ivh_invoicestatus <> 'XFR'
   BEGIN
      SET @process_successful = 0
      SET @process_error = 'Invoice is not in a transferred status'
      GOTO PROCESS_ERROR
   END

   SET @label_count = 0
   SELECT @label_count = Count(*)
     FROM labelfile
    WHERE labeldefinition = 'CreditMemoReason' AND
          abbr = @iasi_reject_reason_code
   IF @label_count = 0
   BEGIN
      SET @process_successful = 0
      SET @process_error = 'Credit Memo reject reason not in labelfile table'
      GOTO PROCESS_ERROR
   END

   --get new invoicenumbers
   SET @ascii = ASCII(RIGHT(@iasi_invoice_number,1))
   SET @ascii = @ascii + 1
   SET @pochar = CHAR(@ascii)
   SET @new_crd_invoicenumber = LEFT(@iasi_invoice_number, LEN(@iasi_invoice_number) - 1) + @pochar
   SET @ascii = ASCII(RIGHT(@new_crd_invoicenumber, 1))
   SET @ascii = @ascii + 1
   SET @pochar = CHAR(@ascii)
   SET @new_rbil_invoicenumber = LEFT(@new_crd_invoicenumber, LEN(@new_crd_invoicenumber) - 1) + @pochar
   --Check to make sure new invoice numbers are not already in the invoice table
   IF EXISTS (SELECT ivh_invoicenumber
                FROM invoiceheader
               WHERE ivh_invoicenumber = @new_crd_invoicenumber)
   BEGIN
      SET @process_successful = 0
      SET @process_error = 'Credit Memo ' + @new_crd_invoicenumber + 
                           ' already exists on file for invoice ' + @iasi_invoice_number
      GOTO PROCESS_ERROR
   END
   IF EXISTS (SELECT ivh_invoicenumber
                FROM invoiceheader
               WHERE ivh_invoicenumber = @new_rbil_invoicenumber)
   BEGIN
      SET @process_successful = 0
      SET @process_error = 'Rebill ' + @new_rbil_invoicenumber + 
                           ' already exists on file for invoice ' + @iasi_invoice_number
      GOTO PROCESS_ERROR
   END

   --Initialize temp tables
   DELETE FROM #tempheader
   DELETE FROM #tempdetail

   --get new ivh_hdrnumbers
   EXECUTE @new_crd_ivh_hdrnumber = getsystemnumber 'INVHDR', ''
   EXECUTE @new_rbil_ivh_hdrnumber = getsystemnumber 'INVHDR', ''

   --insert copy of invoice into tempheader for the credit memo
   INSERT INTO #tempheader
      SELECT 'CRD', ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key
        FROM invoiceheader
       WHERE ivh_invoicenumber = @iasi_invoice_number

   SELECT @old_ivh_hdrnumber = ivh_hdrnumber,
          @ord_hdrnumber = ord_hdrnumber
     FROM #tempheader
   
   --insert copy of invoice into tempheader for the rebill
   INSERT INTO #tempheader
      SELECT 'RBIL', ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key
        FROM invoiceheader
       WHERE ivh_invoicenumber = @iasi_invoice_number

   --Update the info for the credit memo invoiceheader
   UPDATE #tempheader
      SET ivh_hdrnumber = @new_crd_ivh_hdrnumber,
          ivh_invoicenumber = @new_crd_invoicenumber,
          ivh_invoicestatus = 'PRN',
          ivh_mbstatus = 'PRN',
          ivh_creditmemo = 'Y',
          ivh_definition = 'CRD',
          ivh_billdate = GETDATE(),
          ivh_cmrbill_link = @old_ivh_hdrnumber,
          ivh_applyto = @iasi_invoice_number,
          ivh_lastprintdate = NULL,
          ivh_bookyear = NULL,
          ivh_bookmonth = NULL,
          ivh_mbnumber = 0,
          ivh_totalcharge = ivh_totalcharge * -1,
          ivh_totalweight = ivh_totalweight * -1,
          ivh_totalpieces = ivh_totalpieces * -1,
          ivh_quantity = ivh_quantity * -1,
          ivh_charge = ivh_charge * -1,
          ivh_archarge = ivh_archarge * -1
    WHERE temp_type = 'CRD'

   --Update the info for the rebill invoiceheader
   UPDATE #tempheader
      SET ivh_hdrnumber = @new_rbil_ivh_hdrnumber,
          ivh_invoicenumber = @new_rbil_invoicenumber,
          ivh_invoicestatus = 'HLD',
          ivh_mbstatus = 'HLD',
          ivh_definition = 'RBIL',
          ivh_billdate = GETDATE(),
          ivh_cmrbill_link = @old_ivh_hdrnumber,
          ivh_applyto = @new_rbil_invoicenumber,
          ivh_lastprintdate = NULL,
          ivh_bookyear = NULL,
          ivh_bookmonth = NULL,
          ivh_mbnumber = 0
    WHERE temp_type = 'RBIL'

   --Insert copy of invoice details for credit memo into tempdetail
   INSERT INTO #tempdetail
      SELECT 'CRD', ivh_hdrnumber, ivd_number,	ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid
        FROM invoicedetail
       WHERE ivh_hdrnumber = @old_ivh_hdrnumber
      ORDER BY ivd_sequence

   --Insert copy of invoice details for rebill into tempdetail
   INSERT INTO #tempdetail
      SELECT 'RBIL', ivh_hdrnumber, ivd_number,	ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid
        FROM invoicedetail
       WHERE ivh_hdrnumber = @old_ivh_hdrnumber
      ORDER BY ivd_sequence

   --Get new ivd_numbers for the credit memo details
   SET @min_ivdseq = 0
   WHILE 1=1
   BEGIN
      SELECT @min_ivdseq = MIN(ivd_sequence)
        FROM #tempdetail
       WHERE temp_type = 'CRD' AND
             ivd_sequence > @min_ivdseq

      IF @min_ivdseq IS NULL
         BREAK

      EXECUTE @new_ivdnum = getsystemnumber 'INVDET', ''
      UPDATE #tempdetail
         SET ivd_number = @new_ivdnum
       WHERE temp_type = 'CRD' AND
             ivd_sequence = @min_ivdseq
   END

   --Get new ivd_numbers for the rebill details
   SET @min_ivdseq = 0
   WHILE 1=1
   BEGIN
      SELECT @min_ivdseq = MIN(ivd_sequence)
        FROM #tempdetail
       WHERE temp_type = 'RBIL' AND
             ivd_sequence > @min_ivdseq

      IF @min_ivdseq IS NULL
         BREAK

      EXECUTE @new_ivdnum = getsystemnumber 'INVDET', ''
      UPDATE #tempdetail
         SET ivd_number = @new_ivdnum
       WHERE temp_type = 'RBIL' AND
             ivd_sequence = @min_ivdseq
   END

   --Update the invoice details for the credit memo
   UPDATE #tempdetail
      SET ivh_hdrnumber = @new_crd_ivh_hdrnumber,
          ivd_quantity = ivd_quantity * -1,
          ivd_charge = ivd_charge * -1,
          ivd_wgt = ivd_wgt * -1,
          ivd_count = ivd_count * -1,
          ivd_volume = ivd_volume * -1
    WHERE temp_type = 'CRD'

   --Update the invoice details for the rebill
   UPDATE #tempdetail
      SET ivh_hdrnumber = @new_rbil_ivh_hdrnumber
    WHERE temp_type = 'RBIL'
   
   --Begin a transaction and start to insert the temp records into the database tables
   BEGIN TRAN

   --Insert the new credit memo into the invoiceheader table   
   INSERT INTO invoiceheader 
            (ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key)
      SELECT ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key 
        FROM #tempheader
       WHERE temp_type = 'CRD'

   --Check for insert error
   IF @@ERROR <> 0
   BEGIN
      SET @process_successful = -1
      SET @process_error = 'Unable to insert credit memo into the invoiceheader table'
      GOTO PROCESS_ERROR
   END

   --Insert the new credit memo details into the invoicedetail table
   INSERT INTO invoicedetail
            (ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid)
      SELECT ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid
        FROM #tempdetail
       WHERE temp_type = 'CRD'

   --Check for insert error
   IF @@ERROR <> 0
   BEGIN
      SET @process_successful = -1
      SET @process_error = 'Unable to insert credit memo details into the invoicedetail table'
      GOTO PROCESS_ERROR
   END

   --Insert a row into the creditmemo_reason table for this credit memo
   INSERT INTO creditmemo_reason 
      (ivh_invoicenumber, cmr_reason, ord_hdrnumber, cmr_original_invoicenumber,
       cmr_applyto_invoicenumber, cmr_comments, cmr_userid, cmr_datecreated)
      VALUES
      (@new_crd_invoicenumber, @iasi_reject_reason_code, @ord_hdrnumber, @iasi_invoice_number,
       @iasi_invoice_number, @iasi_reject_reason, @userid, GETDATE())
   
   --Check for insert error
   IF @@ERROR <> 0
   BEGIN
      SET @process_successful = -1
      SET @process_error = 'Unable to insert credit memo reason record into creditmemo_reason table'
      GOTO PROCESS_ERROR
   END

   --Insert the new rebill into the invoiceheader table   
   INSERT INTO invoiceheader 
            (ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key)
      SELECT ivh_invoicenumber, ivh_billto, ivh_terms, ivh_totalcharge,
             ivh_shipper, ivh_consignee, ivh_originpoint, ivh_destpoint, 
             ivh_invoicestatus, ivh_origincity, ivh_destcity, ivh_originstate, 
             ivh_deststate, ivh_originregion1, ivh_destregion1, ivh_supplier, 
             ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2,
             ivh_revtype3, ivh_revtype4, ivh_totalweight, ivh_totalpieces,
             ivh_totalmiles, ivh_currency, ivh_currencydate, ivh_totalvolume,
             ivh_taxamount1, ivh_taxamount2, ivh_taxamount3, ivh_taxamount4,
             ivh_transtype, ivh_creditmemo, ivh_applyto, ivh_printdate,
             ivh_billdate, ivh_lastprintdate, ivh_hdrnumber, ord_hdrnumber, 
             ivh_originregion2, ivh_originregion3, ivh_originregion4, ivh_destregion2, 
             ivh_destregion3, ivh_destregion4, ivh_mbnumber, ivh_remark, 
             ivh_driver, ivh_driver2, ivh_tractor, ivh_trailer,
             mov_number, ivh_edi_flag, ivh_freight_miles, ivh_priority,
             ivh_low_temp, ivh_high_temp, ivh_order_by, tar_tarriffnumber, 
             tar_number, ivh_user_id1, ivh_user_id2, ivh_ref_number, 
             ivh_bookyear, ivh_bookmonth, tar_tariffitem, ivh_mbstatus, 
             ord_number, ivh_quantity, ivh_rate, ivh_charge, 
             cht_itemcode, ivh_splitbill_flag, ivh_company, ivh_carrier, 
             ivh_archarge, ivh_arcurrency, ivh_loadtime, ivh_unloadtime, 
             ivh_drivetime, ivh_totaltime, ivh_rateby, ivh_unit, 
             ivh_revenue_date, ivh_batch_id, ivh_stopoffs, ivh_quantity_type, 
             ivh_charge_type, ivh_originzipcode, ivh_destzipcode, ivh_ratingquantity, 
             ivh_ratingunit, ivh_definition, ivh_applyto_definition, ivh_hideshipperaddr, 
             ivh_hideconsignaddr, ivh_showshipper, ivh_showcons, ivh_mileage_adjustment, 
             ivh_paperworkstatus, ivh_order_cmd_code, ivh_allinclusivecharge, 
             ivh_reftype, ivh_attention, ivh_rate_type, ivh_paperwork_override, 
             ivh_cmrbill_link, inv_revenue_pay_fix, inv_revenue_pay, ivh_billto_parent, 
             ivh_block_printing, ivh_custdoc, ivh_entryport, ivh_exitport, 
             ivh_mileage_adj_pct, ivh_dimfactor, ivh_trlconfiguration, ivh_charge_type_lh, 
             ivh_booked_revtype1, ivh_misc_number, ivh_exchangerate, ivh_loaded_distance, 
             ivh_empty_distance, ivh_leaseid, ivh_leaseperiodenddate, ivh_gp_gl_postdate, 
             ivh_nomincharges, car_key 
        FROM #tempheader
       WHERE temp_type = 'RBIL'

   --Check for insert error
   IF @@ERROR <> 0
   BEGIN
      SET @process_successful = -1
      SET @process_error = 'Unable to insert rebill into the invoiceheader table'
      GOTO PROCESS_ERROR
   END

   --Insert the new rebill details into the invoicedetail table
   INSERT INTO invoicedetail
            (ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid)
      SELECT ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity,     
	     ivd_rate, ivd_charge, ivd_taxable1, ivd_taxable2,     
	     ivd_taxable3, ivd_taxable4, ivd_unit, cur_code,     
	     ivd_currencydate, ivd_glnum, ord_hdrnumber, ivd_type,     
	     ivd_rateunit, ivd_billto, ivd_itemquantity, ivd_subtotalptr,     
	     ivd_sequence, ivd_invoicestatus, mfh_hdrnumber, ivd_refnum,     
	     cmp_id, ivd_distance, ivd_distunit, ivd_wgt,  
	     ivd_wgtunit, ivd_count, evt_number, ivd_reftype,     
	     ivd_volume, ivd_volunit, ivd_orig_cmpid, ivd_countunit,     
	     cht_itemcode, cmd_code, ivd_sign, ivd_length,     
	     ivd_lengthunit, ivd_width, ivd_widthunit, ivd_height,     
	     ivd_heightunit, stp_number, cht_basisunit, ivd_remark,    
	     tar_number, tar_tariffnumber, tar_tariffitem, ivd_fromord,    
	     cht_rollintolh, fgt_number, ivd_quantity_type, cht_class,    
	     ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_trl_rent_start,    
	     ivd_trl_rent_end, ivd_rate_type, cht_lh_min, cht_lh_rev,    
	     cht_lh_stl, cht_lh_prn, cht_lh_rpt, ivd_paylgh_number,  
	     ivd_tariff_type, ivd_taxid, ivd_ordered_volume, ivd_ordered_loadingmeters,    
	     ivd_ordered_count, ivd_ordered_weight, ivd_loadingmeters, ivd_loadingmeters_unit,  
	     ivd_revtype1, ivd_hide, ivd_tollcost, ivd_ARTaxAuth,
	     ivd_tax_basis, ivd_actual_quantity, ivd_actual_unit, fgt_supplier,
    	     ivd_loaded_distance, ivd_empty_distance, ivd_paid_indicator, ivd_paid_amount,
	     ivd_leaseassetid, ivd_maskFromRating, ivd_car_key, ivd_showas_cmpid
        FROM #tempdetail
       WHERE temp_type = 'RBIL'

   --Check for insert error
   IF @@ERROR <> 0
   BEGIN
      SET @process_successful = -1
      SET @process_error = 'Unable to insert rebill details into the invoicedetail table'
      GOTO PROCESS_ERROR
   END

   PROCESS_ERROR:
   IF @process_successful = 0
   BEGIN
      UPDATE inv_acct_status_import
         SET iasi_processed_dt = GETDATE(),
             iasi_status = 9,
             iasi_error_msg = @process_error
       WHERE iasi_tran_id = @iasi_tran_id
   END
   
   If @process_successful = -1
   BEGIN
      ROLLBACK TRAN
      UPDATE inv_acct_status_import
         SET iasi_processed_dt = GETDATE(),
             iasi_status = 9,
             iasi_error_msg = @process_error
       WHERE iasi_tran_id = @iasi_tran_id
   END

   IF @process_successful = 1
   BEGIN
      UPDATE inv_acct_status_import
         SET iasi_processed_dt = GETDATE(),
             iasi_status = 1,
             iasi_error_msg = NULL
       WHERE iasi_tran_id = @iasi_tran_id
      COMMIT TRAN
   END


   FETCH NEXT FROM curs1 
    INTO @iasi_tran_id, @iasi_invoice_number, @iasi_reject_reason_code,
         @iasi_reject_reason
END

CLOSE curs1
DEALLOCATE curs1

GO
GRANT EXECUTE ON  [dbo].[process_inv_acct_status_import] TO [public]
GO
