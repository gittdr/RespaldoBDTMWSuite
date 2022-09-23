SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cadec_addacharge] (@ordnumber varchar(12),@chargetype varchar(8),@quantity float) 
As
/*   This proc is suppose to create an invoicedeatil record(Accessorial) for driver issued charges from the
     road with Cadec units.  The Cadec unit is loaded with valid charge types.  The unit sends back the
	order number, the charge type code and the quantity.  If the charge does not exist, add it.  Otherwise
	update it.  The following return codes are generated
	
	1 = Success
	-1 = Invoice has been printed or trasnferred
	-2 = Charge type passed form Cadec is not valid
	-3 = Could not get a system number for the invoicedetail table
	-4 = order number is not valid



   MODIFICATION LOG
DPETE Created /13/02 15133 for Gibsons

*/
Declare @return int, @code int, @ordhdrnumber int,@description varchar(30),@chtrate money,@chtunit varchar(6),
	@chtbasisunit varchar(6),@tax1 char(1),@tax2 char(1),@tax3 char(1),@tax4 char(1),@glnum varchar(32),
	@rateunit varchar(6),@chtclass varchar(6),@chtlhmin char(1),@chtlhrev char(1),@chtlhstl char(1),@chtlhprn char(1),@chtlhrpt char(1),
	@charge money,@key int,@hdrkey int, @oldcharge money,@rate money,@chtcurrunit varchar(6)

  Select @quantity = IsNull(@quantity,0)

	If Not Exists (Select ord_hdrnumber From orderheader Where ord_number = @ordnumber)
	Begin
	  Select @return = -4
	  GOTO ENDOFPROC
	END

/*If an invoiceheader exists for this order with an ivh_status of 'PRN' or 'XFR' 
then raise an error - trip has been invoiced */
   Select @code = max(code)
   From invoiceheader,labelfile
   Where ord_number = @ordnumber
   and labeldefinition = 'InvoiceStatus'
   and abbr = ivh_invoicestatus

   If @code >= 60 
	Begin   
	Select @return = -1
	GOTO ENDOFPROC -- invoice has been printed or transferred
	End

/*If the accessorial exists, then it will be updated. */ 
   Select @ordhdrnumber = ord_hdrnumber from orderheader where ord_number = @ordnumber
   Select @key = ivd_number,@hdrkey = ivh_hdrnumber,@rate=IsNull(ivd_rate,0.0),@oldcharge = Isnull(ivd_charge,0.0)
   From invoicedetail
   Where ord_hdrnumber = @ordhdrnumber
   And cht_itemcode = @chargetype

	Select @oldcharge = IsNull(@oldcharge,0)

  If @key is  null  -- invoicedetail does not exist
	Begin --  Add a record
		Select @description = cht_description,@chtrate = cht_rate, @chtunit = cht_unit,@chtbasisunit = cht_basisunit,@tax1=cht_taxtable1,@tax2=cht_taxtable2,
		@tax3=cht_taxtable3,@tax4=cht_taxtable4,@glnum=cht_glnum,@rateunit=cht_rateunit,@chtclass=cht_class,@chtlhmin = cht_lh_min,
		@chtlhrev = cht_lh_rev,@chtlhstl=cht_lh_stl,@chtlhprn=cht_lh_prn,@charge= Convert(money,@quantity * cht_rate),
		@chtcurrunit = cht_currunit
		From chargetype
		Where cht_itemcode = @chargetype

		If @chtunit is null  -- charge type is not valid 
		 Begin
		 Select @return = -2
		 GOTO ENDOFPROC
		 End

		Exec @key  = dbo.getsystemnumber 'INVDET',NULL
		If @key is Null
		 Begin
		 Select @return = -3
		 GOTO ENDOFPROC
		 End

		INSERT INTO invoicedetail ( ivh_hdrnumber, ivd_number, ivd_description, ivd_quantity, ivd_rate, ivd_charge, --1
		ivd_taxable1, ivd_taxable2, ivd_taxable3, ivd_taxable4, ivd_unit, ivd_glnum,   --2
		ord_hdrnumber, ivd_type, ivd_rateunit, ivd_itemquantity, ivd_subtotalptr, ivd_sequence,  --3
		 mfh_hdrnumber, cmp_id,   --4
		ivd_count, evt_number, ivd_reftype,ivd_refnum, ivd_volume, ivd_volunit,  --5
		 ivd_orig_cmpid,  cht_itemcode, cmd_code, ivd_sign, stp_number,  --6 
		cht_basisunit, ivd_fromord, cht_rollintolh, ivd_quantity_type, cht_class,  --7 
		ivd_mileagetable, ivd_charge_type, ivd_trl_rent, ivd_rate_type,   --8
		 fgt_number,ivd_billto ,cur_code,ivd_currencydate) --9
	-- add later	 cht_lh_min, cht_lh_rev,cht_lh_stl, cht_lh_prn, cht_lh_rpt)   --10
		VALUES (0, @key, @description, @quantity,@chtrate,@charge,  --1
		 @tax1,@tax2,@tax3,@tax4,@chtunit, @glnum,   --2
		@ordhdrnumber, 'LI', @rateunit, 0, 0, 999,  --3 
		0, 'UNKNOWN',   --4
		 0, 0,'REF','Cadec', 0, 'CUB',   --5 
		'UNKNOWN', @chargetype , 'UNKNOWN', 1, 0,   --6
		@chtbasisunit,  'Y', 0, 0, @chtclass,   --7
		'', 0, '', 0,  --8
		 0 ,'UNKNOWN',@chtcurrunit,getdate())  --9
 -- add later		@chtlhmin,@chtlhrev,@chtlhstl,@chtlhprn,@chtlhrpt) --10

	End
Else -- update existing record
  Begin
	Select @charge = Convert(money,@quantity * @rate) --compute here to use in incrementing totals below
	Update invoicedetail set ivd_quantity = @quantity ,  ivd_charge = @charge Where ivd_number = @key

  End

Select @return = 1
/* now you should update the total in the order and invoice */
If @hdrkey is not null
	Update invoiceheader set ivh_totalcharge = ivh_totalcharge + @charge - @oldcharge 
	Where ivh_hdrnumber = @hdrkey

Update orderheader set ord_accessorial_chrg  = (ord_accessorial_chrg + @charge - @oldcharge), ord_totalcharge = (ord_totalcharge + @charge - @oldcharge)
Where ord_hdrnumber = @ordhdrnumber

ENDOFPROC:
  Return @return


GO
GRANT EXECUTE ON  [dbo].[cadec_addacharge] TO [public]
GO
