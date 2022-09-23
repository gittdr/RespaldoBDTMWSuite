SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/* modification log
06/18/03 BLM	17421	replace getdate with dbo.TMW_GETDATE.
11/12/03  BLM		add settlement currency
05/05/2006 DJM	32651 - Added the Rate and Rateunit fields to the returned values.
*/
create proc [dbo].[d_BrokerCarrierDetail_sp]
@CarrierID varchar(8)
as
declare @Daysback int
declare @InvoiceFlag char(10)

select @Daysback = gi_integer1 from generalinfo where gi_name = 'ACS-Days-Back'
select @daysback = isnull(@daysback, 90)

--MRH US VERSION
--select ord_hdrnumber into #Temp0 from legheader where lgh_carrier = @CarrierID and datediff(day, lgh_enddate, dbo.tmw_getdate()) <= @Daysback and lgh_outstatus = 'CMP'
select ord_hdrnumber into #Temp0 from legheader where lgh_carrier = @CarrierID and datediff(day, lgh_enddate, getdate()) <= @Daysback and lgh_outstatus = 'CMP'

select ord_company, 
	ord_number, 
	ord_customer, 
	ord_status, 
	ord_originpoint, 
	ord_destpoint, 
	ord_invoicestatus, 
	ord_origincity as ord_origincitycode, 
	ord_destcity as ord_destcitycode,
	(select cty_name from city where cty_code = ord_origincity) as ord_origincity, 
	(select cty_name from city where cty_code = ord_destcity) as ord_destcity,
	ord_originstate, 
	ord_deststate, 
	ord_originregion1, 
	ord_destregion1, 
	ord_supplier, 
	ord_billto, 
	ord_startdate, 
	ord_completiondate, 
	ord_revtype1, 
	ord_revtype2, 
	ord_revtype3, 
	ord_revtype4, 
	ord_totalweight,	
	ord_totalpieces, 
	ord_totalmiles, 
	ord_totalcharge, 
	ord_currency, 
	ord_currencydate,	
	ord_totalvolume, 
	orderheader.ord_hdrnumber, 
	ord_refnum, 
	ord_invoicewhole, 
	ord_remark, 
	ord_shipper, 
	ord_consignee, 
	ord_pu_at, 
	ord_dr_at, 
	ord_originregion2, 
	ord_originregion3, 
	ord_originregion4, 
	ord_destregion2, 
	ord_destregion3,
	ord_destregion4, 
	ord_contact,	
	ord_quantity, 
	ord_rate, 
	ord_charge, 
	ord_rateunit, 
	ord_unit, 
	trl_type1, 
	ord_trailer, 
	ord_length, 
	ord_width, 
	ord_height, 
	ord_lengthunit, 
	ord_widthunit, 
	ord_heightunit, 
	ord_reftype, 
	cmd_code, 
	ord_description, 
	ord_terms, 
	cht_itemcode, 
	ord_origin_earliestdate, 
	ref_sid, 
	ref_pickup, 
	opt_trc_type4, 
	opt_trl_type4,	
	ord_mileagetable, 
	ord_tareweight, 
	ord_grossweight, 
	ord_trl_type2, 
	ord_trl_type3, 
	ord_trl_type4
into #temp1
from #temp0, 
	orderheader 
where orderheader.ord_hdrnumber = #temp0.ord_hdrnumber

select @InvoiceFlag = gi_string1 from generalinfo where gi_name = 'ACS-Inv-Required'
select @InvoiceFlag = isnull(@InvoiceFlag, 'Y') 

if @InvoiceFlag = 'Y'
begin
	select pyd_amount, 
		pyd_description, 
		pyt_itemcode, 
		ivh_totalcharge, 
		ivh_charge, 
		#temp1.* ,
		pyd_currency = isNull(pyd_currency, ''),-- blm	11.12.03
		pyd_rate,
		pyd_rateunit	
	from paydetail, invoiceheader, #temp1
	where Paydetail.ord_hdrnumber = #temp1.ord_hdrnumber 
		and paydetail.pyt_itemcode in (select pyt_itemcode from paytype where pyt_basis = 'LGH') 
		and invoiceheader.ord_hdrnumber = #temp1.ord_hdrnumber 
		and asgn_type = 'CAR'
end
else	--Invoice not required.
begin
	select pyd_amount, 
		pyd_description, 
		pyt_itemcode, 
		0, 
		0, 
		#temp1.* ,
		pyd_currency = isNull(pyd_currency, ''),		-- blm	11.12.03
		pyd_rate,
		pyd_rateunit	
from paydetail, #temp1
	where Paydetail.ord_hdrnumber = #temp1.ord_hdrnumber 
		and paydetail.pyt_itemcode in (select pyt_itemcode from paytype where pyt_basis = 'LGH') 
		and asgn_type = 'CAR'
end
	
drop table #temp1
GO
GRANT EXECUTE ON  [dbo].[d_BrokerCarrierDetail_sp] TO [public]
GO
