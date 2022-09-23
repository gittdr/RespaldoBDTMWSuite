SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[invoice_template150](@invoice_nbr  	int,@copies		int)
as
/*	PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND
	1 - IF SUCCESFULLY EXECUTED
	@@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS

2/2/99 add cmp_altid from useasbillto company to return set
1/5/00 dpete pts 6946 consignee city state not showing up on invoice hdr when consignee = UNKNOWN
06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * 11/13/2007.01 ? PTS40188 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
* 10/27/2007 pmill - adapted from invoice_template150 for Coastal Transport --USED FOR invoice formats 150 & 151
* PTS 47311 4/30/09 customer does not want to see addtiional PUP stops ( accumulate miles from PUP stops)
*/

declare	@temp_name   varchar(100) ,
	@temp_addr   varchar(100) ,
	@temp_addr2  varchar(100),
	@temp_nmstct varchar(100),
	@temp_altid  varchar(25),
	@counter    int,
	@ret_value  int	

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1


/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1

/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: "COPY" - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
 SELECT  invoiceheader.ivh_invoicenumber,
         invoiceheader.ivh_hdrnumber, 
		invoiceheader.ord_number, 
	 invoiceheader.ivh_billto, 
	 @temp_name ivh_billto_name ,
	 @temp_addr 	ivh_billto_addr,
	 @temp_addr2	ivh_billto_addr2,
	 @temp_nmstct ivh_billto_nmctst,
         invoiceheader.ivh_terms,   	
         invoiceheader.ivh_totalcharge,   
	 invoiceheader.ivh_shipper,   
	 @temp_name	shipper_name,
	 @temp_addr	shipper_addr,
	 @temp_addr2	shipper_addr2,
	 @temp_nmstct shipper_nmctst,
         invoiceheader.ivh_consignee,   
	 @temp_name consignee_name,
	 @temp_addr consignee_addr,
	 @temp_addr2	consignee_addr2,
	 @temp_nmstct consignee_nmctst,
         invoiceheader.ivh_originpoint,   
	 @temp_name originpoint_name,
	 @temp_addr origin_addr,
	 @temp_addr2	origin_addr2,
	 @temp_nmstct origin_nmctst,
         invoiceheader.ivh_destpoint,   
	 @temp_name destpoint_name,
	 @temp_addr dest_addr,
	 @temp_addr2	dest_addr2,
	 @temp_nmstct dest_nmctst,
         invoiceheader.ivh_invoicestatus,   
         invoiceheader.ivh_origincity,   
         invoiceheader.ivh_destcity,   
         invoiceheader.ivh_originstate,   
         invoiceheader.ivh_deststate,
         invoiceheader.ivh_originregion1,   
         invoiceheader.ivh_destregion1,   
         invoiceheader.ivh_supplier,   
         invoiceheader.ivh_shipdate,   
         invoiceheader.ivh_deliverydate,   
         invoiceheader.ivh_revtype1,   
         invoiceheader.ivh_revtype2,   
         invoiceheader.ivh_revtype3,   
         invoiceheader.ivh_revtype4,   
         invoiceheader.ivh_totalweight,   
         invoiceheader.ivh_totalpieces,   
         invoiceheader.ivh_totalmiles,   
         invoiceheader.ivh_currency,   
         invoiceheader.ivh_currencydate,   
         invoiceheader.ivh_totalvolume,   
         invoiceheader.ivh_taxamount1,   
         invoiceheader.ivh_taxamount2,   
         invoiceheader.ivh_taxamount3,   
         invoiceheader.ivh_taxamount4,   
         invoiceheader.ivh_transtype,   
         invoiceheader.ivh_creditmemo,   
         invoiceheader.ivh_applyto,   
         invoiceheader.ivh_printdate,   
         invoiceheader.ivh_billdate,   
         invoiceheader.ivh_lastprintdate,   
         invoiceheader.ivh_originregion2,   
         invoiceheader.ivh_originregion3,   
         invoiceheader.ivh_originregion4,   
         invoiceheader.ivh_destregion2,   
         invoiceheader.ivh_destregion3,   
         invoiceheader.ivh_destregion4,   
         invoiceheader.mfh_hdrnumber,   
         invoiceheader.ivh_remark,   
         invoiceheader.ivh_driver,   
         invoiceheader.ivh_tractor,   
         invoiceheader.ivh_trailer,   
         invoiceheader.ivh_user_id1,   
         invoiceheader.ivh_user_id2,   
         invoiceheader.ivh_ref_number,   
         invoiceheader.ivh_driver2,   
         invoiceheader.mov_number,   
         invoiceheader.ivh_edi_flag,   
         invoiceheader.ord_hdrnumber,   
         invoicedetail.ivd_number,   
         invoicedetail.stp_number,   
         invoicedetail.ivd_description,   
         invoicedetail.cht_itemcode, 
         ivd_quantity = case ivd_sign
           when 0 then ivd_quantity
           else case ivd_charge
                when 0 then 0
                else ivd_quantity
                end
            end, 
        -- invoicedetail.ivd_quantity,   
         --invoicedetail.ivd_rate,   
		Case chargetype.cht_basis WHEN 'TAX' then IsNull(invoicedetail.ivd_rate, 0)/ 100.0000 else IsNull(invoicedetail.ivd_rate, 0) end as ivd_rate,
         invoicedetail.ivd_charge,   
         invoicedetail.ivd_taxable1,   
         invoicedetail.ivd_taxable2,   
	 invoicedetail.ivd_taxable3,   
         invoicedetail.ivd_taxable4,
         invoicedetail.ivd_unit,   
         invoicedetail.cur_code,   
         invoicedetail.ivd_currencydate,   
         invoicedetail.ivd_glnum,   
         invoicedetail.ivd_type,   
         invoicedetail.ivd_rateunit,   
         invoicedetail.ivd_billto,   
	 @temp_name ivd_billto_name,
	 @temp_addr ivd_billto_addr,
	 @temp_addr2	ivd_billto_addr2,
	 @temp_nmstct ivd_billto_nmctst,
         invoicedetail.ivd_itemquantity,   
         invoicedetail.ivd_subtotalptr,   
         invoicedetail.ivd_allocatedrev,   
         invoicedetail.ivd_sequence,   
         invoicedetail.ivd_refnum,   
         invoicedetail.cmd_code,   
         invoicedetail.cmp_id,   
	 @temp_name	stop_name,
	 @temp_addr	stop_addr,
	 @temp_addr2	stop_addr2,
	 @temp_nmstct stop_nmctst,
         invoicedetail.ivd_distance,   
         invoicedetail.ivd_distunit,   
         invoicedetail.ivd_wgt,   
         invoicedetail.ivd_wgtunit,   
         invoicedetail.ivd_count,   
	 invoicedetail.ivd_countunit,   
         invoicedetail.evt_number,   
         invoicedetail.ivd_reftype,   
         invoicedetail.ivd_volume,   
         invoicedetail.ivd_volunit,   
         invoicedetail.ivd_orig_cmpid,   
         invoicedetail.ivd_payrevenue,
	 invoiceheader.ivh_freight_miles,
	 invoiceheader.tar_tarriffnumber,
	 invoiceheader.tar_tariffitem,
	 1 copies,
	 chargetype.cht_primary,
	 chargetype.cht_basis,
	 chargetype.cht_description,
	 commodity.cmd_name,
	commodityclass.ccl_description cmd_class,
	@temp_altid cmp_altid,
	 ref_number = ' ',  -- not used on format150 SQL2k does not like empty string
	invoicedetail.fgt_number,
	isnull(invoiceheader.ivh_rateby,'T') ivh_rateby,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	IsNull(ivh_charge,0.0) ivh_charge,
	0 sortorder,
    firstDRPSeq = case ord_number
           when '0' then 0
           else (select min(ivd_sequence) from invoicedetail id2 
              where id2.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and ivd_type = 'DRP')
           end
    into #invtemp_tbl
    FROM invoiceheader
    join invoicedetail on invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber
    left outer join chargetype on   invoicedetail.cht_itemcode    = chargetype.cht_itemcode
    left outer join commodity on invoicedetail.cmd_code  = commodity.cmd_code 
    LEFT OUTER JOIN commodityclass ON commodity.cmd_class = commodityclass.ccl_code 
 --   FROM
--chargetype  RIGHT OUTER JOIN  invoicedetail  ON  chargetype.cht_itemcode  = invoicedetail.cht_itemcode   
--				LEFT OUTER JOIN  commodity  ON  invoicedetail.cmd_code  = commodity.cmd_code  
--				LEFT OUTER JOIN commodityclass ON commodityclass.ccl_code = commodity.cmd_class,
--		invoiceheader  LEFT OUTER JOIN  referencenumber ref  ON  (invoiceheader.ord_hdrnumber  = ref.ref_tablekey  
--																		and  ref.ref_table = 'orderheader' 
--																		and	ref.ref_sequence = 2)
   WHERE invoiceheader.ivh_hdrnumber = @invoice_nbr 
	and ivd_type <> 'PUP'

--select * from #invtemp_tbl

--If (select ivh_definition from invoiceheader where ivh_hdrnumber = @invoice_nbr ) = 'SUPL' or
--((select count(distinct stp_number) from invoicedetail where ivh_hdrnumber = @invoice_nbr and ivd_type = 'DRP') <>
-- (select count(*) from stops where stp_type = 'DRP' and ord_hdrnumber = (select ord_hdrnumber from invoiceheader where ivh_hdrnumber = @invoice_nbr)))

--If (select top 1 ord_hdrnumber from #invtemp_tbl) > 0 and (select count(*) from #invtemp_tbl where ivd_type = 'DRP') = 0

If (select count(*) from #invtemp_tbl where ord_hdrnumber > 0 and ivd_type = 'DRP' ) = 0
begin
	if (select top 1 ivh_rateby from #invtemp_tbl) = 'D'
		begin
--			select stp_mfh_sequence,fgt_sequence,stp.*,fgt.*,ivh2.*
			insert into #invtemp_tbl
			select 
			ivh2.ivh_invoicenumber,
			ivh2.ivh_hdrnumber, 
			ivh2.ord_number, 
			ivh2.ivh_billto, 
			@temp_name ivh_billto_name ,
			@temp_addr 	ivh_billto_addr,
			@temp_addr2	ivh_billto_addr2,
			@temp_nmstct ivh_billto_nmctst,
			ivh2.ivh_terms,   	
			ivh2.ivh_totalcharge,   
			ivh2.ivh_shipper,   
			@temp_name	shipper_name,
			@temp_addr	shipper_addr,
			@temp_addr2	shipper_addr2,
			@temp_nmstct shipper_nmctst,
			ivh2.ivh_consignee,   
			@temp_name consignee_name,
			@temp_addr consignee_addr,
			@temp_addr2	consignee_addr2,
			@temp_nmstct consignee_nmctst,
			ivh2.ivh_originpoint,   
			@temp_name originpoint_name,
			@temp_addr origin_addr,
			@temp_addr2	origin_addr2,
			@temp_nmstct origin_nmctst,
			ivh2.ivh_destpoint,   
			@temp_name destpoint_name,
			@temp_addr dest_addr,
			@temp_addr2	dest_addr2,
			@temp_nmstct dest_nmctst,
			ivh2.ivh_invoicestatus,   
			ivh2.ivh_origincity,   
			ivh2.ivh_destcity,   
			ivh2.ivh_originstate,   
			ivh2.ivh_deststate,
			ivh2.ivh_originregion1,   
			ivh2.ivh_destregion1,   
			ivh2.ivh_supplier,   
			ivh2.ivh_shipdate,   
			ivh2.ivh_deliverydate,   
			ivh2.ivh_revtype1,   
			ivh2.ivh_revtype2,   
			ivh2.ivh_revtype3,   
			ivh2.ivh_revtype4,   
			ivh2.ivh_totalweight,   
			ivh2.ivh_totalpieces,   
			ivh2.ivh_totalmiles,   
			ivh2.ivh_currency,   
			ivh2.ivh_currencydate,   
			ivh2.ivh_totalvolume,   
			ivh2.ivh_taxamount1,   
			ivh2.ivh_taxamount2,   
			ivh2.ivh_taxamount3,   
			ivh2.ivh_taxamount4,   
			ivh2.ivh_transtype,   
			ivh2.ivh_creditmemo,   
			ivh2.ivh_applyto,   
			ivh2.ivh_printdate,   
			ivh2.ivh_billdate,   
			ivh2.ivh_lastprintdate,   
			ivh2.ivh_originregion2,   
			ivh2.ivh_originregion3,   
			ivh2.ivh_originregion4,   
			ivh2.ivh_destregion2,   
			ivh2.ivh_destregion3,   
			ivh2.ivh_destregion4,   
			ivh2.mfh_hdrnumber,   
			ivh2.ivh_remark,   
			ivh2.ivh_driver,   
			ivh2.ivh_tractor,   
			ivh2.ivh_trailer,   
			ivh2.ivh_user_id1,   
			ivh2.ivh_user_id2,   
			ivh2.ivh_ref_number,   
			ivh2.ivh_driver2,   
			ivh2.mov_number,   
			ivh2.ivh_edi_flag,   
			ivh2.ord_hdrnumber,
			0,  --ivd2.ivd_number,   
			fgt.stp_number,  --ivd2.stp_number,   
			ct.cht_description,  --ivd2.ivd_description,   
			'LHF',  --ivd2.cht_itemcode,
			0,  --ivd_quantity =   case ivd2.ivd_sign
				--				  when 0 then ivd2.ivd_quantity
				--				  else case ivd2.ivd_charge
				--					   when 0 then 0
				--					   else ivd2.ivd_quantity
				--					   end
				--				  end,
			0,  --Case ct.cht_basis WHEN 'TAX' then IsNull(ivd2.ivd_rate, 0)/ 100.0000 else IsNull(ivd2.ivd_rate, 0) end as ivd_rate,
			0,  --ivd2.ivd_charge,   
			'',  --ivd2.ivd_taxable1,   
			'',  --ivd2.ivd_taxable2,   
			'',  --ivd2.ivd_taxable3,   
			'',  --ivd2.ivd_taxable4,
			'FLT',  --ivd2.ivd_unit,   
			'US',  --ivd2.cur_code,   
			ivd2.ivd_currencydate,   
			'',  --ivd2.ivd_glnum,   
			'DRP',  --ivd2.ivd_type,   
			'FLT',  --ivd2.ivd_rateunit,   
			ivd2.ivd_billto,   
			@temp_name ivd_billto_name,
			@temp_addr ivd_billto_addr,
			@temp_addr2	ivd_billto_addr2,
			@temp_nmstct ivd_billto_nmctst,
			ivd2.ivd_itemquantity,   
			ivd2.ivd_subtotalptr,   
			ivd2.ivd_allocatedrev,   
			ivd2.ivd_sequence,   
			ivd2.ivd_refnum,   
			fgt.cmd_code,  --ivd2.cmd_code,   
			stp.cmp_id,  --ivd2.cmp_id,   
			@temp_name	stop_name,
			@temp_addr	stop_addr,
			@temp_addr2	stop_addr2,
			@temp_nmstct stop_nmctst,
			case fgt.fgt_sequence when 1 then stp.stp_ord_mileage else 0 end,  --ivd2.ivd_distance,   
			ivd2.ivd_distunit,   
			ivd2.ivd_wgt,   
			ivd2.ivd_wgtunit,   
			ivd2.ivd_count,   
			ivd2.ivd_countunit,   
			ev.evt_number,  --ivd2.evt_number,   
			ivd2.ivd_reftype,   
			fgt.fgt_volume,  --ivd2.ivd_volume,   
			fgt.fgt_volumeunit,  --ivd2.ivd_volunit,   
			'',  --ivd2.ivd_orig_cmpid,   
			ivd2.ivd_payrevenue,
			ivh2.ivh_freight_miles,
			ivh2.tar_tarriffnumber,
			ivh2.tar_tariffitem,
			1 copies,
			'Y',  --ct.cht_primary,
			'SHP',  --ct.cht_basis,
			ct.cht_description,
			cmd.cmd_name,
			cc.ccl_description cmd_class,
			@temp_altid cmp_altid,
			ref_number = ' ',  -- not used on format150 SQL2k does not like empty string
			fgt.fgt_number,
			isnull(ivh2.ivh_rateby,'T') ivh_rateby,
			ivh2.ivh_hideshipperaddr,
			ivh2.ivh_hideconsignaddr,
			IsNull(ivh2.ivh_charge,0.0) ivh_charge,
			1 sortorder,
			firstDRPSeq = case ivh2.ord_number
			   when '0' then 0
			   else (select min(id2.ivd_sequence) from invoicedetail id2 
				  where id2.ivh_hdrnumber = ivh2.ivh_hdrnumber and id2.ivd_type = 'DRP')
			   end
			from stops stp
				inner join freightdetail fgt on fgt.stp_number = stp.stp_number
				inner join invoiceheader ivh2 on ivh2.ivh_hdrnumber = @invoice_nbr
				inner join invoicedetail ivd2 on ivd2.ivh_hdrnumber = ivh2.ivh_hdrnumber
				left outer join chargetype ct on ct.cht_itemcode = 'LHF'
				left outer join commodity cmd on  cmd.cmd_code = fgt.cmd_code
				left outer join commodityclass cc ON cc.ccl_code = cmd.cmd_class
				left outer join event ev on ev.stp_number = stp.stp_number
			where stp.stp_type = 'DRP' and stp.ord_hdrnumber = (select top 1 ord_hdrnumber from #invtemp_tbl)
			order by stp_mfh_sequence,fgt_sequence
		end
	else
		begin
--			select stp_mfh_sequence,fgt_sequence,stp.*,ivh2.*
			insert into #invtemp_tbl
			select 
			ivh2.ivh_invoicenumber,
			ivh2.ivh_hdrnumber, 
			ivh2.ord_number, 
			ivh2.ivh_billto, 
			@temp_name ivh_billto_name ,
			@temp_addr 	ivh_billto_addr,
			@temp_addr2	ivh_billto_addr2,
			@temp_nmstct ivh_billto_nmctst,
			ivh2.ivh_terms,   	
			ivh2.ivh_totalcharge,   
			ivh2.ivh_shipper,   
			@temp_name	shipper_name,
			@temp_addr	shipper_addr,
			@temp_addr2	shipper_addr2,
			@temp_nmstct shipper_nmctst,
			ivh2.ivh_consignee,   
			@temp_name consignee_name,
			@temp_addr consignee_addr,
			@temp_addr2	consignee_addr2,
			@temp_nmstct consignee_nmctst,
			ivh2.ivh_originpoint,   
			@temp_name originpoint_name,
			@temp_addr origin_addr,
			@temp_addr2	origin_addr2,
			@temp_nmstct origin_nmctst,
			ivh2.ivh_destpoint,   
			@temp_name destpoint_name,
			@temp_addr dest_addr,
			@temp_addr2	dest_addr2,
			@temp_nmstct dest_nmctst,
			ivh2.ivh_invoicestatus,   
			ivh2.ivh_origincity,   
			ivh2.ivh_destcity,   
			ivh2.ivh_originstate,   
			ivh2.ivh_deststate,
			ivh2.ivh_originregion1,   
			ivh2.ivh_destregion1,   
			ivh2.ivh_supplier,   
			ivh2.ivh_shipdate,   
			ivh2.ivh_deliverydate,   
			ivh2.ivh_revtype1,   
			ivh2.ivh_revtype2,   
			ivh2.ivh_revtype3,   
			ivh2.ivh_revtype4,   
			ivh2.ivh_totalweight,   
			ivh2.ivh_totalpieces,   
			ivh2.ivh_totalmiles,   
			ivh2.ivh_currency,   
			ivh2.ivh_currencydate,   
			ivh2.ivh_totalvolume,   
			ivh2.ivh_taxamount1,   
			ivh2.ivh_taxamount2,   
			ivh2.ivh_taxamount3,   
			ivh2.ivh_taxamount4,   
			ivh2.ivh_transtype,   
			ivh2.ivh_creditmemo,   
			ivh2.ivh_applyto,   
			ivh2.ivh_printdate,   
			ivh2.ivh_billdate,   
			ivh2.ivh_lastprintdate,   
			ivh2.ivh_originregion2,   
			ivh2.ivh_originregion3,   
			ivh2.ivh_originregion4,   
			ivh2.ivh_destregion2,   
			ivh2.ivh_destregion3,   
			ivh2.ivh_destregion4,   
			ivh2.mfh_hdrnumber,   
			ivh2.ivh_remark,   
			ivh2.ivh_driver,   
			ivh2.ivh_tractor,   
			ivh2.ivh_trailer,   
			ivh2.ivh_user_id1,   
			ivh2.ivh_user_id2,   
			ivh2.ivh_ref_number,   
			ivh2.ivh_driver2,   
			ivh2.mov_number,   
			ivh2.ivh_edi_flag,   
			ivh2.ord_hdrnumber,
			0,  --ivd2.ivd_number,   
			stp.stp_number,  --ivd2.stp_number,   
			ct.cht_description,  --ivd2.ivd_description,   
			'LHF',  --ivd2.cht_itemcode,
			0,  --ivd_quantity =   case ivd2.ivd_sign
				--				  when 0 then ivd2.ivd_quantity
				--				  else case ivd2.ivd_charge
				--					   when 0 then 0
				--					   else ivd2.ivd_quantity
				--					   end
				--				  end,
			0,  --Case ct.cht_basis WHEN 'TAX' then IsNull(ivd2.ivd_rate, 0)/ 100.0000 else IsNull(ivd2.ivd_rate, 0) end as ivd_rate,
			0,  --ivd2.ivd_charge,   
			'',  --ivd2.ivd_taxable1,   
			'',  --ivd2.ivd_taxable2,   
			'',  --ivd2.ivd_taxable3,   
			'',  --ivd2.ivd_taxable4,
			'FLT',  --ivd2.ivd_unit,   
			'US',  --ivd2.cur_code,   
			ivd2.ivd_currencydate,   
			'',  --ivd2.ivd_glnum,   
			'DRP',  --ivd2.ivd_type,   
			'FLT',  --ivd2.ivd_rateunit,   
			ivd2.ivd_billto,   
			@temp_name ivd_billto_name,
			@temp_addr ivd_billto_addr,
			@temp_addr2	ivd_billto_addr2,
			@temp_nmstct ivd_billto_nmctst,
			ivd2.ivd_itemquantity,   
			ivd2.ivd_subtotalptr,   
			ivd2.ivd_allocatedrev,   
			ivd2.ivd_sequence,   
			ivd2.ivd_refnum,   
			stp.cmd_code,  --ivd2.cmd_code,   
			stp.cmp_id,  --ivd2.cmp_id,   
			@temp_name	stop_name,
			@temp_addr	stop_addr,
			@temp_addr2	stop_addr2,
			@temp_nmstct stop_nmctst,
			stp.stp_lgh_mileage,  --ivd2.ivd_distance,   
			ivd2.ivd_distunit,   
			ivd2.ivd_wgt,   
			ivd2.ivd_wgtunit,   
			ivd2.ivd_count,   
			ivd2.ivd_countunit,   
			ev.evt_number,  --ivd2.evt_number,   
			ivd2.ivd_reftype,   
			stp.stp_volume,  --ivd2.ivd_volume,   
			stp.stp_volumeunit,  --ivd2.ivd_volunit,   
			'',  --ivd2.ivd_orig_cmpid,   
			ivd2.ivd_payrevenue,
			ivh2.ivh_freight_miles,
			ivh2.tar_tarriffnumber,
			ivh2.tar_tariffitem,
			1 copies,
			'Y',  --ct.cht_primary,
			'SHP',  --ct.cht_basis,
			ct.cht_description,
			cmd.cmd_name,
			cc.ccl_description cmd_class,
			@temp_altid cmp_altid,
			ref_number = ' ',  -- not used on format150 SQL2k does not like empty string
			0,  --fgt.fgt_number,
			isnull(ivh2.ivh_rateby,'T') ivh_rateby,
			ivh2.ivh_hideshipperaddr,
			ivh2.ivh_hideconsignaddr,
			IsNull(ivh2.ivh_charge,0.0) ivh_charge,
			1 sortorder,
			firstDRPSeq = case ivh2.ord_number
			   when '0' then 0
			   else (select min(id2.ivd_sequence) from invoicedetail id2 
				  where id2.ivh_hdrnumber = ivh2.ivh_hdrnumber and id2.ivd_type = 'DRP')
			   end
			from stops stp
				inner join invoiceheader ivh2 on ivh2.ivh_hdrnumber = @invoice_nbr
				inner join invoicedetail ivd2 on ivd2.ivh_hdrnumber = ivh2.ivh_hdrnumber
				left outer join chargetype ct on ct.cht_itemcode = 'LHF'
				left outer join commodity cmd on  cmd.cmd_code = stp.cmd_code
				left outer join commodityclass cc ON cc.ccl_code = cmd.cmd_class
				left outer join event ev on ev.stp_number = stp.stp_number
			where stp_type = 'DRP' and stp.ord_hdrnumber = (select top 1 ord_hdrnumber from #invtemp_tbl)
			order by stp_mfh_sequence
		end
end
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
if (select count(*) from #invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end
/* RETRIEVE COMPANY DATA */	                   			
--if @useasbillto = 'BLT'
--	begin
	/*	
		--LOR	PTS#4789(SR# 7160)	
	If ((select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name = '') > 0 or
	     (select count(*) 
		from company c, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is null) > 0 or
	     (select count(*)
		from #invtemp_tbl t, chargetype ch, company c
		where c.cmp_id = t.ivh_billto and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y') = 0 or
	     (select count(*) 
		from company c, chargetype ch, #invtemp_tbl t
		where c.cmp_id = t.ivh_billto and
			c.cmp_mailto_name is not null and
			c.cmp_mailto_name not in ('') and
			ch.cht_itemcode = t.cht_itemcode and
			ch.cht_primary = 'Y' and
			t.ivh_terms not in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3)) > 0)
	*/
	If Not Exists (Select cmp_mailto_name From company c, #invtemp_tbl t
        Where c.cmp_id = t.ivh_billto
			And Rtrim(IsNull(cmp_mailto_name,'')) > ''
			And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
				Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
			And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	
		
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = CASE WHEN charindex('/', company.cty_nmstct) > 0 THEN substring(company.cty_nmstct, 1, (charindex('/', company.cty_nmstct))-1) ELSE company.cty_nmstct END + ' ' + company.cmp_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
	Else	
		update #invtemp_tbl
		set ivh_billto_name = company.cmp_mailto_name,
			 ivh_billto_addr = company.cmp_mailto_address1,
			 ivh_billto_addr2 = company.cmp_mailto_address2,		
			 ivh_billto_nmctst = CASE WHEN charindex('/', company.mailto_cty_nmstct) > 0 THEN substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct))-1) ELSE mailto_cty_nmstct  END + ' ' + company.cmp_mailto_zip,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_billto
--	end	
/*		
if @useasbillto = 'ORD'
	begin
	update #invtemp_tbl
		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company, invoiceheader
		where #invtemp_tbl.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
				company.cmp_id = invoiceheader.ivh_order_by
	end			
if @useasbillto = 'SHP'
	begin
	update #invtemp_tbl

		set ivh_billto_name = company.cmp_name,
			 ivh_billto_addr = company.cmp_address1,
			 ivh_billto_addr2 = company.cmp_address2,		
			 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' + company.cmp_zip ,
			#invtemp_tbl.cmp_altid = company.cmp_altid 
		from #invtemp_tbl, company
		where company.cmp_id = #invtemp_tbl.ivh_shipper
	end			
*/			
update #invtemp_tbl
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = CASE WHEN charindex('/', city.cty_nmstct) > 0 THEN substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))-1) ELSE city.cty_nmstct END 
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_originpoint
	and city.cty_code =  #invtemp_tbl.ivh_origincity			
				
update #invtemp_tbl
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst = CASE WHEN charindex('/', city.cty_nmstct) > 0 THEN substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))-1) ELSE city.cty_nmstct END+ ' ' + ISNULL(city.cty_zip,'')
from #invtemp_tbl, company, city
where company.cmp_id = #invtemp_tbl.ivh_destpoint
	and city.cty_code =  #invtemp_tbl.ivh_destcity
				
update #invtemp_tbl
set shipper_name = company.cmp_name,
	shipper_addr = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,
	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	shipper_nmctst = CASE WHEN charindex('/', company.cty_nmstct) > 0 THEN substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))-1) ELSE company.cty_nmstct END+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.ivh_shipper
				
update #invtemp_tbl
set shipper_nmctst =  origin_nmctst
where ivh_shipper = 'UNKNOWN'
			
update #invtemp_tbl
set consignee_name = company.cmp_name,
	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	consignee_nmctst = CASE WHEN charindex('/', company.cty_nmstct) > 0 THEN substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))-1) ELSE company.cty_nmstct END+ ' ' +company.cmp_zip 
from #invtemp_tbl, company
where company.cmp_id = #invtemp_tbl.ivh_consignee	
				
update #invtemp_tbl
set consignee_nmctst =  dest_nmctst
where ivh_consignee = 'UNKNOWN'		
					
-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
update #invtemp_tbl
set 	stop_nmctst = CASE WHEN charindex('/', city.cty_nmstct) > 0 THEN substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct))-1) ELSE city.cty_nmstct END + ' ' +city.cty_zip 
from 	#invtemp_tbl, city  RIGHT OUTER JOIN  stops  ON  city.cty_code  = stops.stp_city --pts40188 outer join conversion
where 	#invtemp_tbl.stp_number IS NOT NULL
	and	stops.stp_number =  #invtemp_tbl.stp_number

-- PTS47962 Changed update for company to get zip from company table and moved update to gather 
-- company info and put it here because the above statement was pulling the zip from the city table.
UPDATE #invtemp_tbl
   SET stop_name = company.cmp_name,
       stop_addr = company.cmp_address1,
       stop_addr2 = company.cmp_address2,
       stop_nmctst = CASE 
                        WHEN charindex('/', company.cty_nmstct) > 0 THEN substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct))-1) 
                        ELSE company.cty_nmstct 
                     END + ' ' + company.cmp_zip
  FROM #invtemp_tbl JOIN company ON #invtemp_tbl.cmp_id = company.cmp_id
 WHERE #invtemp_tbl.stp_number > 0 AND
       #invtemp_tbl.cmp_id <> 'UNKNOWN'

--make sure minimum charges are after line haul and before other accessorials
UPDATE #invtemp_tbl
SET sortorder = 1
WHERE cht_primary = 'Y'

UPDATE #invtemp_tbl
SET sortorder = 3
WHERE cht_primary = 'N'

UPDATE #invtemp_tbl
SET sortorder = 2
WHERE cht_primary = 'Y' and cht_itemcode = 'MIN'

-- Make sure bill miles include those from any e

update #invtemp_tbl
set ivd_distance = (select sum(isnull(ivd_distance,0))
   from invoicedetail id 
   where   #invtemp_tbl.ivh_hdrnumber = id.ivh_hdrnumber
   and id.ivd_sequence <= #invtemp_tbl.firstDRPSeq)
where ivd_sequence = firstDRPSeq

				
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @counter = 1
while @counter <>  @copies
begin
	select @counter = @counter + 1
 	insert into #invtemp_tbl
 	SELECT  ivh_invoicenumber,   
         ivh_hdrnumber, 
		ord_number,
	 ivh_billto, 
	 ivh_billto_name ,
	 ivh_billto_addr,
	 ivh_billto_addr2,
	 ivh_billto_nmctst,
         ivh_terms,   	
         ivh_totalcharge,   
	 ivh_shipper,   
	 shipper_name,
	 shipper_addr,
	 shipper_addr2,
	 shipper_nmctst,
         ivh_consignee,   
	 consignee_name,
	 consignee_addr,
	 consignee_addr2,
	 consignee_nmctst,
         ivh_originpoint,   
	 originpoint_name,
	 origin_addr,
	 origin_addr2,
	 origin_nmctst,
         ivh_destpoint,   
	 destpoint_name,
	 dest_addr,
	 dest_addr2,
	 dest_nmctst,
         ivh_invoicestatus,   
         ivh_origincity,   
         ivh_destcity,   
         ivh_originstate,   
         ivh_deststate,   
         ivh_originregion1,   
         ivh_destregion1,   
         ivh_supplier,   
         ivh_shipdate,   
         ivh_deliverydate,   
         ivh_revtype1,   
         ivh_revtype2,   
         ivh_revtype3,   
         ivh_revtype4,   
         ivh_totalweight,   
         ivh_totalpieces,   
         ivh_totalmiles,   
         ivh_currency,   
         ivh_currencydate,   
         ivh_totalvolume, 
         ivh_taxamount1,   
         ivh_taxamount2,   
         ivh_taxamount3,   
         ivh_taxamount4,   
         ivh_transtype,   
         ivh_creditmemo,   
         ivh_applyto,   
         ivh_printdate,   
         ivh_billdate,   
         ivh_lastprintdate,   
         ivh_originregion2,   
         ivh_originregion3,   
         ivh_originregion4,   
         ivh_destregion2,   
         ivh_destregion3,   
         ivh_destregion4,   
         mfh_hdrnumber,   
         ivh_remark,   
         ivh_driver,   
         ivh_tractor,   
         ivh_trailer,   
         ivh_user_id1,   
         ivh_user_id2,   
         ivh_ref_number,   
         ivh_driver2,   
         mov_number,   
         ivh_edi_flag,   
         ord_hdrnumber,   
         ivd_number,   
         stp_number,   
         ivd_description,   
         cht_itemcode,   
         ivd_quantity,   
         ivd_rate,   
         ivd_charge,   
         ivd_taxable1,   
         ivd_taxable2,   
	 ivd_taxable3,   
         ivd_taxable4,   
         ivd_unit,   
         cur_code,   
         ivd_currencydate,   
         ivd_glnum,   
         ivd_type,   
         ivd_rateunit,   
         ivd_billto,  
	 ivd_billto_name,
	 ivd_billto_addr,
	 ivd_billto_addr2,
	 ivd_billto_nmctst,
         ivd_itemquantity,   
         ivd_subtotalptr,   
         ivd_allocatedrev,   
         ivd_sequence,   
         ivd_refnum,   
         cmd_code, 
         cmp_id,   
	 stop_name,
	 stop_addr,
	 stop_addr2,
	 stop_nmctst,
         ivd_distance,   
         ivd_distunit,   
         ivd_wgt,   
         ivd_wgtunit,   
         ivd_count,   
         ivd_countunit,   
         evt_number,   
         ivd_reftype,   
         ivd_volume,   
         ivd_volunit,   
         ivd_orig_cmpid,   
         ivd_payrevenue,
	 ivh_freight_miles,
	 tar_tarriffnumber,
	 tar_tariffitem,
	 @counter,
	 cht_primary,
	 cht_basis,
	 cht_description,
	 cmd_name,
	cmd_class,
	cmp_altid,
	 ref_number,
	fgt_number,
	ivh_rateby,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_charge,
	sortorder,
    firstDRPSeq
	from #invtemp_tbl
	where copies = 1   
end 
	                                                            	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select ivh_invoicenumber,   
         ivh_hdrnumber, 
		ord_number,
	 ivh_billto, 
	 ivh_billto_name ,
	 ivh_billto_addr,
	 ivh_billto_addr2,
	 ivh_billto_nmctst,
         ivh_terms,   	
         ivh_totalcharge,   
	 ivh_shipper,   
	 shipper_name,
	 shipper_addr,
	 shipper_addr2,
	 shipper_nmctst,
         ivh_consignee,   
	 consignee_name,
	 consignee_addr,
	 consignee_addr2,
	 consignee_nmctst,
         ivh_originpoint,   
	 originpoint_name,
	 origin_addr,
	 origin_addr2,
	 origin_nmctst,
         ivh_destpoint,   
	 destpoint_name,
	 dest_addr,
	 dest_addr2,
	 dest_nmctst,
         ivh_invoicestatus,   
         ivh_origincity,   
         ivh_destcity,   
         ivh_originstate,   
         ivh_deststate,   
         ivh_originregion1,   
         ivh_destregion1,   
         ivh_supplier,   
         ivh_shipdate,   
         ivh_deliverydate,   
         ivh_revtype1,   
         ivh_revtype2,   
         ivh_revtype3,   
         ivh_revtype4,   
         ivh_totalweight,   
         ivh_totalpieces,   
         ivh_totalmiles,   
         ivh_currency,   
         ivh_currencydate,   
         ivh_totalvolume, 
         ivh_taxamount1,   
         ivh_taxamount2,   
         ivh_taxamount3,   
         ivh_taxamount4,   
         ivh_transtype,   
         ivh_creditmemo,   
         ivh_applyto,   
         ivh_printdate,   
         ivh_billdate,   
         ivh_lastprintdate,   
         ivh_originregion2,   
         ivh_originregion3,   
         ivh_originregion4,   
         ivh_destregion2,   
         ivh_destregion3,   
         ivh_destregion4,   
         mfh_hdrnumber,   
         ivh_remark,   
         ivh_driver,   
         ivh_tractor,   
         ivh_trailer,   
         ivh_user_id1,   
         ivh_user_id2,   
         ivh_ref_number,   
         ivh_driver2,   
         mov_number,   
         ivh_edi_flag,   
         ord_hdrnumber,   
         ivd_number,   
         stp_number,   
         ivd_description,   
         cht_itemcode,   
         ivd_quantity,   
         ivd_rate,   
         ivd_charge,   
         ivd_taxable1,   
         ivd_taxable2,   
	 ivd_taxable3,   
         ivd_taxable4,   
         ivd_unit,   
         cur_code,   
         ivd_currencydate,   
         ivd_glnum,   
         ivd_type,   
         ivd_rateunit,   
         ivd_billto,  
	 ivd_billto_name,
	 ivd_billto_addr,
	 ivd_billto_addr2,
	 ivd_billto_nmctst,
         ivd_itemquantity,   
         ivd_subtotalptr,   
         ivd_allocatedrev,   
         ivd_sequence,   
         ivd_refnum,   
         cmd_code, 
         cmp_id,   
	 stop_name,
	 stop_addr,
	 stop_addr2,
	 stop_nmctst,
         ivd_distance,   
         ivd_distunit,   
         ivd_wgt,   
         ivd_wgtunit,   
         ivd_count,   
         ivd_countunit,   
         evt_number,   
         ivd_reftype,   
         ivd_volume,   
         ivd_volunit,   
         ivd_orig_cmpid,   
         ivd_payrevenue,
	 ivh_freight_miles,
	 tar_tarriffnumber,
	 tar_tariffitem,
	 copies,
	 cht_primary,
	 cht_basis,
	 cht_description,
	 cmd_name,
	cmd_class,
	cmp_altid,
	 ref_number,
	fgt_number,
	ivh_rateby,
	sortorder
  -- ,firstDRPSeq
from #invtemp_tbl
ORDER BY sortorder, ivd_sequence

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value

GO
GRANT EXECUTE ON  [dbo].[invoice_template150] TO [public]
GO
