SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  CREATE PROCEDURE [dbo].[invoice_template157](@invoice_nbr   int,@copies int)  
AS  
  SET nocount on
/* PROCEDURE RETURNS 0 - IF NO DATA WAS FOUND  
 1 - IF SUCCESFULLY EXECUTED  
 @@ERROR - db GLOBAL VARIABLE VALUE IF AN ERROR OCCURS  
DPETE PTS 45666 created from invoice template 2 because that is the proc for hte model format 79, create new proc
      for new format 157 which handles roll itno line haul logic if necessary eithint he proc - does not require
      flat charges
DPETE PTS 46688 emergency enhancements to format (check in 46106)
DPETE PTS 46688 ANSI nulls setting causes a problem with proc
*/  
  
DECLARE @temp_name varchar(30),  
 @temp_addr varchar(30),  
 @temp_addr2 varchar(30),  
 @temp_nmstct varchar(30),  
 @temp_altid  varchar(8),  
 @counter int,  
 @ret_value int,  
 @varchar50 varchar(50) ,
 @rollupcharges money 
DECLARE @invtemp_tbl  table (
ivh_invoicenumber varchar(12) null,   
ivh_hdrnumber int null,   
ivh_billto varchar(8) null,   
ivh_billto_name varchar(100) null,   
ivh_billto_addr varchar(100) null,   
ivh_billto_addr2 varchar(100) null,   
ivh_billto_nmctst varchar(25) null,   
ivh_terms varchar(6) null,   
ivh_totalcharge money null,   
 ivh_shipper varchar(8) null,   
shipper_name varchar(100) null,   
shipper_addr varchar(100) null,   
shipper_addr2 varchar(100) null,   
shipper_nmctst varchar(25) null,   
ivh_consignee varchar(8) null,   
consignee_name varchar(100) null,   
consignee_addr varchar(100) null,   
consignee_addr2 varchar(100) null,   
consignee_nmctst varchar(25) null,   
ivh_originpoint varchar(8) null,   
originpoint_name varchar(100) null,   
origin_addr varchar(100) null,   
origin_addr2 varchar(100) null,   
origin_nmctst varchar(25) null,   
ivh_destpoint varchar(8) null,   
destpoint_name varchar(100) null,   
dest_addr varchar(100) null,   
dest_addr2 varchar(100) null,   
dest_nmctst varchar(25) null,   
ivh_invoicestatus varchar(6) null,   
ivh_origincity int null,   
ivh_destcity int null,   
ivh_originstate char(2) null,   
ivh_deststate char(2) null,   
ivh_originregion1 varchar(6) null,   
ivh_destregion1 varchar(6) null,   
ivh_supplier varchar(8) null,   
 ivh_shipdate datetime null,   
ivh_deliverydate datetime null,   
ivh_revtype1 varchar(6) null,   
ivh_revtype2 varchar(6) null,    
ivh_revtype3 varchar(6) null,    
ivh_revtype4 varchar(6) null,     
ivh_totalweight float null,   
ivh_totalpieces float null,   
ivh_totalmiles float null,   
ivh_currency varchar(6) null,     
ivh_currencydate datetime null,   
ivh_totalvolume float null,   
ivh_taxamount1 money null,   
ivh_taxamount2 money null,   
ivh_taxamount3 money null ,  
ivh_taxamount4 money null,   
ivh_transtype varchar(6) null,     
ivh_creditmemo char(1) null,   
ivh_applyto varchar(12) null,   
ivh_printdate datetime null,   
ivh_billdate datetime null,   
ivh_lastprintdate datetime null,   
ivh_originregion2 varchar(6) null,     
ivh_originregion3 varchar(6) null,     
ivh_originregion4 varchar(6) null,     
ivh_destregion2 varchar(6) null,     
ivh_destregion3 varchar(6) null,     
ivh_destregion4  varchar(6) null,    
mfh_hdrnumber int null,   
ivh_remark varchar(254) null,   
 ivh_driver varchar(8) null,   
ivh_tractor varchar(8) null,   
ivh_trailer varchar(13) null,   
ivh_user_id1 char(20) NULL,   
ivh_user_id2 CHAR(20) NULL,   
ivh_ref_number VARCHAR(30) NULL,   
ivh_driver2 VARCHAR(8) NULL,   
mov_number INT NULL,   
ivh_edi_flag VARCHAR(30) NULL,   
ord_hdrnumber INT NULL,   
ivd_number INT NULL,   
stp_number INT NULL,   
ivd_description VARCHAR(60) NULL,  
cht_itemcode VARCHAR(6) NULL, 
ivd_quantity FLOAT NULL,   
ivd_rate money null,   
ivd_charge money null,   
ivd_taxable1 char(1) null,   
ivd_taxable2 char(1) null,   
ivd_taxable3 char(1) null,   
ivd_taxable4 char(1) null,   
ivd_unit varchar(6) null,   
cur_code varchar(6) null,   
ivd_currencydate datetime null,   
ivd_glnum varchar(32) null,   
ivd_type varchar(6) null,   
ivd_rateunit varchar(6) null,  
ivd_billto varchar(8) null,   
ivd_billto_name varchar(100) null,   
ivd_billto_addr varchar(100) null,   
ivd_billto_addr2 varchar(100) null,   
 ivd_billto_nmctst varchar(25) null,   
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
stop_nmctst varchar(25) null,   
ivd_distance float null, 
ivd_distunit varchar(6) null,   
ivd_wgt float null,   
ivd_wgtunit varchar(6) null,   
ivd_count decimal(9,2) null,   
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
cmp_altid varchar(25) null,  
ivh_hideshipperaddr char(1) null,  
ivh_hideconsignaddr char(1) null,  
ivh_showshipper varchar(8) null,  
ivh_showcons varchar(8) null,  
ivh_charge money null,  
Terms_name varchar(20) null,
 billto_addr3  varchar(100) null,
cmp_contact varchar(50) null,
 shipper_geoloc varchar(50) null,
cons_geoloc varchar(50) null,
ratefactor float null,
cht_primary char(1) null,
cht_basisunit varchar(6) null,
ivh_attention varchar(254) null,
c_total_paid money null,
c_balance_due money null
) 

 
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
select @ret_value = 1  
  
  
  
/* SET FOR A SUCCEFUL RETURN STATUS. ONLY ALTER THIS VALUE IF A PROBLEM OCCURS */  
SELECT @ret_value = 1  
  

 /*NOTE: 'COPY' - ROW IS POPULUTED WITH 1 TO INDICATE FIRST COPY*/  
INSERT INTO @invtemp_tbl 
SELECT ivh.ivh_invoicenumber,   
       ivh.ivh_hdrnumber,   
       ivh.ivh_billto,   
       @temp_name ivh_billto_name,   
       @temp_addr ivh_billto_addr,   
       @temp_addr2 ivh_billto_addr2,   
       @temp_nmstct ivh_billto_nmctst,   
       ivh.ivh_terms,   
       ivh.ivh_totalcharge,   
       ivh.ivh_shipper,   
       @temp_name shipper_name,   
       @temp_addr shipper_addr,   
       @temp_addr2 shipper_addr2,   
       @temp_nmstct shipper_nmctst,   
       ivh.ivh_consignee,   
       @temp_name consignee_name,   
       @temp_addr consignee_addr,   
       @temp_addr2 consignee_addr2,   
       @temp_nmstct consignee_nmctst,   
       ivh.ivh_originpoint,   
       @temp_name originpoint_name,   
       @temp_addr origin_addr,   
       @temp_addr2 origin_addr2,   
       @temp_nmstct origin_nmctst,   
       ivh.ivh_destpoint,   
       @temp_name destpoint_name,   
       @temp_addr dest_addr,   
       @temp_addr2 dest_addr2,   
       @temp_nmstct dest_nmctst,   
       ivh.ivh_invoicestatus,   
       ivh.ivh_origincity,   
       ivh.ivh_destcity,   
       ivh.ivh_originstate,   
       ivh.ivh_deststate,   
       ivh.ivh_originregion1,   
       ivh.ivh_destregion1,   
       ivh.ivh_supplier,   
       ivh.ivh_shipdate,   
       ivh.ivh_deliverydate,   
       ivh.ivh_revtype1,   
       ivh.ivh_revtype2,   
       ivh.ivh_revtype3,   
       ivh.ivh_revtype4,   
       ivh.ivh_totalweight,   
       ivh.ivh_totalpieces,   
       ivh.ivh_totalmiles,   
       ivh.ivh_currency,   
       ivh.ivh_currencydate,   
       ivh.ivh_totalvolume,   
       ivh.ivh_taxamount1,   
       ivh.ivh_taxamount2,   
       ivh.ivh_taxamount3,   
       ivh.ivh_taxamount4,   
       ivh.ivh_transtype,   
       ivh.ivh_creditmemo,   
       ivh.ivh_applyto,   
       ivh.ivh_printdate,   
       ivh.ivh_billdate,   
       ivh.ivh_lastprintdate,   
       ivh.ivh_originregion2,   
       ivh.ivh_originregion3,   
       ivh.ivh_originregion4,   
       ivh.ivh_destregion2,   
       ivh.ivh_destregion3,   
       ivh.ivh_destregion4,   
       ivh.mfh_hdrnumber,   
       ivh.ivh_remark,   
       ivh.ivh_driver,   
       ivh.ivh_tractor,   
       ivh.ivh_trailer,  
       ivh.ivh_user_id1,   
       ivh.ivh_user_id2,   
       ivh.ivh_ref_number,   
       ivh.ivh_driver2,   
       ivh.mov_number,   
       ivh.ivh_edi_flag,   
       ivh.ord_hdrnumber,   
       ivd.ivd_number,   
       ivd.stp_number,   
       ivd.ivd_description,   
       ivd.cht_itemcode,   
       ivd.ivd_quantity,   
       ivd.ivd_rate,   
       ivd.ivd_charge,   
       ivd.ivd_taxable1,   
       ivd.ivd_taxable2,   
       ivd.ivd_taxable3,   
       ivd.ivd_taxable4,   
       ivd.ivd_unit,   
       ivd.cur_code,   
       ivd.ivd_currencydate,   
       ivd.ivd_glnum,   
       ivd.ivd_type,   
       ivd.ivd_rateunit,   
       ivd.ivd_billto,   
       @temp_name ivd_billto_name,   
       @temp_addr ivd_billto_addr,   
       @temp_addr2 ivd_billto_addr2,   
       @temp_nmstct ivd_billto_nmctst,   
       ivd.ivd_itemquantity,   
       ivd.ivd_subtotalptr,   
       ivd.ivd_allocatedrev,   
       ivd.ivd_sequence,   
       ivd.ivd_refnum,   
       ivd.cmd_code,   
       ivd.cmp_id, 
       @temp_name stop_name,   
       @temp_addr stop_addr,   
       @temp_addr2 stop_addr2,   
       @temp_nmstct stop_nmctst,   
       ivd.ivd_distance,   
       ivd.ivd_distunit,   
       ivd.ivd_wgt,   
       ivd.ivd_wgtunit,   
       ivd.ivd_count,   
       ivd.ivd_countunit,   
       ivd.evt_number,   
       ivd.ivd_reftype,   
       ivd.ivd_volume,   
       ivd.ivd_volunit,  
       ivd.ivd_orig_cmpid,   
       ivd.ivd_payrevenue,   
       ivh.ivh_freight_miles,   
       ivh.tar_tarriffnumber,  
       ivh.tar_tariffitem,   
       1 copies,   
       cht.cht_basis,   
       cht.cht_description,  
       cmd_name = Case ivd_type 
         WHEN 'SUB' then isnull(ord_description,'')  -- gets cmd name for line haul charge in rae by tot
         else cmd.cmd_name
         end ,  
       @temp_altid  cmp_altid,  
       ivh_hideshipperaddr,  
       ivh_hideconsignaddr,  
       ivh_showshipper =
         Case isnull(ivh_showshipper,'UNKNOWN')   
         when 'UNKNOWN' then ivh.ivh_shipper  
         else ivh.ivh_shipper  
         end ,  
       ivh_showcons = 
         Case isnull(ivh_showcons,'UNKNOWN')   
         when 'UNKNOWN' then ivh.ivh_consignee  
         else ivh.ivh_consignee   
        end ,  
       IsNull(ivh_charge,0.0) ivh_charge,  
       Terms_name = replicate(' ',20),
       billto_addr3 = @temp_addr2,
       @varchar50 cmp_contact,
       shipper_geoloc = @varchar50,
       cons_geoloc = @varchar50  ,
       ratefactor = unc_factor,
       cht.cht_primary,
       cht.cht_basisunit,
       ivh_attention,
       0.00,
       0.00
  FROM invoiceheader ivh
       join invoicedetail ivd on  ivh.ivh_hdrnumber = ivd.ivh_hdrnumber
       left outer join orderheader on ivh.ord_hdrnumber = orderheader.ord_hdrnumber
       LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code 
	   left outer join chargetype cht  on ivd.cht_itemcode = cht.cht_itemcode  
       left outer join unitconversion  on unc_from = ivd_unit and unc_to = ivd_rateunit and unc_convflag = 'R'
 WHERE ivh.ivh_hdrnumber = @invoice_nbr   
       and (IsNull(ivd.cht_rollintolh,0) = 0) 
 order by ivd_sequence  
		  

   
/* IF NO RECORDS FOUND TERMINATE STORED PROCEDURE */  
IF (SELECT COUNT(*) FROM @invtemp_tbl) = 0  
BEGIN  
     SELECT @ret_value = 0   
     GOTO ERROR_END   
END  
/* get sum of charge to be rolled into line haul */
  SELECT @rollupcharges = SUM(ivd.ivd_charge) 
    FROM invoicedetail ivd
   WHERE  ivd.ivh_hdrnumber = @invoice_nbr AND
          (IsNull(ivd.cht_rollintolh,0) = 1)       
select @rollupcharges = isnull(@rollupcharges,0)
 
/* adjust the line haul charge to include to rolleed up charges, copute an effective rate */
IF (@rollupcharges <> 0 )  
UPDATE @invtemp_tbl   
   SET ivd_rate = case ivd_quantity
       when 0 then ivd_rate
       else round((ivd_charge + @rollupcharges ) / (ratefactor * ivd_quantity) ,4)
       end,
       ivd_charge = ivd_charge + @rollupcharges   
 WHERE  cht_primary = 'Y' and ivd_charge <> 0 

         
 If Not Exists (Select cmp_mailto_name From company c, @invtemp_tbl t  
        Where c.cmp_id = t.ivh_billto  
   And Rtrim(IsNull(cmp_mailto_name,'')) > ''  
   And t.ivh_terms in (c.cmp_mailto_crterm1, c.cmp_mailto_crterm2, c.cmp_mailto_crterm3,   
   Case IsNull(cmp_mailtoTermsMatchFlag,'N') When 'Y' Then '^^' ELse t.ivh_terms End)  
   And t.ivh_charge <> Case IsNull(cmp_MailtToForLinehaulFlag,'Y') When 'Y' Then 0.00 Else ivh_charge + 1.00 End )   
  
    update @invtemp_tbl  
    set ivh_billto_name = company.cmp_name,  
    ivh_billto_addr = isnull(company.cmp_address1,''),  
    ivh_billto_addr2 = isnull(company.cmp_address2,''),  
    billto_addr3 = isnull(company.cmp_address3,''),  
    ivh_billto_nmctst = substring(cty_nmstct,1, (charindex('/', company.cty_nmstct+'/')))+ ' ' + IsNull(company.cmp_zip,''),  
    cmp_altid = company.cmp_altid ,  
    cmp_contact = company.cmp_contact  
    from @invtemp_tbl temtbl
    join  company  on temtbl.ivh_billto = company.cmp_id 
 
Else   
   update @invtemp_tbl  
   set ivh_billto_name = upper(company.cmp_mailto_name),  
   ivh_billto_addr = isnull(company.cmp_mailto_address1,''),  
   ivh_billto_addr2 = isnull(company.cmp_mailto_address2,''),    
   ivh_billto_nmctst = substring(company.mailto_cty_nmstct,1, (charindex('/', company.mailto_cty_nmstct+'/')))+ ' ' + IsNull(company.cmp_mailto_zip, ''), 
   cmp_altid = company.cmp_altid ,  
   cmp_contact = company.cmp_contact   
   from @invtemp_tbl temtbl, company  
   where company.cmp_id = temtbl.ivh_billto  
 

UPDATE @invtemp_tbl   
   SET originpoint_name = cmp.cmp_name,   
       origin_addr = isnull(cmp.cmp_address1, ''),  
       origin_addr2 = isnull(cmp.cmp_address2, ''),  
       origin_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct+'/'))) + ' ' + ISNULL(city.cty_zip,'')  
  FROM @invtemp_tbl temtbl
  join company cmp on temtbl.ivh_originpoint = cmp.cmp_id
  join city on  temtbl.ivh_origincity =  city.cty_code 

  
UPDATE @invtemp_tbl   
   SET destpoint_name = cmp.cmp_name,   
       dest_addr = isnull(cmp.cmp_address1, ''),  
       dest_addr2 = isnull(cmp.cmp_address2, '') , 
       dest_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct+'/'))) + ' ' + ISNULL(city.cty_zip,'')   
  FROM @invtemp_tbl temtbl
  join company cmp on temtbl.ivh_destpoint = cmp.cmp_id
  join city on  temtbl.ivh_destcity =  city.cty_code 

   
  
UPDATE @invtemp_tbl   
   SET shipper_name = cmp.cmp_name,   
       shipper_addr = 
         Case ivh_hideshipperaddr 
         when 'Y'   then ''  
         else isnull(cmp.cmp_address1,'')  
         end,  
       shipper_addr2 = 
         Case ivh_hideshipperaddr 
         when 'Y'   then ''  
         else isnull(cmp.cmp_address2,'')  
         end,  
       shipper_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct+'/'))) + ' ' + IsNull(cmp.cmp_zip ,''),
	   shipper_geoloc = IsnUll(cmp_geoloc,'')  
  FROM @invtemp_tbl temtbl
  JOIN company cmp on    temtbl.ivh_showshipper   = cmp.cmp_id

  
UPDATE @invtemp_tbl   
SET shipper_nmctst = origin_nmctst  
WHERE ivh_shipper  = 'UNKNOWN'

UPDATE @invtemp_tbl   
SET consignee_nmctst = dest_nmctst  
WHERE ivh_consignee   = 'UNKNOWN'    
  
  UPDATE @invtemp_tbl   
   SET consignee_name = cmp.cmp_name,   
       consignee_addr = 
          Case ivh_hideconsignaddr 
          when 'Y'  then ''  
          else isnull(cmp.cmp_address1 ,'') 
          end,      
        consignee_addr2 = 
          Case ivh_hideconsignaddr 
          when 'Y' then ''  
          else isnull(cmp.cmp_address2,'')  
          end,   
       consignee_nmctst = substring(cmp.cty_nmstct,1, (charindex('/', cmp.cty_nmstct+'/'))) + ' ' + IsNull(cmp.cmp_zip,'') ,
	   cons_geoloc = IsNull(cmp_geoloc,'')  
  FROM @invtemp_tbl temtbl
  JOIN company cmp  on  temtbl.ivh_showcons  = cmp.cmp_id

  
update @invtemp_tbl  
set terms_name = la.name  
from @invtemp_tbl  temtbl
join labelfile la on temtbl.ivh_terms = la.abbr 
where la.labeldefinition = 'creditterms' 

  
UPDATE @invtemp_tbl   
   SET stop_name = cmp.cmp_name,   
       stop_addr = isnull(cmp.cmp_address1, ''),  
       stop_addr2 = isnull(cmp.cmp_address2,'')   
  FROM @invtemp_tbl temtbl
  JOIN  company cmp   on temtbl.cmp_id  = cmp.cmp_id 
 --## WHERE isnull(temtbl.cmp_id,'UNKNOWN') <> 'UNKNOWN'


  update @invtemp_tbl  
  set  stop_nmctst = substring(city.cty_nmstct,1, (charindex('/', city.cty_nmstct+'/') -1)) 
  from  @invtemp_tbl  temtbl
   join stops on temtbl.stp_number = stops.stp_number
   join  city  on stops.stp_city = cty_code
  where  temtbl.stp_number > 0
 
  
SELECT @counter = 1  
  
WHILE @counter <> @copies  
   BEGIN  
      SELECT @counter = @counter + 1  
      INSERT INTO @invtemp_tbl   
      SELECT ivh_invoicenumber,   
      ivh_hdrnumber,   
      ivh_billto,   
      ivh_billto_name,   
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
      cmp_altid,  
      ivh_hideshipperaddr,  
      ivh_hideconsignaddr,  
      ivh_showshipper,  
      ivh_showcons,  
      ivh_charge,  
     Terms_name ,
      billto_addr3,
     cmp_contact,
     shipper_geoloc ,
 	 cons_geoloc ,
     ratefactor ,
     cht_primary,
     cht_basisunit,
     ivh_attention,
     c_total_paid,
     c_balance_due
     FROM @invtemp_tbl   
     WHERE copies = 1   
  END  
ERROR_END:  
  
/* FINAL SELECT - FORMS RETURN SET */  
SELECT   ivh_invoicenumber,   
      ivh_hdrnumber,   
      ivh_billto,   
      ivh_billto_name,   
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
      cht_basis,   
      cht_description,   
      cmd_name,  
      cmp_altid,  
 --     ivh_hideshipperaddr,  
 --     ivh_hideconsignaddr,  
      ivh_showshipper,  
      ivh_showcons,  
      ivh_charge,  
     Terms_name ,
      billto_addr3,
     cmp_contact
--   ,shipper_geoloc ,
--	 ,cons_geoloc 
--   ,ratefactor
--     ,cht_primary
     ,cht_basisunit
     ,ivh_attention
     ,c_total_paid
     ,c_balance_due
     FROM @invtemp_tbl   
  
/* SET RET VALUE TO @@ERROR IF ONE HAS OCCURED. */  
IF @@ERROR != 0  
SELECT @ret_value = @@ERROR   
  
RETURN @ret_value  
  

GO
GRANT EXECUTE ON  [dbo].[invoice_template157] TO [public]
GO
