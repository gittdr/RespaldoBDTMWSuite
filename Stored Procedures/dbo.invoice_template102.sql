SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[invoice_template102](@invoice_nbr   int,@copies int)  
AS  
set nocount on
  
/**
 * 
 * NAME:
 * dbo.invoice_template102
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Provide a return set of all the invoice detail records 
 * based on the invoice number selected in the interface.
 *
 * RETURNS:
 * 0 - IF NO DATA WAS FOUND  
 * 1 - IF SUCCESFULLY EXECUTED  
 * @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @invoice_nbr, int, input, null;
 *       This parameter indicates the INVOICE NUMBER(ie.ivh_hdrnumber)
 *       for which the invoice will be printed. The value must be 
 *       non-null and non-empty.
 * 002 - @copies, int, input, null;
 *       This parameter indicates the number of hard copies 
 *       to print. The value must be non-null and 
 *       non-empty. 
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * N/A
 * 
 * 
 * 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 06/29/2001	Vern Jewett		vmj1	PTS 10870: not returning copy # correctly.
 * 12/5/2 16314 DPETE use GI settings to control terms and linehaul restricitons on mail to
 * 09/27/2007   PTS32976 - Imari Bremer - create a new invoice format for the increased size of the trailer number on the datawindow
* 6/21/12 DPETE PTS 62392 make performance changes for Mindy Curnutt DBA
* 7/5/12 PTS62706 performance changes from Mark Bugner. Added my own enhancements for the stop ref numbers and added ability
*      to handle new style roll into line haul 
*****(now both procs template102 and 102_rollin are the same proc)
*       , Saw issue with
*       invoicedetail ref number printing without a space between the type and number and the combination being wordcapped
*       but got no response when I asked about the issue, so I left it alone.
 **/

declare	@temp_name   varchar(30) ,
	@temp_addr   varchar(30) ,
	@temp_addr2  varchar(30),
	@temp_nmstct varchar(30),
	@counter    int,
	@ret_value  int,
	@varchar25  varchar(25),
	--PTS# 32916 ILB 08/22/2006
        @v_MinStp   int,
	@reftype    varchar(50),
 	@refnumber  varchar(50)
	--PTS# 32916 ILB 08/22/2006
	,@ord_hdrnumber int
--PTS#   
DECLARE @invtemp_tbl TABLE  
(ivh_invoicenumber varchar(12) not null,     
 ivh_hdrnumber int not null,   
 ivh_billto varchar(8) null,   
 ivh_billto_name varchar(100)null,  
 ivh_billto_addr varchar(100)null,  
 ivh_billto_addr2 varchar(100)null,  
 ivh_billto_nmctst  varchar(100)null,  
 ivh_terms char(3)null,      
 ivh_totalcharge money null,     
 ivh_shipper varchar(8)null,     
 shipper_name varchar(100)null,  
 shipper_addr varchar(100)null,  
 shipper_addr2 varchar(100)null,  
 shipper_nmctst varchar(100)null,  
 ivh_consignee varchar(8)null,     
 consignee_name varchar(100)null,  
 consignee_addr varchar(100)null,  
 consignee_addr2 varchar(100)null,  
 consignee_nmctst varchar(100)null,  
 ivh_originpoint varchar(8)null,     
 originpoint_name varchar(100)null,  
 origin_addr varchar(100) null,  
 origin_addr2 varchar(100)null,  
 origin_nmctst varchar(100)null,  
 ivh_destpoint varchar(8)null,     
 destpoint_name varchar(100)null,  
 dest_addr varchar(100)null,  
 dest_addr2 varchar(100)null,  
 dest_nmctst varchar(100)null,  
 ivh_invoicestatus varchar(6)null,     
 ivh_origincity int null,     
 ivh_destcity int null,     
 ivh_originstate char(2)null,   
 ivh_deststate char(2)null,  
 ivh_originregion1 varchar(6)null,     
 ivh_destregion1 varchar(6)null,     
 ivh_supplier varchar(8)null,     
 ivh_shipdate datetime null,     
 ivh_deliverydate datetime null,     
 ivh_revtype1 varchar(6) null,     
 ivh_revtype2 varchar(6)null,     
 ivh_revtype3 varchar(6)null,     
 ivh_revtype4 varchar(6)null,     
 ivh_totalweight float null,     
 ivh_totalpieces float null,     
 ivh_totalmiles float null,     
 ivh_currency varchar(6)null,     
 ivh_currencydate datetime null,     
 ivh_totalvolume float null,     
 ivh_taxamount1 money null,     
 ivh_taxamount2 money null,     
 ivh_taxamount3 money null,     
 ivh_taxamount4 money null,     
 ivh_transtype varchar(6)null,     
 ivh_creditmemo char(1)null,     
 ivh_applyto varchar(12)null,     
 ivh_printdate datetime null,     
 ivh_billdate datetime null,     
 ivh_lastprintdate datetime null,     
 ivh_originregion2 varchar(6)null,     
 ivh_originregion3 varchar(6)null,     
 ivh_originregion4 varchar(6)null,     
 ivh_destregion2 varchar(6)null,     
 ivh_destregion3 varchar(6)null,     
 ivh_destregion4 varchar(6)null,     
 mfh_hdrnumber int null,     
 ivh_remark varchar(254)null,     
 ivh_driver varchar(8)null,     
 ivh_tractor varchar(8)null,     
 ivh_trailer varchar(13)null,     
 ivh_user_id1 char(20)null,     
 ivh_user_id2 char(20)null,     
 ivh_ref_number varchar(30)null,     
 ivh_driver2 varchar(8)null,     
 mov_number int null,     
 ivh_edi_flag char(30)null,     
 ord_hdrnumber int null,     
 ivd_number int null,     
 stp_number int null,     
 ivd_description varchar(60) null,     
 cht_itemcode varchar(6)null,     
 ivd_quantity float null,     
 ivd_rate money null,     
 ivd_charge money null,     
 ivd_taxable1 char(1)null,     
 ivd_taxable2 char(1)null,     
 ivd_taxable3 char(1)null,     
 ivd_taxable4 char(1)null,     
 ivd_unit varchar(6)null,     
 cur_code varchar(6)null,     
 ivd_currencydate datetime null,     
 ivd_glnum char(32)null,     
 ivd_type varchar(6) null,     
 ivd_rateunit varchar(6) null,     
 ivd_billto varchar(8) null,     
 ivd_billto_name varchar(100) null,  
 ivd_billto_addr varchar(100) null,  
 ivd_billto_addr2 varchar(100) null,  
 ivd_billto_nmctst varchar(100) null,  
 ivd_itemquantity float null,     
 ivd_subtotalptr int null,     
 ivd_allocatedrev money null,     
 ivd_sequence int null,     
 ivd_refnum varchar(30) null,     
 cmd_code varchar(8) null,     
 cmp_id varchar(8) null,     
 stop_name varchar(100) null,  
 stop_addr varchar(100) null,  
 stop_addr2 varchar(100) null,  
 stop_nmctst varchar(100) null,  
 ivd_distance float null,     
 ivd_distunit varchar(6) null,      
 ivd_wgt float null,     
 ivd_wgtunit varchar(6) null,     
 ivd_count decimal(10,2) null,     
 ivd_countunit varchar(6) null,     
 evt_number int null,     
 ivd_reftype varchar(6) null,     
 ivd_volume float null,     
 ivd_volunit varchar(6) null,     
 ivd_orig_cmpid varchar(8) null,     
 ivd_payrevenue money null,  
 ivh_freight_miles float null,  
 tar_tarriffnumber varchar(12) null,  
 tar_tariffitem varchar(12) null,  
 copies int null,  
 cht_basis varchar(6) null,  
 cht_description varchar(30) null,  
 cmd_name varchar(60) null,  
 tar_number int null,  
 ivd_tarnumber int null,  
 ivd_tartariffnumber varchar(12) null,  
 ivd_tartariffitem varchar(12) null,  
 cmp_altid varchar(25) null,  
 cht_primary char(1) null,          
 ivh_hideshipperaddr char(1) null,  
 ivh_hideconsignaddr char(1) null,  
 ivh_showshipper varchar(8) null,  
 ivh_showcons varchar(8) null , 
 --PTS# 32916 ILB 08/22/2006  
 ref_type1 varchar(50) null,  
 ref_number1 varchar(50) null,  
 ref_type2 varchar(50) null,  
 ref_number2 varchar(50) null,  
 --PTS# 32916 ILB 08/22/2006  
 ivh_charge money null,
 cht_rollintolh int NULL  
) 
declare @stoprefs1 table (stp_number int,ref_sequence int null, ref_type varchar(14)null, ref_number varchar(60) null)
declare @stoprefs2 table (stp_number int,ref_sequence int null, ref_type varchar(14)null, ref_number varchar(60) null)
declare @rollintolhamount money,@ratefactor float,@unit varchar(6),@rateunit varchar(6)

select @ord_hdrnumber = ord_hdrnumber 
from invoiceheader where ivh_hdrnumber = @invoice_nbr

If @ord_hdrnumber > 0 
  BEGIN
    insert into @stoprefs1
    select ref_tablekey,ref_sequence,'Reftype ' + ref_type,'Ref# ' + ref_number
    from referencenumber WITH(NOLOCK)
    WHERE ord_hdrnumber = @ord_hdrnumber
    AND ref_table = 'stops'
    and ref_sequence =1
    
    insert into @stoprefs2
    select ref_tablekey,ref_sequence,'Reftype ' + ref_type,'Ref# ' + ref_number
    from referencenumber WITH(NOLOCK)
    WHERE ord_hdrnumber = @ord_hdrnumber
    AND ref_table = 'stops'
    and ref_sequence = 2
  
  END
  

/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1



/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */
select @ret_value = 1



/* CREATE TEMP TABLE AND SELECT INITIAL DATA SET 
	NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/
INSERT     into @invtemp_tbl  
SELECT  invoiceheader.ivh_invoicenumber,   
         invoiceheader.ivh_hdrnumber, 
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
         invoicedetail.ivd_quantity,   
         invoicedetail.ivd_rate,   
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
	 chargetype.cht_basis,
	 chargetype.cht_description,
	 commodity.cmd_name,
	 invoiceheader.tar_number,
	invoicedetail.tar_number as ivd_tarnumber,
	invoicedetail.tar_tariffnumber as ivd_tartariffnumber,
	invoicedetail.tar_tariffitem as ivd_tartariffitem,
	@varchar25 as cmp_altid,
	chargetype.cht_primary,        
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	(Case ivh_showshipper 
		when 'UNKNOWN' then invoiceheader.ivh_shipper
		else IsNull(ivh_showshipper,invoiceheader.ivh_shipper) 
	end) ivh_showshipper,
	(Case ivh_showcons 
		when 'UNKNOWN' then invoiceheader.ivh_consignee
		else IsNull(ivh_showcons,invoiceheader.ivh_consignee) 
	end) ivh_showcons,
	/*--PTS# 32916 ILB 08/22/2006
	@reftype ref_type1,
        @refnumber ref_number1,
	@reftype ref_type2,
        @refnumber ref_number2,
	--PTS# 32916 ILB 08/22/2006 */
	ISNULL(sr1.ref_type,'') ref_type1,
	ISNULL(sr1.ref_number,'') ref_number1,
	ISNULL(sr2.ref_type,'') ref_type2,
	ISNULL(sr2.ref_number,'') ref_number2,
	IsNull(ivh_charge,0.0) ivh_charge,
	ISNULL(invoicedetail.cht_rollintolh ,chargetype.cht_rollintolh) cht_rollintolh  
  --  into #invtemp_tbl
    FROM --invoiceheader, invoicedetail, chargetype, commodity
       --  invoiceheader JOIN invoicedetail ON (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )  
       --  RIGHT OUTER JOIN chargetype ON ( chargetype.cht_itemcode = invoicedetail.cht_itemcode)   
        -- LEFT OUTER JOIN commodity ON (invoicedetail.cmd_code = commodity.cmd_code) 
        (select * from invoiceheader with (NOLOCK) where ivh_hdrnumber = @invoice_nbr) as invoiceheader JOIN 
         (select * from invoicedetail with (NOLOCK) where ivh_hdrnumber = @invoice_nbr) as invoicedetail ON (invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber )    
         RIGHT OUTER JOIN chargetype WITH (NOLOCK) ON ( chargetype.cht_itemcode = invoicedetail.cht_itemcode)     
         LEFT OUTER JOIN commodity WITH (NOLOCK) ON (invoicedetail.cmd_code = commodity.cmd_code) 
         LEFT OUTER JOIN @stoprefs1 sr1 on invoicedetail.stp_number = sr1.stp_number
         LEFT OUTER JOIN @stoprefs2 sr2  on invoicedetail.stp_number = sr1.stp_number 
   WHERE --(invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber ) and
	 --(chargetype.cht_itemcode =* invoicedetail.cht_itemcode) and
	 --(invoicedetail.cmd_code *= commodity.cmd_code) and
    	  invoiceheader.ivh_hdrnumber = @invoice_nbr
	
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */
--if (select count(*) from #invtemp_tbl) = 0
if (select count(*) from @invtemp_tbl) = 0
	begin
	select @ret_value = 0  
	GOTO ERROR_END
	end
	--***********************************************
select @rollintolhamount = sum(ivd_charge)
from @invtemp_tbl tbl
where cht_rollintolh = 1
and ivd_type = 'LI'
and cht_basis = 'ACC'


select @rollintolhamount = isnull(@rollintolhamount,0)
-- roll up only if rating by total for an order
If @rollintolhamount <> 0 and exists (select 1 from invoiceheader where ivh_hdrnumber = @invoice_nbr
    and ivh_rateby = 'T' and ord_hdrnumber > 0)
  BEGIN  -- if min charge or quantity applied modify it
    If exists (select 1 from @invtemp_tbl where cht_itemcode = 'MIN')
      BEGIN
        select @unit = ivd_unit,
        @rateunit = ivd_rateunit
        from @invtemp_tbl tbl
        where cht_itemcode = 'MIN'
        
        select @ratefactor = unc_factor
        from unitconversion
        where unc_from = @unit
        and unc_to = @rateunit
        and unc_convflag = 'R'

        select @ratefactor = isnull(@ratefactor,1)

		update @invtemp_tbl
	    set ivd_charge = ivd_charge + @rollintolhamount,
            ivd_rate = case ivd_quantity 
            when 0 then ivd_charge + @rollintolhamount
            else  round((ivd_charge + @rollintolhamount) / (ivd_quantity * @ratefactor),4)
            end
        where cht_itemcode = 'MIN'
      END
    else 
      BEGIN
       select @unit = ivd_unit,
        @rateunit = ivd_rateunit
        from @invtemp_tbl tbl
        where ivd_type = 'SUB'
 
        select @ratefactor = unc_factor
        from unitconversion
        where unc_from = @unit
        and unc_to = @rateunit
        and unc_convflag = 'R'

        select @ratefactor = isnull(@ratefactor,1)

		update @invtemp_tbl
	    set ivd_charge = ivd_charge + @rollintolhamount,
            ivd_rate = case ivd_quantity 
            when 0 then ivd_charge + @rollintolhamount
            else  round((ivd_charge + @rollintolhamount) / (ivd_quantity * @ratefactor),4)
            end
        where ivd_type = 'SUB'
       END
    
    delete from @invtemp_tbl 
    where cht_rollintolh = 1


  END


--****************************

If Not Exists (Select cmp_mailto_name From company c WITH (NOLOCK) , @invtemp_tbl t
Where c.cmp_id = t.ivh_billto
		And Rtrim(IsNull(cmp_mailto_name,'')) > ''
		And t.ivh_terms in (c.cmp_mailto_crterm1,	c.cmp_mailto_crterm2,	c.cmp_mailto_crterm3,	
			Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)
		And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End	)	

	--update #invtemp_tbl
	update a
	set ivh_billto_name = company.cmp_name,
		 ivh_billto_addr = company.cmp_address1,
		 ivh_billto_addr2 = company.cmp_address2,		
		 ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct + '/')))+ ' ' + company.cmp_zip,
		--#invtemp_tbl.cmp_altid = company.cmp_altid
		a.cmp_altid = company.cmp_altid 
	--from #invtemp_tbl, company 
	from @invtemp_tbl a, dbo.company WITH(NOLOCK)
	--where company.cmp_id = #invtemp_tbl.ivh_billto
	where company.cmp_id = a.ivh_billto
Else	
	--update #invtemp_tbl
	update a
	set ivh_billto_name = company.cmp_mailto_name,
		 ivh_billto_addr = company.cmp_mailto_address1,
		 ivh_billto_addr2 = company.cmp_mailto_address2,		
		 ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct + '/')))+ ' ' + company.cmp_mailto_zip,
		--#invtemp_tbl.cmp_altid = company.cmp_altid 
		a.cmp_altid = company.cmp_altid
	--from #invtemp_tbl, company
	from @invtemp_tbl a, company WITH(NOLOCK)
	--where company.cmp_id = #invtemp_tbl.ivh_billto
	where company.cmp_id = a.ivh_billto


--update #invtemp_tbl
update a
set originpoint_name = company.cmp_name,
	origin_addr = company.cmp_address1,
	origin_addr2 = company.cmp_address2,
	origin_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct + '/')))+ ' ' + ISNULL(city.cty_zip,'') 
--from #invtemp_tbl, company, city
from @invtemp_tbl a 
join company WITH(NOLOCK) on a.ivh_originpoint = company.cmp_id
join city WITH(NOLOCK) on a.ivh_origincity = city.cty_code
--where company.cmp_id = #invtemp_tbl.ivh_originpoint
--	and city.cty_code = #invtemp_tbl.ivh_origincity
				
--update #invtemp_tbl
update a
set destpoint_name = company.cmp_name,
	dest_addr = company.cmp_address1,
	dest_addr2 = company.cmp_address2,
	dest_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct + '/')))+ ' ' + ISNULL(city.cty_zip,'')
from @invtemp_tbl a
join company WITH(NOLOCK) on a.ivh_destpoint = company.cmp_id
join city WITH(NOLOCK) on a.ivh_destcity = city.cty_code 
--from #invtemp_tbl, company, city
--where company.cmp_id = #invtemp_tbl.ivh_destpoint
--	and city.cty_code = #invtemp_tbl.ivh_destcity		

--update #invtemp_tbl
update a
set shipper_name = company.cmp_name,
	shipper_addr = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,
	shipper_addr2 = Case ivh_hideshipperaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	shipper_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct + '/')))+ ' ' +company.cmp_zip 
from @invtemp_tbl a
join company WITH(NOLOCK) on a.ivh_showshipper = company.cmp_id
--from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.ivh_shipper
--where company.cmp_id = #invtemp_tbl.ivh_showshipper

--update #invtemp_tbl
update @invtemp_tbl
set 	shipper_nmctst = origin_nmctst
where     ivh_shipper = 'UNKNOWN'
					
--update #invtemp_tbl
update a
set consignee_name = company.cmp_name,
	consignee_addr = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address1
			end,			 
	consignee_addr2 = Case ivh_hideconsignaddr when 'Y' 
				then ''
				else company.cmp_address2
			end,
	consignee_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct + '/')))+ ' ' +company.cmp_zip 
from @invtemp_tbl a
join company WITH(NOLOCK) on a.ivh_showcons = company.cmp_id
--from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.ivh_consignee	
--where company.cmp_id = #invtemp_tbl.ivh_showcons	
	
--update 	#invtemp_tbl
update 	@invtemp_tbl
set 	consignee_nmctst = dest_nmctst
where     ivh_consignee = 'UNKNOWN'						

--update #invtemp_tbl
update a
set stop_name = company.cmp_name,
	stop_addr = company.cmp_address1,
	stop_addr2 = company.cmp_address2
--		 stop_nmctst = substring(company.cty_nmstct,1, (charindex('/', company.cty_nmstct)))+ ' ' +company.cmp_zip 
from @invtemp_tbl a
join company WITH(NOLOCK) on a.cmp_id = company.cmp_id
--from #invtemp_tbl, company
--where company.cmp_id = #invtemp_tbl.cmp_id				

-- dpete for UNKNOWN companies with cities must get city name from city table	pts5319	
--update #invtemp_tbl
update a
set 	stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct + '/')))+ ' ' +city.cty_zip 
--from 	#invtemp_tbl, stops,city
from @invtemp_tbl a
join stops WITH(NOLOCK) on a.stp_number = stops.stp_number
join city WITH(NOLOCK) on stops.stp_city = city.cty_code
where a.stp_number > 0
--from  stops JOIN #invtemp_tbl ON (stops.stp_number = #invtemp_tbl.stp_number) 
--      RIGHT OUTER JOIN city ON (city.cty_code = stops.stp_city )
--where 	#invtemp_tbl.stp_number IS NOT NULL
	--and	stops.stp_number =  #invtemp_tbl.stp_number
	--and	city.cty_code =* stops.stp_city		
--PTS# 32916 ILB 08/22/2006
/* code moved into temp talbe pf stop ref numbers
Select @v_MinStp = 0
WHILE (SELECT COUNT(*) 
         FROM #invtemp_tbl 
        WHERE stp_number > @v_MinStp ) > 0

	BEGIN
		SELECT @v_MinStp = (SELECT MIN(stp_number)
                            	      FROM #invtemp_tbl 
                           	     WHERE stp_number > @v_MinStp)

		update #invtemp_tbl
		   set ref_type1 = 'Reftype ' + ref_type,
                       ref_number1 = 'Ref# ' + ref_number
		  from referencenumber
                 where ref_tablekey = @v_MinStp 
                   and ref_table = 'stops' 
                   and ref_sequence = 1
                   and stp_number = @v_MinStp

		update #invtemp_tbl
		   set ref_type2 = 'Reftype ' + ref_type,
                       ref_number2 = 'Ref# ' + ref_number		 
		  from referencenumber
                 where ref_tablekey = @v_MinStp 
                   and ref_table = 'stops' 
		   and ref_sequence = 2
		   and stp_number = @v_MinStp
	END		
--PTS# 32916 ILB 08/22/2006
*/
/* MAKE COPIES OF INVOICES BASES ON INPUTTED VALUE */
select @counter = 1

while @counter <>  @copies
begin
	select @counter = @counter + 1
	--insert into #invtemp_tbl
	insert into @invtemp_tbl
	SELECT 
   	 ivh_invoicenumber,   
         ivh_hdrnumber, 
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
	 cht_basis,
	 cht_description,
	 cmd_name,
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	ivh_showshipper,
	ivh_showcons,	
	--PTS# 32916 ILB 08/22/2006
        ref_type1,
	ref_number1,
	ref_type2,
	ref_number2,
	--PTS# 32916 ILB 08/22/2006
	ivh_charge,
	cht_rollintolh
	--from #invtemp_tbl
	from @invtemp_tbl
	where copies = 1   
end 
                                                    	
ERROR_END:
/* FINAL SELECT - FORMS RETURN SET */
select ivh_invoicenumber,   
         ivh_hdrnumber, 
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

	 --vmj1+	@counter is constant for all rows!
	 copies,
--	 @counter,
	 --vmj1-

	cht_basis,
	cht_description,
	cmd_name,
	tar_number,
	ivd_tarnumber,
	ivd_tartariffnumber,
	ivd_tartariffitem,
	cmp_altid,
	cht_primary,	
	ivh_showshipper,
	ivh_showcons,	
	--PTS# 32916 ILB 08/22/2006	
	ref_type1,
	ref_number1,
	ref_type2,
	ref_number2,
	--PTS# 32916 ILB 08/22/2006
	ivh_charge	
--from #invtemp_tbl
FROM @invtemp_tbl

/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */
IF @@ERROR != 0 select @ret_value = @@ERROR 
return @ret_value
GO
GRANT EXECUTE ON  [dbo].[invoice_template102] TO [public]
GO
