SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

  CREATE PROC [dbo].[d_masterbill26b_sp]  
  (@reprintflag   varchar(10)  
  ,@mbnumber    int  
  ,@billto    varchar(8)  
  ,@revtype1    varchar(6)  
  ,@mbstatus    varchar(6)  
  ,@shipstart   datetime  
  ,@shipend    datetime  
  ,@billdate    datetime  
  ,@shipper    varchar(8)  
  ,@consignee   varchar(8)  
  ,@copy     int  
  ,@ivh_invoicenumber varchar(12)  
  ,@orderedby   varchar(8)  
  ,@deldatestart  datetime  
  ,@deldateend  datetime  
  ,@revtype2   varchar(6)  
  ,@revtype3   varchar(6)  
  ,@revtype4   varchar(6)  
  ,@paperworkstatus varchar(6))  
AS  
  
/* 07/25/2002 Vern Jewett (label=vmj1) PTS 14924: lengthen ivd_description from 30 to  
           60 chars.  
 08/13/2002 Vern Jewett (label=vmj2) PTS 15202: fix bug where MB Format26 A & B portions are   
           retrieving different result sets.  Added parms   
           @orderedby, @deldatestart, @deldateend, @revtype2,   
           @revtype3, @revtype4, and @paperworkstatus. 
 7/20/07 DPETE 38512 misc invoice ref numbers were getting mutiple records 
       Note (customer has modified proc on site in a different way (removed join to ref number)
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 * BDH 4/16/08 pts 42414.  Added revtypes 2-4 to where clause when not a reprint. 
*/  
  
DECLARE @int0  int,  
 @ord_hdrnumber int,  
 @last_ord int,  
 @stp_city varchar(40),  
 @last_city varchar(40),  
 @city_name varchar(40),  
 @ord_route varchar(254),  
 @stp_cmp   varchar(20),  
 @last_cmp  varchar(20)  
SELECT @int0 = 0  
select @ord_route = ''  
  
--SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'  
--SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'  
  
  
CREATE TABLE #masterbill_temp (  ord_number varchar(12),  
  ivh_invoicenumber varchar(12),    
  ivh_hdrnumber int NULL,   
  ivh_billto varchar(8) NULL,  
  ivh_shipper varchar(8) NULL,  
  ivh_consignee varchar(8) NULL,  
  ivh_totalcharge money NULL,     
  ivh_originpoint  varchar(8) NULL,    
  ivh_destpoint varchar(8) NULL,     
  ivh_origincity int NULL,     
  ivh_destcity int NULL,     
  ivh_shipdate datetime NULL,     
  ivh_deliverydate datetime NULL,     
  ivh_revtype1 varchar(6) NULL,  
  ivh_mbnumber int NULL,  
  ivh_billto_name varchar(30)  NULL,  
  ivh_billto_address varchar(40) NULL,  
  ivh_billto_address2 varchar(40) NULL,  
  ivh_billto_nmstct varchar(25) NULL ,  
  ivh_billto_zip varchar(9) NULL,  
  ivh_ref_number varchar(30) NULL,  
  ivh_tractor varchar(8) NULL,  
  ivh_trailer varchar(13) NULL,  
  origin_nmstct varchar(25) NULL,  
  origin_state varchar(2) NULL,  
  dest_nmstct varchar(25) NULL,  
  dest_state varchar(2) NULL,  
  billdate datetime NULL,  
  cmp_mailto_name varchar(30)  NULL,  
  bill_quantity float  NULL,  
  ivd_refnumber varchar(30) NULL,  
  ivd_weight float NULL,  
  ivd_weightunit char(6) NULL,  
  ivd_count float NULL,  
  ivd_countunit char(6) NULL,  
  ivd_volume float NULL,  
  ivd_volunit char(6) NULL,  
  ivd_unit char(6) NULL,  
  ivd_rate money NULL,  
  ivd_rateunit char(6) NULL,  
  ivd_charge money NULL,  
  cht_description varchar(30) NULL,  
  cht_primary char(1) NULL,  
  cmd_name varchar(60)  NULL,  
  --vmj1+  
  ivd_description varchar(60) NULL,  
--  ivd_description varchar(30) NULL,  
  --vmj1-  
  ivd_type char(6) NULL,  
  stp_city int NULL,  
  stp_cty_nmstct varchar(25) NULL,  
  ivd_sequence int NULL,  
  stp_number int NULL,  
  copy int NULL,  
  ref_number varchar(30) NULL,  
  cmp_id varchar(8) NULL,  
  cmp_name varchar(30) NULL,  
  ivh_remark varchar(254) NULL,  
  order_route varchar(254) null,  
  ord_hdrnumber int null,
  tar_number int null,
  cht_itemcode char(6) NULL)  
-- PTS 17132 -- BL  
--  tar_description varchar (50) NULL)  
  
  
  
-- if printflag is set to REPRINT, retrieve an already printed mb by #  
if UPPER(@reprintflag) = 'REPRINT'   
  BEGIN  
    INSERT INTO #masterbill_temp  
    SELECT  IsNull(invoiceheader.ord_number, ''),  
  invoiceheader.ivh_invoicenumber,    
  invoiceheader.ivh_hdrnumber,   
  invoiceheader.ivh_billto,  
  invoiceheader.ivh_shipper,  
  invoiceheader.ivh_consignee,     
  invoiceheader.ivh_totalcharge,     
  invoiceheader.ivh_originpoint,    
  invoiceheader.ivh_destpoint,     
  invoiceheader.ivh_origincity,     
  invoiceheader.ivh_destcity,     
  invoiceheader.ivh_shipdate,     
  invoiceheader.ivh_deliverydate,     
  invoiceheader.ivh_revtype1,  
  invoiceheader.ivh_mbnumber,  
  ivh_billto_name = cmp1.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
  ivh_billto_address =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
     END,  
  ivh_billto_address2 =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
     END,  
  ivh_billto_nmstct =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')  
     END,  
 ivh_billto_zip =   
     CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
     END,  
  invoiceheader.ivh_ref_number,  
  invoiceheader.ivh_tractor,  
  invoiceheader.ivh_trailer,  
  cty1.cty_nmstct   origin_nmstct,  
  cty1.cty_state  origin_state,  
  cty2.cty_nmstct   dest_nmstct,  
  cty2.cty_state  dest_state,  
  ivh_billdate      billdate,  
  ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,  
  ivd.ivd_quantity 'bill_quantity',  
  IsNull(ivd.ivd_refnum, ''),  
  IsNull(ivd.ivd_wgt, 0),  
  IsNull(ivd.ivd_wgtunit, ''),  
  IsNull(ivd.ivd_count, 0),  
  IsNull(ivd.ivd_countunit, ''),  
  IsNull(ivd.ivd_volume, 0),  
  IsNull(ivd.ivd_volunit, ''),  
  IsNull(ivd.ivd_unit, ''),  
  IsNull(ivd.ivd_rate, 0),  
  IsNull(ivd.ivd_rateunit, ''),  
  ivd.ivd_charge,  
  cht.cht_description,  
  cht.cht_primary,  
  cmd.cmd_name,  
  IsNull(ivd.ivd_description, ''),  
  ivd.ivd_type,  
  stp.stp_city,  
  '',  
  ivd_sequence,  
  IsNull(stp.stp_number, -1),  
  @copy,  
  case invoiceheader.ord_hdrnumber 
    when 0  then
    isnull((select top 1 ref_number 
        from referencenumber invref
        where invref.ref_table = 'invoiceheader'
        and ref_type in ('BOL','BL#')
        and ref_tablekey = invoiceheader.ivh_hdrnumber
        order by ref_sequence),'')
    else 
    isnull((select top 1 ref_number 
        from referencenumber ordref
        where ordref.ref_table = 'orderheader'
        and ref_type in ('BOL','BL#')
        and ref_tablekey = invoiceheader.ord_hdrnumber
        order by ref_sequence),'')

     end, --#ref.ref_number,  
  ivd.cmp_id cmp_id,  
  cmp2.cmp_name,  
  invoiceheader.ivh_remark,  
  '',  
  invoiceheader.ord_hdrnumber,
	ivd.tar_number tar_number,
  ivd.cht_itemcode  cht_itemcode
-- PTS 17132 -- BL  
--  tar.tar_description   
    FROM  invoiceheader,   
  company cmp1,  
  company cmp2,   
  city cty1,   
  city cty2,   
  invoicedetail ivd left outer join stops stp on ivd.stp_number = stp.stp_number left outer join commodity cmd on ivd.cmd_code = cmd.cmd_code,   
  chargetype cht  
--# referencenumber ref  
-- PTS 17294 -- BL  
-- (comment out 'PTS 17132' lines)  
-- PTS 17132 -- BL  
--  tariffheader tar  
   WHERE ( invoiceheader.ivh_mbnumber = @mbnumber )  
  AND (invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber)  
  AND (cmp1.cmp_id = invoiceheader.ivh_billto)   
  AND (cty1.cty_code = invoiceheader.ivh_origincity)   
  AND (cty2.cty_code = invoiceheader.ivh_destcity)  
  AND (ivd.cht_itemcode = cht.cht_itemcode)  
  AND (@shipper IN(invoiceheader.ivh_shipper,'UNKNOWN'))  
  AND (@consignee IN (invoiceheader.ivh_consignee,'UNKNOWN'))  
  AND ivd.cmp_id = cmp2.cmp_id   
/*# 
  AND invoiceheader.ord_hdrnumber *= ref.ref_tablekey 
 
-- PTS 17748 -- BL
--  AND ref.ref_table = 'orderheader'   
  AND ref.ref_table IN ('orderheader', 'invoiceheader')
  AND ref.ref_type in ('BOL','BL#')  
-- PTS 17294 -- BL  
-- (comment out 'PTS 17132' and 'PTS 17285' lines)  
-- PTS 17132 -- BL  
--  AND ivd.tar_number = tar.tar_number   
-- PTS 17285 -- BL  
--    (make the join an OUTER join)  
--  AND ivd.tar_number *= tar.tar_number   
-- PTS 20398 -- BL (start)
		and ref.ref_sequence = 
			(select min(ref_sequence)
			from referencenumber ref2
			where ref2.ref_tablekey = ref.ref_tablekey
			and ref2.ref_table IN ('orderheader','invoiceheader')
			and ref2.ref_type in ('BOL','BL#'))
-- PTS 20398 -- BL (end)
 #*/ 
  END  
  
-- for master bills with 'RTP' status  
  
IF UPPER(@reprintflag) <> 'REPRINT'   
  BEGIN  
     INSERT INTO  #masterbill_temp  
     SELECT IsNull(invoiceheader.ord_number,''),  
            invoiceheader.ivh_invoicenumber,    
            invoiceheader.ivh_hdrnumber,   
            invoiceheader.ivh_billto,     
            invoiceheader.ivh_shipper,  
            invoiceheader.ivh_consignee,  
            invoiceheader.ivh_totalcharge,     
            invoiceheader.ivh_originpoint,    
            invoiceheader.ivh_destpoint,     
            invoiceheader.ivh_origincity,     
            invoiceheader.ivh_destcity,   
            invoiceheader.ivh_shipdate,     
            invoiceheader.ivh_deliverydate,  
            invoiceheader.ivh_revtype1,  
            @mbnumber     ivh_mbnumber,  
            ivh_billto_name = cmp1.cmp_name,  
-- dpete for LOR pts4785 provide for maitlto override of billto  
            ivh_billto_address =   
       CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address1,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address1,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address1,'')  
       END,  
            ivh_billto_address2 =   
       CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN ISNULL(cmp1.cmp_address2,'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_address2,'')  
  ELSE ISNULL(cmp1.cmp_mailto_address2,'')  
       END,  
            ivh_billto_nmstct =   
       CASE  
  WHEN cmp1.cmp_mailto_name IS NULL THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN   
     ISNULL(SUBSTRING(cmp1.cty_nmstct,1,(CHARINDEX('/',cmp1.cty_nmstct))- 1),'')  
  ELSE ISNULL(SUBSTRING(cmp1.mailto_cty_nmstct,1,(CHARINDEX('/',cmp1.mailto_cty_nmstct)) - 1),'')  
       END,  
            ivh_billto_zip =   
       CASE  
  WHEN cmp1.cmp_mailto_name IS NULL  THEN ISNULL(cmp1.cmp_zip ,'')    
  WHEN (cmp1.cmp_mailto_name <= ' ') THEN ISNULL(cmp1.cmp_zip,'')  
  ELSE ISNULL(cmp1.cmp_mailto_zip,'')  
       END,  
     invoiceheader.ivh_ref_number,  
     invoiceheader.ivh_tractor,  
     invoiceheader.ivh_trailer,  
            cty1.cty_nmstct   origin_nmstct,  
            cty1.cty_state  origin_state,  
            cty2.cty_nmstct   dest_nmstct,  
            cty2.cty_state  dest_state,  
            @billdate billdate,  
            ISNULL(cmp1.cmp_mailto_name,'') cmp_mailto_name,  
            ivd.ivd_quantity 'bill_quantity',  
     IsNull(ivd.ivd_refnum, ''),  
            IsNull(ivd.ivd_wgt, 0),  
            IsNull(ivd.ivd_wgtunit, ''),  
            IsNull(ivd.ivd_count, 0),  
            IsNull(ivd.ivd_countunit, ''),  
            IsNull(ivd.ivd_volume, 0),  
            IsNull(ivd.ivd_volunit, ''),  
            IsNull(ivd.ivd_unit, ''),  
            IsNull(ivd.ivd_rate, 0),  
            IsNull(ivd.ivd_rateunit, ''),  
            ivd.ivd_charge,  
            cht.cht_description,  
            cht.cht_primary,  
            cmd.cmd_name,  
            IsNull(ivd.ivd_description, ''),  
            ivd.ivd_type,  
            stp.stp_city,  
            '',  
            ivd_sequence,  
            IsNull(stp.stp_number, -1),  
            @copy,  
    case invoiceheader.ord_hdrnumber 
    when 0  then
    isnull((select top 1 invref.ref_number 
        from referencenumber invref
        where invref.ref_table = 'invoiceheader'
        and invref.ref_type in ('BOL','BL#')
        and invref.ref_tablekey = invoiceheader.ivh_hdrnumber
        order by ref_sequence),'')
    else 
    isnull((select top 1 ordref.ref_number 
        from referencenumber ordref
        where ordref.ref_table = 'orderheader'
        and ordref.ref_type in ('BOL','BL#')
        and ordref.ref_tablekey = invoiceheader.ord_hdrnumber
        order by ref_sequence),'')

     end, --#ref.ref_number,  
            ivd.cmp_id cmp_id,  
     cmp2.cmp_name,  
     invoiceheader.ivh_remark,  
     '',  
     invoiceheader.ord_hdrnumber ,
     ivd.tar_number tar_number,
     ivd.cht_itemcode cht_itemcode  
-- PTS 17132 -- BL  
--     tar.tar_description   
       FROM invoicedetail ivd  LEFT OUTER JOIN  stops stp  ON  ivd.stp_number  = stp.stp_number   
				LEFT OUTER JOIN  commodity cmd  ON  ivd.cmd_code  = cmd.cmd_code   
				LEFT OUTER JOIN  chargetype cht  ON  ivd.cht_itemcode  = cht.cht_itemcode   
				LEFT OUTER JOIN  company cmp2  ON  ivd.cmp_id  = cmp2.cmp_id ,
			city cty1  RIGHT OUTER JOIN  invoiceheader  ON  cty1.cty_code  = invoiceheader.ivh_origincity   
				LEFT OUTER JOIN  city cty2  ON  cty2.cty_code  = invoiceheader.ivh_destcity ,
			company cmp1 
 --#    referencenumber ref  
-- PTS 17132 -- BL  
--     tariffheader tar  
      WHERE invoiceheader.ivh_billto = @billto and  
            invoiceheader.ivh_hdrnumber = ivd.ivh_hdrnumber and  
            invoiceheader.ivh_shipdate between @shipstart AND @shipend and   
            invoiceheader.ivh_mbstatus = 'RTP' and   
            @revtype1 in (invoiceheader.ivh_revtype1,'UNK') and   
 			@revtype2 in (invoiceheader.ivh_revtype2,'UNK') and		-- BDH pts 42414    
			@revtype3 in (invoiceheader.ivh_revtype3,'UNK') and   	-- BDH pts 42414    
			@revtype4 in (invoiceheader.ivh_revtype4,'UNK') and   	-- BDH pts 42414    
            cmp1.cmp_id = invoiceheader.ivh_billto and  
            @shipper in (invoiceheader.ivh_shipper,'UNKNOWN') and  
            @consignee IN (invoiceheader.ivh_consignee,'UNKNOWN') and  
            @ivh_invoicenumber IN (invoiceheader.ivh_invoicenumber, 'Master') 
 /*# and  
     invoiceheader.ord_hdrnumber *= ref.ref_tablekey and  
-- PTS 17748 -- BL
--     ref.ref_table = 'orderheader' and  
     ref.ref_table IN ('orderheader', 'invoiceheader') AND
     ref.ref_type in ('BOL','BL#')  
  
  --vmj2+ This was copied from "A" version of SP..  
  and ivd_charge <> 0  
  and @OrderedBy in ('UNKNOWN', invoiceheader.ivh_order_by)  
  and invoiceheader.ivh_deliverydate between @DelDatestart and @DelDateend  
  and @Revtype2 in ('UNK', invoiceheader.ivh_revtype2)  
  and @Revtype3 in ('UNK', invoiceheader.ivh_revtype3)  
  and @Revtype4 in ('UNK', invoiceheader.ivh_revtype4)  
  and @paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )  
  --vmj2-  
-- PTS 17294 -- BL  
-- (comment out 'PTS 17132' and 'PTS 17285' lines)  
-- PTS 17132 -- BL  
--     AND ivd.tar_number = tar.tar_number   
-- PTS 17285 -- BL  
--    (make the join an OUTER join)  
--     AND ivd.tar_number *= tar.tar_number   
-- PTS 20398 -- BL (start)
		and ref.ref_sequence = 
			(select min(ref_sequence)
			from referencenumber ref2
			where ref2.ref_tablekey = ref.ref_tablekey
			and ref2.ref_table IN ('orderheader','invoiceheader')
			and ref2.ref_type in ('BOL','BL#'))
-- PTS 20398 -- BL (end)
#*/
  END  
  
  create table #order_temp(  
  ord_hdrnumber int)  
  
  insert into #order_temp   
  select distinct ord_hdrnumber  
  from   #masterbill_temp  
  
  Declare  ord_cursor CURSOR for  
 select #order_temp.ord_hdrnumber  
 from   #order_temp  
  open ord_cursor  
  FETCH NEXT From ord_cursor  
        Into @ord_hdrnumber  
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
    Declare  stop_cursor CURSOR for  
    Select isnull(city.cty_nmstct,'')  
      From stops,city  
     Where stops.ord_hdrnumber = @ord_hdrnumber and  
    city.cty_code = stops.stp_city  
    and @ord_hdrnumber <> 0 -- PTS 15034 - DJM      
    Order by stp_sequence  
  
     OPEN       stop_cursor  
     FETCH NEXT From stop_cursor  
           Into @stp_city  
    
  
     WHILE @@FETCH_STATUS = 0  
     BEGIN  
 if  @stp_city is not null and len(@stp_city) > 0 begin  
  if charindex('/',@stp_city,1) > 0 begin  
   select @city_name = left(@stp_city,charindex('/',@stp_city,1)- 1 )  
     
  end else begin  
   select @city_name = @stp_city  
  end  
                if @ord_route = '' begin  
     select @ord_route = 'SHIPPED FROM ' + @city_name + ' TO '  
  end else if right(rtrim(@ord_route),2) = 'TO' begin  
      select @ord_route = @ord_route  + @city_name  
  End else begin   
     select @ord_route = @ord_route + ' / ' + @city_name  
  end  
 end   
    
    
 FETCH NEXT From stop_cursor  
   Into  @stp_city  
    END  
  
    CLOSE stop_cursor  
    DEALLOCATE stop_cursor  
  
      
    UPDATE  #masterbill_temp   
    SET  #masterbill_temp.order_route = @ord_route  
    WHERE        #masterbill_temp.ord_hdrnumber = @ord_hdrnumber  
   
    select @ord_route = ''  
    FETCH NEXT From ord_cursor  
        Into @ord_hdrnumber  
  end  
    
  CLOSE ord_cursor  
  DEALLOCATE ord_cursor  
  /*UPDATE  #masterbill_temp   
  SET  #masterbill_temp.stp_cty_nmstct = city.cty_nmstct  
  FROM  #masterbill_temp, city   
  WHERE  #masterbill_temp.stp_city = city.cty_code */  

--JLB PTS 23462  First Fleet wants charge typee description to print on Minimum lines instead of the ivd_description
--which is the chargetype description of the line the minimum applies to.
/*
--Provide override for pre rated line item charge problem in VisDIsp (does not apply desc)
Update   #masterbill_temp
Set ivd_description = tar.ivd_description
From tariffheader tar
Where #masterbill_temp.ivd_description = 'UNKNOWN'
And IsNull(#masterbill_temp.tar_number,0) > 0
And tar.tar_number = #masterbill_temp.tar_number
And Rtrim(IsNull(tar.ivd_description,'')) > ''
*/
Update   #masterbill_temp
   Set ivd_description = tar.ivd_description
  From tariffheader tar
 Where (#masterbill_temp.ivd_description = 'UNKNOWN' AND
        IsNull(#masterbill_temp.tar_number,0) > 0 AND
        tar.tar_number = #masterbill_temp.tar_number AND
        Rtrim(IsNull(tar.ivd_description,'')) > ''
       )
    OR (#masterbill_temp.cht_itemcode in ('MIN', 'MINACC') AND
        IsNull(#masterbill_temp.tar_number,0) > 0 AND
        tar.tar_number = #masterbill_temp.tar_number AND
        Rtrim(IsNull(tar.ivd_description,'')) > ''
       )
--end 23462

  SELECT *   
  FROM  #masterbill_temp  
  WHERE  ivd_charge <> 0    
   
    
  
  DROP TABLE  #masterbill_temp  
GO
GRANT EXECUTE ON  [dbo].[d_masterbill26b_sp] TO [public]
GO
