SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE   PROCEDURE [dbo].[billing_validation_kriska_sp] (@ivh_invoicenumber varchar(12),
						@ErrorMessage varchar(255) output)
as

/**
 * 
 * NAME:
 * dbo.billing_validation_kriska_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Validates invoices on save that GST tax amount is correct 
 *  Used to trouble shoot an error where invalid tax amounts were saved.
 *
 * RETURNS:
 * err message if validation fails 
 *
 * RESULT SETS: 
 * N/A
 *
 * PARAMETERS:
 * 001 - @ivh_invoicenumber varchar(12),
 * 002 - @ErrorMessage varchar varchar(255) output
 *
 *  EDITS DONE
 *     if the invoice has a GST tax amount, check to see that the GST charge is equal to the sum of the taxable charges times the
 *    GST rate  
 *
 * REFERENCES:
 * CALLED BY billing_validation_sp if GI entry  'InvValidationProc' has 'billing_validation_kriska_sp' in gi_string1 field
 * 
 * REVISION HISTORY:
 * 4/13/07 - PTS 37076 DPETE created 
 * 6/12/07 37871 - DPETE custoemr does not wnat gst compute done is trip is not within the same country
 *
 **/
declare @v_ivhhdrnumber int,@v_taxablecharges money,@v_GSTcht varchar(8),@v_GSTAmount money,@v_gstrate money,@v_batchnbr int
declare @v_computedTax money,@v_origincountry varchar(50), @v_destcountry varchar(50),@V_originstate varchar(10),@v_deststate varchar(10)


select @v_ivhhdrnumber = ivh_hdrnumber,@v_originstate = ivh_originstate
,@v_deststate = ivh_deststate
 from invoiceheader where ivh_invoicenumber = @ivh_invoicenumber
select @v_GSTcht = cht_itemcode from chargetype where cht_basis = 'TAX' and cht_taxtable1 = 'Y'
select @V_origincountry = stc_country_c  from statecountry where stc_state_c = @V_originstate
select @V_destcountry = stc_country_c  from statecountry where stc_state_c = @v_deststate


select @ErrorMessage = ''
If @v_origincountry = @v_destcountry
BEGIN

  select @v_gstrate = min(round(tax_rate/100.00,4)) from taxrate where tax_type = 1 and tax_effectivedate <= getdate()
  and tax_expirationdate > getdate()
  select @v_gstrate = isnull(@v_gstrate,0.00)
  If @v_gstrate = 0 
   BEGIN
     EXEC @v_batchnbr =  getsystemnumber 'BATCHQ', NULL
      insert into tts_errorlog(err_batch,err_user_id,err_message,err_date,err_number,err_title,err_icon)
      values(@v_batchnbr,'Inv# '+@ivh_invoicenumber,'GST tax rate not found for billing validation proc',getdate(),1,'Failed Billing Validation proc','!')
      return
   END

  select @v_GSTAmount  = sum(round(isnull(ivd_charge,0.0),2)) 
  from invoicedetail 
  where ivh_hdrnumber = @v_ivhhdrnumber and cht_itemcode = @v_GSTcht

  If @v_GSTAmount <> 0
    BEGIN
     Select @v_taxablecharges = sum(round(isnull(ivd_charge,0.0),2) )
     from invoicedetail d
     where ivh_hdrnumber =  @v_ivhhdrnumber 
     and ivd_taxable1 = 'Y'
     and cht_itemcode <> @v_GSTcht

     select @v_computedTax = round((@v_taxablecharges *  @v_gstrate),2)

     If @v_GSTAmount  <> @v_computedTax
       BEGIN

        EXEC @v_batchnbr =  getsystemnumber 'BATCHQ', NULL
        select @ErrorMessage = 'Computed GST tax ( '+ convert(varchar(15),@v_taxablecharges)+' * '
        +convert(varchar(15),@v_gstrate)+' = '+
        +convert(varchar(15),@v_computedTax)
        +' ) not equal to actual taxes ( '+convert(varchar(15),@v_GSTAmount)+' )  ' 
        + ' (Log '+ convert(varchar(12),@v_batchnbr)+')'

        insert into tts_errorlog(err_batch,err_user_id,err_message,err_date,err_number,err_title,err_icon)
        values(@v_batchnbr,'Inv# '+@ivh_invoicenumber,Substring(@ErrorMessage,1,254),getdate(),1,'Failed Billing Validation proc','!')

        select @ErrorMessage = substring(@ErrorMessage,1,255)

      END
   END
END

Return
GO
GRANT EXECUTE ON  [dbo].[billing_validation_kriska_sp] TO [public]
GO
