SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



/* modification log
37106 10/31/07 BDH - Stolen from d_BrokerCarrierDetail_sp, now returning tariffnumber.
44813 20081105 JJF - Rewritten - streamlined.  Fixed problem where rows excluded if no corresponding paydetail
*/

create proc [dbo].[d_BrokerCarrierPaymentDetail_sp]
	@CarrierID varchar(8),
	@origin varchar(50),
	@destination varchar(50),
	@oradius int, 
	@dradius int,
	@tarnumber int = null 

as
/*

exec d_BrokerCarrierPaymentDetail_sp car1, 'nd', 'oh', 0, 0 


*/
declare 
	@InvoiceFlag char(10),
	@workingOrigin varchar(50),
	@workingDest varchar(50),
	@ete_commapos int,
	@ls_ocity varchar(50),
	@ll_ocity int,
	@ls_ostate char(2),
	@orig_lat dec(12,6),
	@orig_long dec(12,6),
	@ls_dcity varchar(50),
	@ll_dcity int,
	@ls_dstate char(2),
	@dest_lat dec(12,6),
	@dest_long dec(12,6)

if @origin is null set @origin = ''
if @destination is null set @destination = ''
if @tarnumber is null set @tarnumber = 0

CREATE TABLE #Resultset(
	pyd_amount money null,
	pyd_description varchar(75) null,
	pyt_itemcode varchar(6) null,
	ivh_totalcharge money null,
	ivh_charge money null,
	ord_company varchar(8) null,
	ord_number varchar(12) null, 
	ord_customer varchar(8) null, 
	ord_status varchar(6) null, 
	ord_originpoint varchar(8) null, 
	ord_destpoint varchar(8) null, 
	ord_invoicestatus varchar(6) null, 
	ord_origincitycode int null, 
	ord_destcitycode int null,
	ord_origincity varchar(18) null, 
	ord_destcity varchar(18) null,
	ord_originstate varchar(6) null, 
	ord_deststate varchar(6) null, 
	ord_originregion1 varchar(6) null, 
	ord_destregion1 varchar(6) null, 
	ord_supplier varchar(8) null, 
	ord_billto varchar(8) null, 
	ord_startdate datetime null, 
	ord_completiondate datetime null, 
	ord_revtype1 varchar(6) null, 
	ord_revtype2 varchar(6) null, 
	ord_revtype3 varchar(6) null, 
	ord_revtype4 varchar(6) null, 
	ord_totalweight float null,	
	ord_totalpieces decimal(10,2) null, 
	ord_totalmiles int null, 
	ord_totalcharge float null, 
	ord_currency varchar(6) null, 
	ord_currencydate datetime null,	
	ord_totalvolume float null, 
	ord_hdrnumber int null, 
	ord_refnum varchar(30) null, 
	ord_invoicewhole char(1) null, 
	ord_remark varchar(254) null, 
	ord_shipper varchar(8) null, 
	ord_consignee varchar(8) null, 
	ord_pu_at varchar(6) null, 
	ord_dr_at varchar(6) null, 
	ord_originregion2 varchar(6) null,
	ord_originregion3 varchar(6) null, 
	ord_originregion4 varchar(6) null, 
	ord_destregion2 varchar(6) null, 
	ord_destregion3 varchar(6) null,
	ord_destregion4 varchar(6) null, 
	ord_contact varchar(30) null,	
	ord_quantity float null, 
	ord_rate money null, 
	ord_charge money null, 
	ord_rateunit varchar(6) null, 
	ord_unit varchar(6) null, 
	trl_type1 varchar(6) null, 
	ord_trailer varchar(13) null, 
	ord_length money null, 
	ord_width money null, 
	ord_height money null, 
	ord_lengthunit varchar(6) null, 
	ord_widthunit varchar(6) null, 
	ord_heightunit varchar(6) null, 
	ord_reftype varchar(6) null, 
	cmd_code varchar(8) null, 
	ord_description varchar(75) null, 
	ord_terms varchar(6) null, 
	cht_itemcode varchar(6) null, 
	ord_origin_earliestdate datetime null, 
	ref_sid char(1) null, 
	ref_pickup char(1) null, 
	opt_trc_type4 varchar(6) null, 
	opt_trl_type4 varchar(6) null,	
	ord_mileagetable varchar(2) null, 
	ord_tareweight int null, 
	ord_grossweight int null, 
	ord_trl_type2 varchar(6) null, 
	ord_trl_type3 varchar(6) null, 
	ord_trl_type4 varchar(6) null,
	pyd_currency varchar(6) null,
	pyd_rate money null,
	pyd_rateunit varchar(6) null,
	tar_tarriffnumber varchar(12) null,
	lm_keeporigin char(1) null,
	lm_keepDestination char(1) null,
	lm_origcity_lat dec(12,6) null,
	lm_origcity_long dec(12,6) null,
	lm_origdistance int null,
	lm_destcity_lat dec(12,6) null,
	lm_destcity_long dec(12,6) null,
	lm_destdistance int null
)

INSERT INTO #Resultset(
	pyd_amount,
	pyd_description,
	pyt_itemcode,
	ivh_totalcharge,
	ivh_charge,
	ord_company,
	ord_number, 
	ord_customer, 
	ord_status,
	ord_originpoint,
	ord_destpoint,
	ord_invoicestatus,
	ord_origincitycode,
	ord_destcitycode,
	ord_origincity,
	ord_destcity,
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
	ord_hdrnumber,
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
	ord_trl_type4,
	pyd_currency,
	pyd_rate,
	pyd_rateunit,
	tar_tarriffnumber,
	lm_keeporigin,
	lm_keepDestination,
	lm_origcity_lat,
	lm_origcity_long,
	lm_origdistance,
	lm_destcity_lat,
	lm_destcity_long,
	lm_destdistance
)
select 
	null,
	null,
	null,
	0,
	0,
	oh.ord_company, 
	oh.ord_number, 
	oh.ord_customer, 
	oh.ord_status, 
	oh.ord_originpoint, 
	oh.ord_destpoint, 
	oh.ord_invoicestatus, 
	oh.ord_origincity as ord_origincitycode, 
	oh.ord_destcity as ord_destcitycode,
	(select cty_name from city where cty_code = oh.ord_origincity) as ord_origincity, 
	(select cty_name from city where cty_code = oh.ord_destcity) as ord_destcity,
	oh.ord_originstate, 
	oh.ord_deststate, 
	oh.ord_originregion1, 
	oh.ord_destregion1, 
	oh.ord_supplier, 
	oh.ord_billto, 
	oh.ord_startdate, 
	oh.ord_completiondate, 
	oh.ord_revtype1, 
	oh.ord_revtype2, 
	oh.ord_revtype3, 
	oh.ord_revtype4, 
	oh.ord_totalweight,	
	oh.ord_totalpieces, 
	oh.ord_totalmiles, 
	oh.ord_totalcharge, 
	oh.ord_currency, 
	oh.ord_currencydate,	
	oh.ord_totalvolume, 
	oh.ord_hdrnumber, 
	oh.ord_refnum, 
	oh.ord_invoicewhole, 
	oh.ord_remark, 
	oh.ord_shipper, 
	oh.ord_consignee, 
	oh.ord_pu_at, 
	oh.ord_dr_at, 
	oh.ord_originregion2, 
	oh.ord_originregion3, 
	oh.ord_originregion4, 
	oh.ord_destregion2, 
	oh.ord_destregion3,
	oh.ord_destregion4, 
	oh.ord_contact,	
	oh.ord_quantity, 
	oh.ord_rate, 
	oh.ord_charge, 
	oh.ord_rateunit, 
	oh.ord_unit, 
	oh.trl_type1, 
	oh.ord_trailer, 
	oh.ord_length, 
	oh.ord_width, 
	oh.ord_height, 
	oh.ord_lengthunit, 
	oh.ord_widthunit, 
	oh.ord_heightunit, 
	oh.ord_reftype, 
	oh.cmd_code, 
	oh.ord_description, 
	oh.ord_terms, 
	oh.cht_itemcode, 
	oh.ord_origin_earliestdate, 
	oh.ref_sid, 
	oh.ref_pickup, 
	oh.opt_trc_type4, 
	oh.opt_trl_type4,	
	oh.ord_mileagetable, 
	oh.ord_tareweight, 
	oh.ord_grossweight, 
	oh.ord_trl_type2, 
	oh.ord_trl_type3, 
	oh.ord_trl_type4,
	null,
	null,
	null,
	null,
	'N',
	'N',
	null,
	null,
	null,
	null,
	null,
	null
from CarrierHistoryDetail chd inner join orderheader oh on chd.ord_hdrnumber = oh.ord_hdrnumber
where Crh_Carrier = @CarrierID


if len(@origin) > 0 
begin
 	set @workingOrigin = ltrim(rtrim(@origin))
	-- Parse Origin
	SELECT @ete_commapos = CHARINDEX(',', @workingOrigin)
	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	BEGIN
		set @ls_ocity = RTRIM(LTRIM(LEFT(@workingOrigin, @ete_commapos - 1))) 
		set @ls_ostate = RTRIM(LTRIM(SUBSTRING(@workingOrigin, @ete_commapos + 1, 99))) 
		
		select  @ll_ocity = cty_code,
			@orig_lat = cty_latitude,
			@orig_long = cty_longitude 
		from city where cty_name = @ls_ocity and cty_state = @ls_ostate

		--This is 
		update #ResultSet 
		set lm_origcity_lat  = (select cty_latitude from city where cty_code = ord_origincitycode),
			lm_origcity_long = (select cty_longitude from city where cty_code = ord_origincitycode)
		
		update #ResultSet 
		set lm_origdistance = dbo.tmw_airdistance_fn(@orig_lat, @orig_long, lm_origcity_lat, lm_origcity_long)

		if @ll_ocity  > 0
		begin
			if isnull(@oradius, 0) > 0
			begin
				update #ResultSet
				set lm_keepOrigin = 'Y' where lm_origdistance <= @oradius 				
			end
			else
			begin
				update #ResultSet
				SET lm_keepOrigin = 'Y' where ord_origincitycode = @ll_ocity
			end		
		end	
	END
	if len(rtrim(ltrim(@origin))) = 2 and rtrim(ltrim(@origin)) in (select tcz_state from transcore_zones)
	begin	
		update #ResultSet set lm_keepOrigin = 'Y' where ord_originstate = @origin
	end
end

--destination
if len(@destination) > 0 
begin
 	set @workingDest = ltrim(rtrim(@destination))
	-- Parse Origin
	SELECT @ete_commapos = CHARINDEX(',', @workingDest)
	If @ete_commapos > 0 
	-- Has a comma, must be a city state
	BEGIN
		set @ls_dcity = RTRIM(LTRIM(LEFT(@workingDest, @ete_commapos - 1))) 
		set @ls_dstate = RTRIM(LTRIM(SUBSTRING(@workingDest, @ete_commapos + 1, 99))) 
		
		select  @ll_dcity = cty_code,
			@dest_lat = cty_latitude,
			@dest_long = cty_longitude 
		from city where cty_name = @ls_dcity and cty_state = @ls_dstate

		--This is 
		update #ResultSet 
		set lm_destcity_lat  = (select cty_latitude from city where cty_code = ord_destcitycode),
			lm_destcity_long = (select cty_longitude from city where cty_code = ord_destcitycode)
		
		update #ResultSet 
		set lm_destdistance = dbo.tmw_airdistance_fn(@dest_lat, @dest_long, lm_destcity_lat, lm_destcity_long)

		if @ll_dcity  > 0
		begin
			if isnull(@dradius, 0) > 0
			begin
				update #ResultSet
					set lm_keepDestination = 'Y' where lm_destdistance <= @dradius 				
			end
			else
			begin
			update #ResultSet
				SET lm_keepDestination = 'Y' where ord_destcitycode = @ll_dcity
			end		
		end	
	END
	if len(rtrim(ltrim(@destination))) = 2 and rtrim(ltrim(@destination)) in (select tcz_state from transcore_zones)
	begin	
		update #ResultSet set lm_keepDestination = 'Y' where ord_deststate = @destination
	end
end

update #ResultSet
set pyd_amount = pd.pyd_amount, 
	pyd_description = pd.pyd_description, 
	pyt_itemcode = pd.pyt_itemcode, 
	pyd_currency = isNull(pd.pyd_currency, ''),
	pyd_rate = pd.pyd_rate,
	pyd_rateunit = pd.pyd_rateunit,
	tar_tarriffnumber = pd.tar_tarriffnumber
from	#ResultSet inner join paydetail pd on #ResultSet.ord_hdrnumber = pd.ord_hdrnumber
where 	pd.pyt_itemcode in (select pyt_itemcode from paytype where pyt_basis = 'LGH') 
		and pd.asgn_type = 'CAR'
		and ((@tarnumber > 0 and pd.tar_tarriffnumber = @tarnumber) or (@tarnumber = 0 and isnull(pd.tar_tarriffnumber, 0) = 0 ))


select @InvoiceFlag = gi_string1 from generalinfo where gi_name = 'ACS-Inv-Required'
select @InvoiceFlag = isnull(@InvoiceFlag, 'Y') 

if @InvoiceFlag = 'Y'
begin
	--in this implementation, this is more of a 'include invoice info' as opposed to 'invoice required'
	update #ResultSet
	set ivh_totalcharge = ivh.ivh_totalcharge, 
		ivh_charge =  ivh.ivh_charge
	from	#ResultSet inner join invoiceheader ivh on #ResultSet.ord_hdrnumber = ivh.ord_hdrnumber
end


SELECT 
	pyd_amount,
	pyd_description,
	pyt_itemcode,
	ivh_totalcharge,
	ivh_charge,
	ord_company,
	ord_number, 
	ord_customer, 
	ord_status,
	ord_originpoint,
	ord_destpoint,
	ord_invoicestatus,
	ord_origincitycode,
	ord_destcitycode,
	ord_origincity,
	ord_destcity,
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
	ord_hdrnumber,
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
	ord_trl_type4,
	pyd_currency,
	pyd_rate,
	pyd_rateunit,
	tar_tarriffnumber,
	lm_keeporigin,
	lm_keepDestination
FROM #Resultset
WHERE 	((@origin <> '' and lm_keepOrigin = 'Y') or @origin = '')
		and ((@destination <> '' and lm_keepDestination = 'Y') or @destination = '')
		and ((@tarnumber > 0 and tar_tarriffnumber = @tarnumber) or (@tarnumber = 0 and isnull(tar_tarriffnumber, 0) = 0 ))

GO
GRANT EXECUTE ON  [dbo].[d_BrokerCarrierPaymentDetail_sp] TO [public]
GO
