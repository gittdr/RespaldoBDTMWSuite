SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- Invoice_Test


--if exists (select * from sysobjects where id = object_id('dbo.SSRS_RB_INVOICE_04') and sysstat & 0xf = 4)
--	drop procedure dbo.SSRS_RB_INVOICE_04
--GO

-- exec SSRS_RB_INVOICE_04 1427,1,106,'4/1/2013'

create procedure [dbo].[SSRS_RB_INVOICE_04](@invoice_nbr  	int,@copies		int,@ivs_number	int,@billdate	datetime)
as 

declare @printcount as int
declare @ret_value as int
declare @invoice as int
declare @rollintoLHAmt money
declare @rateconvertion float

set @printcount = 1
set @ret_value = 1
set @invoice = @invoice_nbr

-------------------- Bill to Mailing Address Section -----------------------

declare @Bill_Address as table 
	([Invoice Header Bill To Name] varchar(100),
	 [Invoice Header Bill To Add1] varchar(100),
	 [Invoice Header Bill To Add2] varchar(100),
	 [Invoice Header Bill To Add3] varchar(100),
	 [Invoice Header Bill To CityStZip] varchar(100),
	 [Invoice Header Bill To Alternate Company Id] varchar(25),
	 [Invoice Header Bill To Contact] varchar(30)
	)

declare @cmp_mailto varchar(30)

select @cmp_mailto = isnull(cmp_mailto_name,'')
	from invoiceheader
		inner join company c on c.cmp_id = invoiceheader.ivh_billto
	where	invoiceheader.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
			Case IsNull(c.cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse invoiceheader.ivh_terms End)
			And invoiceheader.ivh_charge <> Case IsNull(c.cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else invoiceheader.ivh_charge + 1.00 End	
			And	ivh_hdrnumber = @invoice

if IsNull(@cmp_mailto,'') = ''
	-- No MailTo, use main address	
	begin
		insert into @Bill_Address
		select
			cmp_name,
			cmp_address1,
			cmp_address2,
			cmp_address3,
			cty_name + ', ' + cty_state + ' ' + IsNull(cmp_zip,''),
			cmp_altid,
			cmp_contact 
		from invoiceheader 
			inner join company c on c.cmp_id = ivh_billto
			inner join city cty on cty.cty_code = c.cmp_city
		where ivh_hdrnumber = @invoice
	end
else
	-- MailTo address	
	begin
		insert into @Bill_Address
		select
			cmp_mailto_name,
			cmp_mailto_Address1,
			cmp_mailto_address2,
			'',
			cty_name + ', ' + cty_state + ' ' + IsNull(cmp_mailto_zip,''),
			cmp_altid,
			cmp_contact			
		from invoiceheader 
			inner join company c on c.cmp_id = ivh_billto
			inner join city cty on cty.cty_code = c.cmp_mailto_city
		where ivh_hdrnumber = @invoice
	end

------------------------ End BillTo mailing address  -----------------------
------------------------------ Main Select ---------------------------------

select 

	ivh.ivh_invoicenumber [Invoice Header Invoice Number],	
	ivh.ivh_hdrnumber [Invoice Header Number],
	ivh.ord_number [Invoice Header Order Number],
	ivh.ord_hdrnumber [Invoice Header Order Header Number],
	ivh.ivh_billto [Invoice Header Bill To],
	[Invoice Header Bill To Name],
	[Invoice Header Bill To Add1],
	[Invoice Header Bill To Add2],
	[Invoice Header Bill To Add3],
	[Invoice Header Bill To CityStZip],
	[Invoice Header Bill To Alternate Company Id],
	[Invoice Header Bill To Contact],
	ivh.ivh_terms [Invoice Header Terms],
	la_terms.name [Labelfile Terms Name],
	ivh.ivh_totalcharge [Invoice Header Total Charge],
	ivh.ivh_shipper [Invoice Header Shipper],
	sc.cmp_name [Shipper Name],
	Case ivh.ivh_hideshipperaddr when 'Y' then '' else sc.cmp_address1 end [Shipper Add1],
	Case ivh.ivh_hideshipperaddr when 'Y' then '' else sc.cmp_address2 end [Shipper Add2],
	Case ivh.ivh_shipper when 'UNKNOWN' then oc_cty.cty_name + ', ' + oc_cty.cty_state + ' ' + IsNull(oc.cmp_zip,'') else sc_cty.cty_name + ', ' + sc_cty.cty_state + ' ' + IsNull(sc.cmp_zip,'') end [Shipper CityStZip],
	sc.cmp_geoloc [Shipper Geoloc],
	ivh.ivh_consignee [Invoice Header Consignee],
	cc.cmp_name [Consignee Name],
	Case ivh.ivh_hideconsignaddr when 'Y' then '' else cc.cmp_address1 end [Consignee Add1],
	Case ivh.ivh_hideconsignaddr when 'Y' then '' else cc.cmp_address2 end [Consignee Add2],
	Case ivh.ivh_consignee when 'UNKNOWN' then dc_cty.cty_name + ', ' + dc_cty.cty_state + ' ' + IsNull(dc.cmp_zip,'') else cc_cty.cty_name + ', ' + cc_cty.cty_state + ' ' + IsNull(cc.cmp_zip,'') end [Consignee CityStZip],
	cc.cmp_geoloc [Consignee Geoloc],
	ivh.ivh_originpoint [Invoice Header Origin],
	oc.cmp_name [Origin Company Name],
	oc.cmp_address1 [Origin Add1],
	oc.cmp_address2 [Origin Add2],
	oc_cty.cty_name + ', ' + oc_cty.cty_state + ' ' + IsNull(oc.cmp_zip,'') [Origin CityStZip],
	ivh.ivh_destpoint [Invoice Header Destination],
	dc.cmp_name [Destination Company Name],
	dc.cmp_address1 [Destination Add1],
	dc.cmp_address2 [Destination Add2],
	dc_cty.cty_name + ', ' + dc_cty.cty_state + ' ' + IsNull(dc.cmp_zip,'') [Destination CityStZip],
	ivh.ivh_invoicestatus [Invoice Header InvoiceStatus],
	ivh.ivh_origincity [Invoice Header Origin City],
	ivh.ivh_destcity [Invoice Header Destination City],
	ivh.ivh_originstate [Invoice Header Origin State],
	ivh.ivh_deststate [Invoice Header Destination State],
	ivh.ivh_originregion1 [Invoice Header Origin Region 1],
	ivh.ivh_originregion2 [Invoice Header Origin Region 2],
	ivh.ivh_originregion3 [Invoice Header Origin Region 3],
	ivh.ivh_originregion4 [Invoice Header Origin Region 4],
	ivh.ivh_destregion1 [Invoice Header Destination Region 1],
	ivh.ivh_destregion2 [Invoice Header Destination Region 2],
	ivh.ivh_destregion3 [Invoice Header Destination Region 3],
	ivh.ivh_destregion4 [Invoice Header Destination Region 4],
	ivh.ivh_supplier [Invoice Header Supplier],
	ivh.ivh_shipdate [Invoice Header Ship Date],
	ivh.ivh_deliverydate [Invoice Header Delivery Date],
	ivh.ivh_revtype1 [Invoice Header Rev Type 1],
	ivh.ivh_revtype2 [Invoice Header Rev Type 2],
	ivh.ivh_revtype3 [Invoice Header Rev Type 3],
	ivh.ivh_revtype4 [Invoice Header Rev Type 4],
	ivh.ivh_totalweight [Invoice Header Total Weight],
	ivh.ivh_totalpieces [Invoice Header Total Pieces],
	ivh.ivh_totalmiles [Invoice Header Total Miles],
	ivh.ivh_currency [Invoice Header Currency],
	ivh.ivh_currencydate [Invoice Header Currency Date],
	ivh.ivh_totalvolume [Invoice Header Total Volume],
	ivh.ivh_taxamount1 [Invoice Header Tax Amount 1],
	ivh.ivh_taxamount2 [Invoice Header Tax Amount 2],
	ivh.ivh_taxamount3 [Invoice Header Tax Amount 3],
	ivh.ivh_taxamount4 [Invoice Header Tax Amount 4],
	ivh.ivh_transtype [Invoice Header Transaction Type],
	ivh.ivh_creditmemo [Invoice Header Credit Memo],
	ivh.ivh_applyto [Invoice Header Apply To],
	ivh.ivh_printdate [Invoice Header Print Date],
	case @billdate when '01/01/1950' then ivh.ivh_billdate
    else
         case ivh.ivh_invoicestatus when 'PRN' then ivh.ivh_billdate
                                    when 'XFR' then ivh.ivh_billdate
                                    else @billdate
         end
    end [Invoice Header Bill Date],
	ivh.ivh_lastprintdate [Invoice Header Last Print Date],
	ivh.mfh_hdrnumber [Invoice Header MFH Number],
	ivh.ivh_remark [Invoice Header Remark],
	ivh.ivh_driver [Invoice Header Driver],
	ivh.ivh_tractor [Invoice Header Tractor],
	ivh.ivh_trailer [Invoice Header Trailor],
	ivh.ivh_user_id1 [Invoice Header User Id 1],
	ivh.ivh_user_id2 [Invoice Header User Id 2],
	ivh.ivh_ref_number [Invoice Header 1st Reference Number],
	ivh.ivh_driver2 [Invoice Header Driver 2],
	ivh.mov_number [Invoice Header Move Number],
	ivh.ivh_edi_flag [Invoice Header EDI Flag],
	ivh.ivh_freight_miles [Invoice Header Freight Miles],
	ivh.tar_tarriffnumber [Invoice Header Tariff Number],
	ivh.tar_tariffitem [Invoice Header Tariff Item],
	IsNull(ivh.ivh_rateby,'T') [Invoice Header Rate By],
	IsNull(ivh.ivh_charge,0.0) [Invoice Header Charge],
	ivd.ivd_number [Invoice Detail Number],
	ivd.stp_number [Invoice Detail Stop Number],
	ivd.ivd_description	[Invoice Detail Description],
	ivd.cht_itemcode [Invoice Detail Charge Type Item Code],
	ivd.ivd_quantity [Invoice Detail Quantity],
	Case ct.cht_basis WHEN 'TAX' then IsNull(ivd.ivd_rate, 0)/ 100.0000 else IsNull(ivd.ivd_rate, 0) end as [Charge Type Rate],
	ivd.ivd_charge [Invoice Detail Charge],
	ivd.ivd_taxable1 [Invoice Detail Taxable 1],
	ivd.ivd_taxable2 [Invoice Detail Taxable 2],
	ivd.ivd_taxable3 [Invoice Detail Taxable 3],
	ivd.ivd_taxable4 [Invoice Detail Taxable 4],
	ivd.ivd_unit [Invoice Detail Unit],
	ivd.cur_code [Invoice Detail Currency Code],
	ivd.ivd_currencydate [Invoice Detail Currency Date],
	ivd.ivd_glnum [Invoice Detail GL Number],
	ivd.ivd_type [Invoice Detail Type],
	ivd.ivd_rate [Invoice Detail Rate],
	ivd.ivd_rateunit [Invoice Detail Rate Unit],
	ivd.ivd_itemquantity [Invoice Detail Item Quantity],
	ivd.ivd_subtotalptr [Invoice Detail Subtotal],
	ivd.ivd_allocatedrev [Invoice Detail Allocated Revenue],
	ivd.ivd_sequence [Charge Group Sort Order],
	ivd.ivd_refnum [Invoice Detail 1st Reference Number],
	ivd.ivd_reftype [Invoice Detail Reference Type],
	ivd.cmd_code [Invoice Detail Commodity Code],
	commodity.cmd_name [Commodity Name],
	commodityclass.ccl_description [Commodity Class Description],
	ivd.cmp_id [Invoice Detail Stop ID],
	stc.cmp_name [Invoice Detail Stop Name],
	stc.cmp_address1 [Invoice Detail Stop Add1],
	stc.cmp_address2 [Invoice Detail Stop Add2],
	stp_cty.cty_name + ', ' + stp_cty.cty_state + ' ' + IsNull(stc.cmp_zip,'') [Invoice Detail Stop CityStZip],
	ivd.ivd_distance [Invoice Detail Distance],
	ivd.ivd_loaded_distance [Invoice Detail Loaded Distance],
	ivd.ivd_distunit [Invoice Detail Distance Unit],
	ivd.ivd_wgt [Invoice Detail Weight],
	ivd.ivd_wgtunit [Invoice Detail Weight Unit],
	ivd.ivd_count [Invoice Detail Count],
	ivd.ivd_countunit [Invoice Detail Count Unit],
	ivd.ivd_volume [Invoice Detail Volume],
	ivd.ivd_volunit [Invoice Detail Volume Unit],
	ivd.evt_number [Invoice Detail Event Number],
	ivd.ivd_payrevenue [Invoice Detail Pay Revenue],
	ivd.fgt_number [Invoice Detail Freight Number],
	coalesce(ivd.cht_rollintoLH, 0) [Invoice Detail Roll Into Linehaul Flag],
	ct.cht_primary [Charge Type Primary],
	ct.cht_basis [Charge Type Basis],
	ct.cht_description [Charge Type Description],
	(select CASE WHEN name = 'UNKNOWN' THEN '' ELSE name END from labelfile where abbr = ivd.ivd_rateunit and labelfile.labeldefinition = 'RateBy') as [Invoice Detail Rate Unit Full],
	ivs.ivs_terms [Invoice Format Invoice Terms],
	ivs.ivs_logocompanyname [Invoice Format Company Name],
	ivs.ivs_logocompanyloc [Invoice Format Company Address],
	ivs.ivs_logopicturefile [Invoice Format Company Logo File],
	ivs.ivs_remittocompanyname [Invoice Format Remit To Company Name],
	ivs.ivs_remittocompanyloc [Invoice Format Remit To Company Address],
	Case 
		when ct.cht_primary = 'Y' then 1
		when ct.cht_primary = 'N' then 3
		when ct.cht_primary = 'Y' and ct.cht_itemcode = 'MIN' then 2
		else 0
	end [Charges Group Sort Order],
	dbo.[TMWSSRS_fcn_referencenumbers_CRLF](ivh.ord_hdrnumber,'orderheader') as 'reflist',
	dbo.[TMWSSRS_fcn_referencenumbers_CRLF](ivd.stp_number,'stops') as 'refliststops',
	ivs_company,
	ivs_logocompanyname,
	ivs_logocompanyloc

into #rsInvoice
from
	invoiceheader ivh
		LEFT OUTER JOIN  referencenumber ref  ON  (ivh.ord_hdrnumber  = ref.ref_tablekey  
													and  ref.ref_table = 'orderheader' 
													and	ref.ref_sequence = 2)
		INNER JOIN company oc on oc.cmp_id = ivh.ivh_originpoint
		INNER JOIN city oc_cty on oc_cty.cty_code = oc.cmp_city
		INNER JOIN company dc on dc.cmp_id = ivh.ivh_destpoint
		INNER JOIN city dc_cty on dc_cty.cty_code = dc.cmp_city
		INNER JOIN company sc on sc.cmp_id = ivh_shipper
		INNER JOIN city sc_cty on sc_cty.cty_code = sc.cmp_city
		INNER JOIN company cc on cc.cmp_id = ivh_consignee
		INNER JOIN city cc_cty on cc_cty.cty_code = cc.cmp_city
		INNER JOIN invoicedetail ivd on ivd.ivh_hdrnumber = ivh.ivh_hdrnumber
		INNER JOIN company stc on stc.cmp_id = ivd.cmp_id
		INNER JOIN city stp_cty on stp_cty.cty_code = stc.cmp_city
		INNER JOIN labelfile la_terms on (la_terms.labeldefinition = 'creditterms' and la_terms.abbr = ivh.ivh_terms) 
		LEFT OUTER JOIN chargetype ct ON ct.cht_itemcode = ivd.cht_itemcode
		LEFT OUTER JOIN  commodity  ON  ivd.cmd_code  = commodity.cmd_code  
		LEFT OUTER JOIN commodityclass ON commodityclass.ccl_code = commodity.cmd_class
		LEFT OUTER JOIN invoiceselection ivs on ivs.ivs_number = @ivs_number,
	 @Bill_Address BillTo
where ivh.ivh_hdrnumber = @invoice



------------------------------- End Main Select -----------------------------

if (select count(*) from #rsInvoice) = 0
	begin
		select @ret_value = 0  
		GOTO ERROR_END
	end

/*     *******************ROLLINTOLH************************     */
/* Handle possible roll into lh */

select @rollintoLHAmt = sum([Invoice Detail Charge]) from #rsInvoice where [Invoice Detail Roll Into Linehaul Flag] = 1

select @rollintoLHAmt = isnull(@rollintoLHAmt,0)

If @rollintoLHAmt <> 0 and exists(select 1 from #rsInvoice where ([Invoice Detail Type] = 'SUB' or [Invoice Detail Charge Type Item Code] = 'MIN') and [Invoice Detail Quantity] <> 0) 
  BEGIN 
      -- determine if a rate conversion factor is involved in the line haul rate
      If exists (select 1 from #rsInvoice where [Invoice Detail Charge Type Item Code] = 'MIN')
        BEGIN
          select @rateconvertion = unc_factor
          from #rsInvoice ttbl
          join unitconversion on [Invoice Detail Unit] = unc_from and [Invoice Detail Rate Unit] = unc_to and unc_convflag = 'R'
          where ttbl.[Invoice Detail Charge Type Item Code] = 'MIN'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #rsInvoice
          set [Invoice Detail Charge] = 
            case [Invoice Detail Charge Type Item Code]
            when 'MIN' then [Invoice Detail Charge] + @rollintoLHAmt
            else 0
            end,
          [Invoice Detail Rate] = 
            case [Invoice Detail Quantity]
            when 1 then round(([Invoice Detail Charge] + @rollintoLHAmt) / @rateconvertion,4)
            else round(([Invoice Detail Charge] + @rollintoLHAmt) / (@rateconvertion * [Invoice Detail Quantity]),4)
            end
          from #rsInvoice tmp
          where [Invoice Detail Type] = 'SUB' or [Invoice Detail Charge Type Item Code] = 'MIN'
        END
            
      else 
        BEGIN
          select @rateconvertion = unc_factor
          from #rsInvoice ttbl
          join unitconversion on [Invoice Detail Unit] = unc_from and [Invoice Detail Rate Unit] = unc_to and unc_convflag = 'R'
          where ttbl.[Invoice Detail Type] = 'SUB'
          
          select @rateconvertion = isnull(@rateconvertion,1) 

          update #rsInvoice
          set [Invoice Detail Charge] =  [Invoice Detail Charge] + @rollintoLHAmt,
          [Invoice Detail Rate] = 
            case [Invoice Detail Quantity]
            when 1 then round(([Invoice Detail Charge] + @rollintoLHAmt) / @rateconvertion,4)
            else round(([Invoice Detail Charge] + @rollintoLHAmt) / (@rateconvertion * [Invoice Detail Quantity]),4)
            end
          from #rsInvoice tmp
          where [Invoice Detail Type] = 'SUB'
        END

    delete from #rsInvoice where [Invoice Detail Roll Into Linehaul Flag] = 1

  END

/* End roll into lh */
/*     *******************ROLLINTOLH************************     */

-------------------------- Create Copies of Main Select ---------------------

select top 1 [Invoice Header Number], 1 as copies
into #rsInvoiceCopy
from #rsInvoice 

select @printcount = @printcount + 1

while @printcount <= @copies
	
	begin 
		insert into #rsInvoiceCopy
		select [Invoice Header Number],@printcount as copies
		from #rsInvoiceCopy
		where copies = 1
		select @printcount = @printcount + 1
	end

select 
	#rsInvoiceCopy.copies,
	#rsInvoice.*
from #rsInvoice
  	inner join #rsInvoiceCopy on #rsInvoiceCopy.[Invoice Header Number] = #rsInvoice.[Invoice Header Number]
order by copies, [Charges Group Sort Order], [Charge Group Sort Order]

----------------------- End Create Copies of Main Select --------------------
ERROR_END:

IF @@ERROR != 0 select @ret_value = @@ERROR
return @ret_value

GO
GRANT EXECUTE ON  [dbo].[SSRS_RB_INVOICE_04] TO [public]
GO
