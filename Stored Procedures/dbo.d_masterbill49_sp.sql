SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
  PTS 24901 - DJM - MasterBill format created for Carter Express
  PTS 25415 - DJM - Corrected printing of Masterbill. Was not returning
		rows for Invoice Header once they were updated as Printed.	
  PTS 25480 - DJM - Modified Proc to use the ord_quantity column to hold miles.  Needs a Decimal
		value, so they agreed to manually place the miles into this field to allow a Decimal value.	
  PTS 34155 - DPM - Modified Proc to bring back only contract rate for specified billto
*/

CREATE PROC [dbo].[d_masterbill49_sp] (@reprintflag varchar(10),@mbnumber int,@billto varchar(8), 
	                       @revtype1 varchar(6), @revtype2 varchar(6), @mbstatus varchar(6),@shipstart datetime,
                               @shipend datetime,@billdate datetime, @delstart datetime, @delend datetime,@ord_number varchar (12) )
AS

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'
Select @delstart = convert(char(12),@delstart)+'00:00:00'  
Select @delend   = convert(char(12),@delend  )+'23:59:59'

/* PTS 25480 - DJM - Added GI setting to indicate the RevType value on the MasterOrder to pull the
	SpotBuy string from.
*/
Declare @spotbuy_revtype varchar(10), @Ord_hdrnumber int

select @spotbuy_revtype = isNull(gi_string1,'')from generalinfo where gi_name = 'MB49_spotbuy_type'

SELECT @Ord_hdrnumber = Ord_hdrnumber from orderheader where ord_number = @ord_number
If @ord_number = '' or @ord_number = 'UNKNOWN' SELECT @Ord_hdrnumber = isnull(@Ord_hdrnumber,0) 

-- Table to hold the Invoice Orders.
Create Table #mb_orders(
	ord_hdrnumber		int,
	ivh_billto		varchar(8))
	
  
IF UPPER(@reprintflag) <> 'REPRINT' 
  BEGIN
	-- Build the list of distinct Order(s) required for the current masterbill.
	Insert Into #mb_orders
	Select Distinct ord_hdrnumber,
		ivh_billto
	from Invoiceheader
	where ( @ord_hdrnumber = 0 or invoiceheader.ord_hdrnumber = @ord_hdrnumber) --PTS 25699
  		AND (invoiceheader.ivh_billto = @billto) 
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (invoiceheader.ivh_mbstatus = 'RTP')  
		AND (invoiceheader.ivh_mbnumber is NULL  OR  
		  invoiceheader.ivh_mbnumber = 0   ) 
		AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND (invoiceheader.ivh_deliverydate between @delstart AND @delend )   

	SELECT invoiceheader.ord_hdrnumber,
		@billto invoice_billto,
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_totalcharge,   
		master.ord_refnum route_name,
		invoiceheader.ivh_shipdate run_date,
		master.ord_quantity route_miles,
		o.ord_totalmiles tot_miles,
		contract.contract_rate,
		contract.fixed_cost,
		contract.fixed_cwt,
		contract.detail_max_charge,
		contract.detail_min_charge,
		contract.min_cwt,
		contract.add_pct,
		contract.or_charge,
		contract.max_cwt,
		contract.no_freight_charge,
		contract.adjlane_cost,
		contract.fuel_sc_exempt,
		id.ivd_number,
		id.ivd_billto,
		id.ivd_fsc,
		cmp1.cmp_name billto_name,
		stops.stp_type,
		id.ivd_refnum,
		id.ivd_wgt,
		id.ivd_charge,
		master.ord_number route_number,
		o.ord_number,
		id.ivd_oradjustment,
		id.ivd_cbadjustment,
		id.ivd_rawcharge,
		(select cmp_name from company where company.cmp_id = @billto) invoice_billto_name,
		isNull(invoiceheader.ivh_fuelprice, 0) ivh_fuelprice,
		@mbnumber masterbill_number,
		isNull(Case When @spotbuy_revtype= '' then ''
			Else (select isNull(ref_number,'') 
				from referencenumber 
				where ref_table = 'orderheader' 
					and ref_tablekey = master.ord_hdrnumber 
					and ref_type = @spotbuy_revtype) 
		End,'') spotbuy_text
	INTO #temp
	FROM #mb_orders mb,
		orderheader o,
		orderheader master,	
		contract,
		stops,
		invoiceheader, 
		invoicedetail id,
		company cmp1
	WHERE mb.ord_hdrnumber = invoiceheader.ord_hdrnumber 
		AND invoiceheader.ord_hdrnumber = o.ord_hdrnumber	
		AND invoiceheader.ivh_invoicenumber = id.ivh_hdrnumber
		AND invoiceheader.ord_hdrnumber = contract.ord_hdrnumber
		AND @billto = contract.cmp_id
		--AND invoiceheader.ivh_billto = contract.cmp_id --PTS34155
		AND master.ord_hdrnumber = contract.mastord_hdrnumber
		AND id.stp_number = stops.stp_number 
		AND (invoiceheader.ivh_shipdate between @shipstart AND @shipend ) 
		AND (cmp1.cmp_id = id.ivd_billto)

	
	Select * from #temp

 End
Else
 Begin

	-- Build the list of distinct Order(s) required for the current masterbill.
	Insert Into #mb_orders
	Select Distinct ord_hdrnumber,
		ivh_billto
	from Invoiceheader
	where (invoiceheader.ivh_mbnumber = @mbnumber ) 
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK'))
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 
		AND (@revtype1 in (invoiceheader.ivh_revtype1,'UNK')) 
		AND (@revtype2 in (invoiceheader.ivh_revtype2,'UNK')) 



	SELECT invoiceheader.ord_hdrnumber,
		@billto invoice_billto,
		invoiceheader.ivh_invoicenumber,  
		invoiceheader.ivh_hdrnumber, 
		invoiceheader.ivh_billto,   
		invoiceheader.ivh_totalcharge,   
		master.ord_refnum route_name,
		invoiceheader.ivh_shipdate run_date,
		master.ord_quantity route_miles,
		o.ord_totalmiles tot_miles,
		contract.contract_rate,
		contract.fixed_cost,
		contract.fixed_cwt,
		contract.detail_max_charge,
		contract.detail_min_charge,
		contract.min_cwt,
		contract.add_pct,
		contract.or_charge,
		contract.max_cwt,
		contract.no_freight_charge,
		contract.adjlane_cost,
		contract.fuel_sc_exempt,
		id.ivd_number,
		id.ivd_billto,
		id.ivd_fsc,
		cmp1.cmp_name billto_name,
		stops.stp_type,
		id.ivd_refnum,
		id.ivd_wgt,
		id.ivd_charge,
		master.ord_number route_number,
		o.ord_number,
		id.ivd_oradjustment,
		id.ivd_cbadjustment,
		id.ivd_rawcharge,
		(select cmp_name from company where company.cmp_id = @billto) invoice_billto_name,
		isNull(invoiceheader.ivh_fuelprice, 0) ivh_fuelprice,
		@mbnumber masterbill_number,
		Case When @spotbuy_revtype= '' then ''
			Else (select isNull(ref_number,'') 
				from referencenumber 
				where ref_table = 'orderheader' 
					and ref_tablekey = master.ord_hdrnumber 
					and ref_type = @spotbuy_revtype) 
		End spotbuy_text
	INTO #temp2
	FROM #mb_orders mb,
		orderheader o,
		orderheader master,
		contract,
		stops,
		invoiceheader, 
		invoicedetail id,
		company cmp1
	WHERE mb.ord_hdrnumber = invoiceheader.ord_hdrnumber 
		AND invoiceheader.ord_hdrnumber = o.ord_hdrnumber	
		AND invoiceheader.ivh_invoicenumber = id.ivh_hdrnumber
		AND invoiceheader.ord_hdrnumber = contract.ord_hdrnumber
		AND @billto = contract.cmp_id
		--AND invoiceheader.ivh_billto = contract.cmp_id --PTS34155
		AND master.ord_hdrnumber = contract.mastord_hdrnumber
		AND id.stp_number = stops.stp_number 
		AND (cmp1.cmp_id = id.ivd_billto)

	-- Return the rows to the application.
	Select * from #temp2

 End 


GO
GRANT EXECUTE ON  [dbo].[d_masterbill49_sp] TO [public]
GO
