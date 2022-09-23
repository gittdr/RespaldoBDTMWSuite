SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_invoices_printqueue3_batch] (@status VARCHAR(6), @billto VARCHAR(8),    
  @shipper varchar(8), @consignee varchar(8), @orderedby varchar(8),    
  @shipdate1 datetime, @shipdate2 datetime, @deldate1 datetime,     
  @deldate2 datetime, @rev1 varchar(6),    
  @rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6),     
  @printdate datetime, @doinvoices char(1),     
  @domasterbills char(1) , @mbnumber int,     
  @batch varchar(254), @batch_count int,     
  @billdate1 datetime, @billdate2 datetime,    
  @mbcompany_include char(1), @user_id char(20), @byuser char(1),@paperworkstatus varchar(6),    
  @xfrdate1 datetime, @xfrdate2 datetime,@imagestatus tinyint, @usr_id char(20), 
	@company varchar(6), @ord_number varchar (12), @sch_date1 datetime, @sch_date2 datetime,@driverid varchar(8))
  --@xfrdate1 datetime, @xfrdate2 datetime,@ivhrefnumber varchar(20),@imagestatus tinyint)    
AS    
    
/**
 * 
 * NAME:
 * dbo.d_invoices_printqueue3_batch_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_invoices_printqueue3_batch
 * Returns information for invoices and masterbills which meet the  
 * selection criterea.  A candidate list for invoice printing 
 *
 * RETURNS:
 * dw result set
 *
 * PARAMETERS:
 * .....
 * 031 - @sch_date1 datetime	sch earliest datetime from
 * 032 - @sch_date1 datetime	sch earliest datetime to
 * 
 * REVISION HISTORY:
 * Modified 8/8/00 pts 7896 populate cmp_transfertype for masterbills  
5/23/01 dpete pts8790 add cmp_invoicetype to return set so output may be bypassed when processing printing and staus updated  
4/4/2 DPETE PTS 13822 add tariff information to return set for master bills 19 & 20  
DPETE PTS15533 add ivh_refnumber to selection and to return set  
DPETE PTS15913 add image status to args and return set  
DPETE 16354 add break on ord_fromorder for mb format 29 (remove ref number)  
DPETE PTS 16739 Add back case statements on master bill retrieves for mb_group (cmd_code not in return set)  
DPETE PTS16739 found subcomapny filed is 6 here and 8 on database
DPETE 4/15/ 16739 fix errors
DPETE 17999 Add REF#1 group to group by first ref on order/invoice
LOR	PTS# 23109	add company

PTS 28682 - DJM - Keith found an easy performance enhancement.  Modified the Where clause to use the CharIndex statment
	to match RevType values.
 * LOR	PTS# 30053	added sch earliest dates
 * DPETE PTS34005 alllow bill date set earlier than today with mbdays = -1
 *  EMK PTS 39333 Put in ivh_showshipper and ivh_showcons fields.  Lost them back in 2005
 * SGB PTS 39913 Correct spelling of ivh_showcons from ivh_showcosignee and ivh_showconsignee
 * DPETE PTS 40753 40260 recode Pauls Hauling ad car_key for alternate address for bill to company
 * DPETE PTS 43745 complete recode of Paul's which copie dosme work done in main source and not put in batch
 * 47582 DPETE support new status Printed or Transferred
 * PTS 48221 SGB Add Driver as a selection criteria and return set column 
 **/

DECLARE @int0  int, @varchar6 varchar(6), @varchar8 varchar (8), @money money,     
 @varchar254 varchar(254), @varchar30 varchar(30), @char3 char(3), @charn char,    
 @chary char, @varchar20 varchar(20), @char1 char(1), @dummystatus varchar(6),    
 @copies smallint 
declare @dummystatus2 varchar(6)   
    
SELECT @int0 = 0, @money = 0.00, @varchar8 = '', @varchar30 = '', @varchar254 = '',    
     @varchar6 = '', @char3 = '', @charn = 'N', @chary = 'Y',@varchar20 = '',    
 @dummystatus = '<',@copies = 0    
    
DECLARE @batch_id_1  varchar(10),    
 @i_batch int,    
 @batch_string varchar(254),    
 @count   int  
DECLARE @cmp_dflt_reftype VARCHAR(8)  --43745
--43745 recode PTS32823
SET @cmp_dflt_reftype = (Select CASE ISNULL(gi_string1, 'REF')
				  WHEN '' THEN 'REF'
				  WHEN ' ' THEN 'REF'
				  WHEN 'REF' THEN 'REF'
				  ELSE gi_string1
				END
		    From generalinfo
		    Where gi_name = 'MasterBill82DefaultRef')
--END 43745 (PTS32823 )      
    
select @batch_string = RTRIM(@batch)    
select @i_batch = 0    
select @count = 1    
select @imagestatus = IsNull(@imagestatus,0)    
create table #batch (batch_id varchar(10) not null)    
insert #batch (batch_id) values('XXX,')    
    
WHILE @count <= @batch_count    
BEGIN    
 select @i_batch = charindex(',', @batch_string)    
 If @i_batch > 0    
 BEGIN    
  SELECT @batch_id_1 = substring(@batch_string, 1, (@i_batch - 1))    
  select @batch_string = substring(@batch_string, (@i_batch + 1), (254 - @i_batch))    
  insert #batch (batch_id) values(@batch_id_1)    
  select @count = @count + 1    
 END    
 If @count > 1 and @i_batch = 0    
 BEGIN    
  insert #batch (batch_id) values(@batch_string)    
  select @count = @count + 1    
 END    
END    
    
-- for reprinting invoices the PRN and PRO status are the same    
-- for reprinting masterbills the status is not used    
IF @status = 'PRN' 
  BEGIN    
    SELECT @dummystatus = 'PRO'
    SELECT @dummystatus2 = 'PRO'  
  END   
IF @status = 'PRO'
  BEGIN     
    SELECT @dummystatus = 'PRN'
    SELECT @dummystatus2 = 'PRN' 
  END 
if @status = 'PRNXFR' 
  BEGIN
    SELECT @status = 'XFR'  -- @status is used with transfer date params
    SELECT @dummystatus = 'PRN'
    SELECT @dummystatus2 = 'PRO'  
  END   

     
CREATE TABLE #invview (     
 mov_number int NULL,    
 ivh_invoicenumber varchar(12) NULL,    
 ivh_invoicestatus varchar(6) NULL,    
 ivh_billto varchar(8) NULL,    
 billto_name varchar(30) NULL,    
 ivh_shipper varchar(8) NULL,    
 shipper_name varchar(30) NULL,    
 ivh_consignee varchar(8) NULL,    
 consignee_name varchar(30) NULL,    
 ivh_shipdate datetime NULL,    
  ivh_deliverydate datetime NULL,    
  ivh_revtype1 varchar(6) NULL,    
  ivh_revtype2 varchar(6) NULL,    
  ivh_revtype3 varchar(6) NULL,    
  ivh_revtype4 varchar(6) NULL,    
  ivh_totalweight float NULL,    
  ivh_totalpieces float NULL,    
  ivh_totalmiles float NULL,    
  ivh_totalvolume float NULL,    
  ivh_printdate datetime NULL,    
  ivh_billdate datetime NULL,    
  ivh_lastprintdate datetime NULL,    
  ord_hdrnumber int NULL,    
  ivh_remark varchar(254) NULL,    
  ivh_edi_flag char(30) NULL,    
  ivh_totalcharge money NULL,    
 RevType1 char(8) NULL,    
  RevType2 char(8) NULL,    
  Revtype3 char(8) NULL,    
  RevType4 char(8) NULL,    
  ivh_hdrnumber int NULL,    
  ivh_order_by varchar(8) NULL,    
  ivh_user_id1 char(20) NULL,    
  ord_number char(12) NULL,    
 ivh_terms char(3) NULL,    
 ivh_trailer varchar(8) NULL,    
 ivh_tractor varchar(8) NULL,    
 commodities int NULL,    
 validcommodities int NULL,    
 accessorials int NULL,    
 validaccessorials int NULL,    
 trltype3 varchar(6) NULL,    
cmp_subcompany varchar(8) NULL,    
 totallinehaul money NULL,    
 negativecharges int NULL,    
 edi_210_flag int NULL,    
 ismasterbill char(1) NULL,    
 trltype3name char(8) NULL,     
 cmp_mastercompany varchar(8) NULL,    
 refnumber varchar(30) NULL,    
 cmp_invoiceto char(3) NULL,    
 cmp_invprintto char(1) NULL,    
 cmp_invformat int NULL,    
 cmp_transfertype varchar(6) NULL,    
 ivh_mbstatus varchar(6) NULL,    
 trp_linehaulmax money NULL,    
 trp_totchargemax money NULL,    
 cmp_invcopies smallint NULL,    
        cmp_mbgroup varchar(6) NULL,    
 ivh_originpoint varchar(8) NULL,    
 batch_id varchar(10) NULL,    
 cmp_invoicetype varchar(6) NULL,    
 tar_tariffitem varchar(12) NULL,    
 tar_tariffnumber varchar(12) NULL,    
 --ivh_ref_number varchar(20) NULL,    
 imagestatus tinyint null,    
 ivh_definition varchar(6) NULL,    
 ivh_applyto varchar(12) NULL,    
 ord_fromorder varchar(12) NULL,    
 cmd_code varchar(8) Null  ,  
 production_year smallint Null,  -- for masterbills 19,20,34,35  
 production_month tinyint Null,   -- for masterbills 19,20,34,35  
 cmp_image_routing1	varchar(254) NULL,
 cmp_image_routing2	varchar(254) NULL,
 cmp_image_routing3	varchar(254) NULL,
ivh_company varchar(6) null,
 ivh_showshipper varchar(8) null, 
 ivh_showcons varchar(8) null,  --PTS39333   PTS 39913 corrected spelling
 car_key int null,  --40753
 inv_accessorials	money	null, 	/* 08/24/2009 MDH PTS 42291: Added */
 inv_fuel			money	null, 	/* 08/24/2009 MDH PTS 42291: Added */
 inv_linehaul		money	null,	/* 08/24/2009 MDH PTS 42291: Added */
 ivh_driver varchar(8) -- PTS 48221 SGB 06/17/2010 
)    
    
IF @doinvoices = 'Y'    
BEGIN    
 IF @mbcompany_include = 'N'    
 begin    
  IF @byuser = 'N'    
  INSERT INTO #invview    
  SELECT invoiceheader.mov_number,    
    invoiceheader.ivh_invoicenumber,    
    invoiceheader.ivh_invoicestatus,    
    invoiceheader.ivh_billto,    
    Substring(bcmp.cmp_name,1,30)  billto_name,    
    invoiceheader.ivh_shipper,    
    Substring(scmp.cmp_name,1,30)  shipper_name,    
    invoiceheader.ivh_consignee,    
    Substring(ccmp.cmp_name,1,30)  consignee_name,    
    invoiceheader.ivh_shipdate,    
    invoiceheader.ivh_deliverydate,    
    invoiceheader.ivh_revtype1,    
    invoiceheader.ivh_revtype2,    
    invoiceheader.ivh_revtype3,    
    invoiceheader.ivh_revtype4,    
    invoiceheader.ivh_totalweight,    
    invoiceheader.ivh_totalpieces,    
    invoiceheader.ivh_totalmiles,    
    invoiceheader.ivh_totalvolume,    
    invoiceheader.ivh_printdate,    
    invoiceheader.ivh_billdate,    
    invoiceheader.ivh_lastprintdate,    
    ord_hdrnumber,    
    ivh_remark,    
    invoiceheader.ivh_edi_flag,    
    invoiceheader.ivh_totalcharge,    
   'RevType1' RevType1,    
    'RevType2' RevType2,    
    'RevType3' Revtype3,    
    'RevType4' RevType4,    
    invoiceheader.ivh_hdrnumber,    
    invoiceheader.ivh_order_by,    
    invoiceheader.ivh_user_id1,    
    invoiceheader.ord_number,    
   invoiceheader.ivh_terms,    
   invoiceheader.ivh_trailer,    
   invoiceheader.ivh_tractor,    
   @int0 'commodities',    
   @int0 'validcommodities',    
   @int0 'accessorials',    
   @int0 'validaccessorials',    
   @varchar6 'trltype3',    
    bcmp.cmp_subcompany,  
   @money 'totallinehaul',    
   @int0 'negativecharges',    
   bcmp.cmp_edi210 'edi_210_flag',    
   @charn 'ismasterbill',    
   'Trltype3' trltype3name,    
   bcmp.cmp_mastercompany,    
   @varchar30 'refnumber',    
   bcmp.cmp_invoiceto,    
   bcmp.cmp_invprintto,    
   bcmp.cmp_invformat,    
   bcmp.cmp_transfertype,    
   invoiceheader.ivh_mbstatus,    
   @money trp_linehaulmax,    
   @money trp_totchargemax,    
   bcmp.cmp_invcopies,    
   bcmp.cmp_mbgroup,    
   invoiceheader.ivh_originpoint,     
   invoiceheader.ivh_batch_id,    
   bcmp.cmp_invoicetype,    
   isnull(invoiceheader.tar_tariffitem,''),    
   IsNull(invoiceheader.tar_tarriffnumber,''),    
   --IsNull(invoiceheader.ivh_ref_number,''),    
   IsNull(invoiceheader.ivh_imagestatus,0),    
   ivh_definition,    
   ivh_applyto,    
   '',    
 '',  
 0,0,
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK'),
   IsNull(ivh_showshipper,'UNKNOWN'),
   IsNull(ivh_showcons,'UNKNOWN'),  --PTS 39333 --PTS39913 corrected spelling
   isnull(invoiceheader.car_key,0),
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
	 ivh_driver -- PTS 48221 SGB 06/17/2010	
  FROM invoiceheader, company bcmp, company scmp, company ccmp, #batch    
  WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus,@dummystatus2) )     
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
-- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND   charindex(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
-- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND   charindex(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
-- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND   charindex(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
-- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND   charindex(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
  AND ( bcmp.cmp_id = invoiceheader.ivh_billto)    
  AND (bcmp.cmp_invoicetype in ('BTH','INV','NONE') )    
  AND ( scmp.cmp_id = invoiceheader.ivh_shipper)    
  AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)    
  AND ( invoiceheader.ivh_batch_id = #batch.batch_id )     
--  AND ( @batch_id_1 in ( 'XXX' , invoiceheader.ivh_batch_id) )     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
 -- And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))
  --DPH PTS 23007
  -- PTS 28804 -- BL (start)
--  AND (@usr_id in ( CASE ivh_user_id2
  AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
  -- PTS 28804 -- BL (end)
    		    WHEN 'NULL' THEN ivh_user_id1
     		     ELSE ivh_user_id2
                    END,
		    'UNK'))
  --DPH PTS 23007     
	AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0) 
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221     
    
  IF @byuser = 'Y'    
  INSERT INTO #invview    
  SELECT invoiceheader.mov_number,    
    invoiceheader.ivh_invoicenumber,    
    invoiceheader.ivh_invoicestatus,    
    invoiceheader.ivh_billto,    
    Substring(bcmp.cmp_name,1,30)  billto_name,    
    invoiceheader.ivh_shipper,    
    Substring(scmp.cmp_name,1,30)  shipper_name,    
    invoiceheader.ivh_consignee,    
    Substring(ccmp.cmp_name,1,30)  consignee_name,    
    invoiceheader.ivh_shipdate,    
    invoiceheader.ivh_deliverydate,    
    invoiceheader.ivh_revtype1,    
    invoiceheader.ivh_revtype2,    
    invoiceheader.ivh_revtype3,    
    invoiceheader.ivh_revtype4,    
    invoiceheader.ivh_totalweight,    
    invoiceheader.ivh_totalpieces,    
    invoiceheader.ivh_totalmiles,    
    invoiceheader.ivh_totalvolume,    
    invoiceheader.ivh_printdate,    
    invoiceheader.ivh_billdate,    
    invoiceheader.ivh_lastprintdate,    
    ord_hdrnumber,    
    ivh_remark,    
    invoiceheader.ivh_edi_flag,    
    invoiceheader.ivh_totalcharge,    
   'RevType1' RevType1,    
    'RevType2' RevType2,    
    'RevType3' Revtype3,    
    'RevType4' RevType4,    
    invoiceheader.ivh_hdrnumber,    
    invoiceheader.ivh_order_by,    
    invoiceheader.ivh_user_id1,    
    invoiceheader.ord_number,    
   invoiceheader.ivh_terms,    
   invoiceheader.ivh_trailer,    
   invoiceheader.ivh_tractor,    
   @int0 'commodities',    
   @int0 'validcommodities',    
   @int0 'accessorials',    
   @int0 'validaccessorials',    
   @varchar6 'trltype3',    
   bcmp.cmp_subcompany, 
   @money 'totallinehaul',    
   @int0 'negativecharges',    
   bcmp.cmp_edi210 'edi_210_flag',    
   @charn 'ismasterbill',    
   'Trltype3' trltype3name,    
   bcmp.cmp_mastercompany,    
   @varchar30 'refnumber',    
   bcmp.cmp_invoiceto,    
   bcmp.cmp_invprintto,    
   bcmp.cmp_invformat,    
   bcmp.cmp_transfertype,    
   invoiceheader.ivh_mbstatus,    
   @money trp_linehaulmax,    
   @money trp_totchargemax,    
   bcmp.cmp_invcopies,    
   bcmp.cmp_mbgroup,    
   invoiceheader.ivh_originpoint,     
   invoiceheader.ivh_batch_id,    
   bcmp.cmp_invoicetype,    
   isnull(invoiceheader.tar_tariffitem,''),    
   IsNull(invoiceheader.tar_tarriffnumber,''),    
   --IsNull(invoiceheader.ivh_ref_number,''),    
   IsNull(invoiceheader.ivh_imagestatus,0),    
   ivh_definition,    
   ivh_applyto,    
   '',    
   '',  
 0,0,
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK'),
   IsNull(ivh_showshipper,'UNKNOWN'),
   IsNUll(ivh_showcons,'UNKNOWN') ,
    isnull(invoiceheader.car_key,0)   ,
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
	  ivh_driver -- PTS 48221	 SGB 06/17/2010
  FROM invoiceheader, company bcmp, company scmp, company ccmp, #batch    
  WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus,@dummystatus2) )     
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
  AND ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND ( bcmp.cmp_id = invoiceheader.ivh_billto)    
  AND (bcmp.cmp_invoicetype in ('BTH','INV','NONE') )    
  AND ( scmp.cmp_id = invoiceheader.ivh_shipper)    
  AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)    
  AND ( invoiceheader.ivh_batch_id = #batch.batch_id )     
--  AND ( @batch_id_1 in ( 'XXX' , invoiceheader.ivh_batch_id) )     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  and ivh_user_id1 = @user_id    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
  --And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))   
  --DPH PTS 23007
  -- PTS 28804 -- BL (start)
--  AND (@usr_id in ( CASE ivh_user_id2
  AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
  -- PTS 28804 -- BL (end)
    		    WHEN 'NULL' THEN ivh_user_id1
     		     ELSE ivh_user_id2
                    END,
		    'UNK'))
  --DPH PTS 23007    
	AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221      
 end    
    
 IF @mbcompany_include = 'Y'    
 begin    
  IF @byuser = 'N'    
  INSERT INTO #invview    
  SELECT invoiceheader.mov_number,    
    invoiceheader.ivh_invoicenumber,    
    invoiceheader.ivh_invoicestatus,    
    invoiceheader.ivh_billto,    
    Substring(bcmp.cmp_name,1,30)  billto_name,    
    invoiceheader.ivh_shipper,    
    Substring(scmp.cmp_name,1,30)  shipper_name,    
    invoiceheader.ivh_consignee,    
    Substring(ccmp.cmp_name,1,30)  consignee_name,    
    invoiceheader.ivh_shipdate,    
    invoiceheader.ivh_deliverydate,    
    invoiceheader.ivh_revtype1,    
    invoiceheader.ivh_revtype2,    
    invoiceheader.ivh_revtype3,    
    invoiceheader.ivh_revtype4,    
    invoiceheader.ivh_totalweight,    
    invoiceheader.ivh_totalpieces,    
    invoiceheader.ivh_totalmiles,    
    invoiceheader.ivh_totalvolume,    
    invoiceheader.ivh_printdate,    
    invoiceheader.ivh_billdate,    
    invoiceheader.ivh_lastprintdate,    
    ord_hdrnumber,    
    ivh_remark,    
    invoiceheader.ivh_edi_flag,    
    invoiceheader.ivh_totalcharge,    
   'RevType1' RevType1,    
    'RevType2' RevType2,    
    'RevType3' Revtype3,    
    'RevType4' RevType4,    
    invoiceheader.ivh_hdrnumber,    
    invoiceheader.ivh_order_by,    
    invoiceheader.ivh_user_id1,    
    invoiceheader.ord_number,    
   invoiceheader.ivh_terms,    
   invoiceheader.ivh_trailer,    
   invoiceheader.ivh_tractor,    
   @int0 'commodities',    
   @int0 'validcommodities',    
   @int0 'accessorials',    
   @int0 'validaccessorials',    
   @varchar6 'trltype3',    
    bcmp.cmp_subcompany, 
   @money 'totallinehaul',    
   @int0 'negativecharges',    
   bcmp.cmp_edi210 'edi_210_flag',    
   @charn 'ismasterbill',    
   'Trltype3' trltype3name,    
   bcmp.cmp_mastercompany,    
   @varchar30 'refnumber',    
   bcmp.cmp_invoiceto,    
   bcmp.cmp_invprintto,    
   bcmp.cmp_invformat,    
   bcmp.cmp_transfertype,    
   invoiceheader.ivh_mbstatus,    
   @money trp_linehaulmax,    
   @money trp_totchargemax,    
   bcmp.cmp_invcopies,    
   bcmp.cmp_mbgroup,    
   invoiceheader.ivh_originpoint,     
   invoiceheader.ivh_batch_id,    
   bcmp.cmp_invoicetype,    
   isnull(invoiceheader.tar_tariffitem,''),    
   IsNull(invoiceheader.tar_tarriffnumber,''),    
  -- IsNull(invoiceheader.ivh_ref_number,''),    
   IsNull(invoiceheader.ivh_imagestatus,0),    
   ivh_definition,    
   ivh_applyto,    
   '',    
   '',  
 0,0,
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK'),
   IsNull(ivh_showshipper,'UNKNOWN'),
   IsNull(ivh_showcons,'UNKNOWN'),
    isnull(invoiceheader.car_key,0)     ,
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)	,	/* 08/24/2009 MDH PTS 42291: Added */
		ivh_driver -- PTS 48221 SGB 06/17/2010
  FROM invoiceheader, company bcmp, company scmp, company ccmp, #batch    
  WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus,@dummystatus2) )     
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
-- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND   charindex(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
-- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND   charindex(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
-- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND   charindex(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
-- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND   charindex(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
  AND ( bcmp.cmp_id = invoiceheader.ivh_billto)    
  AND ( scmp.cmp_id = invoiceheader.ivh_shipper)    
  AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)    
  AND ( invoiceheader.ivh_batch_id = #batch.batch_id )     
--  AND ( @batch_id_1 in ( 'XXX' , invoiceheader.ivh_batch_id) )     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
  --And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0)) 
  --DPH PTS 23007
  -- PTS 28804 -- BL (start)
--  AND (@usr_id in ( CASE ivh_user_id2
  AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
  -- PTS 28804 -- BL (end)
    		    WHEN 'NULL' THEN ivh_user_id1
     		     ELSE ivh_user_id2
                    END,
		    'UNK'))
  --DPH PTS 23007     
	AND @company in ('UNK', invoiceheader.ivh_company)  and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0) 
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221     
    
  IF @byuser = 'Y'    
  INSERT INTO #invview    
  SELECT invoiceheader.mov_number,    
    invoiceheader.ivh_invoicenumber,    
    invoiceheader.ivh_invoicestatus,    
    invoiceheader.ivh_billto,    
    Substring(bcmp.cmp_name,1,30)  billto_name,    
    invoiceheader.ivh_shipper,    
    Substring(scmp.cmp_name,1,30)  shipper_name,    
    invoiceheader.ivh_consignee,    
    Substring(ccmp.cmp_name,1,30)  consignee_name,    
    invoiceheader.ivh_shipdate,    
    invoiceheader.ivh_deliverydate,    
    invoiceheader.ivh_revtype1,    
    invoiceheader.ivh_revtype2,    
    invoiceheader.ivh_revtype3,    
    invoiceheader.ivh_revtype4,    
    invoiceheader.ivh_totalweight,    
    invoiceheader.ivh_totalpieces,    
    invoiceheader.ivh_totalmiles,    
    invoiceheader.ivh_totalvolume,    
    invoiceheader.ivh_printdate,    
    invoiceheader.ivh_billdate,    
    invoiceheader.ivh_lastprintdate,    
    ord_hdrnumber,    
    ivh_remark,    
    invoiceheader.ivh_edi_flag,    
    invoiceheader.ivh_totalcharge,    
   'RevType1' RevType1,    
    'RevType2' RevType2,    
    'RevType3' Revtype3,    
    'RevType4' RevType4,    
    invoiceheader.ivh_hdrnumber,    
    invoiceheader.ivh_order_by,    
    invoiceheader.ivh_user_id1,    
    invoiceheader.ord_number,    
   invoiceheader.ivh_terms,    
   invoiceheader.ivh_trailer,    
   invoiceheader.ivh_tractor,    
   @int0 'commodities',    
   @int0 'validcommodities',    
   @int0 'accessorials',    
   @int0 'validaccessorials',    
   @varchar6 'trltype3',    
    bcmp.cmp_subcompany,  
   @money 'totallinehaul',    
   @int0 'negativecharges',    
   bcmp.cmp_edi210 'edi_210_flag',    
   @charn 'ismasterbill',    
   'Trltype3' trltype3name,    
   bcmp.cmp_mastercompany,    
   @varchar30 'refnumber',    
   bcmp.cmp_invoiceto,    
   bcmp.cmp_invprintto,    
   bcmp.cmp_invformat,    
   bcmp.cmp_transfertype,    
   invoiceheader.ivh_mbstatus,    
   @money trp_linehaulmax,    
   @money trp_totchargemax,    
   bcmp.cmp_invcopies,    
   bcmp.cmp_mbgroup,    
   invoiceheader.ivh_originpoint,     
   invoiceheader.ivh_batch_id,    
   bcmp.cmp_invoicetype,    
   isnull(invoiceheader.tar_tariffitem,''),    
   IsNull(invoiceheader.tar_tarriffnumber,''),    
   --IsNull(invoiceheader.ivh_ref_number,''),    
   IsNull(invoiceheader.ivh_imagestatus,0),    
   ivh_definition,    
   ivh_applyto,    
   '',    
   '',  
 0,0,
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK'),
   IsNull(ivh_showshipper,'UNKNOWN'),
   IsNull(ivh_showcons,'UNKNOWN'),
    isnull(invoiceheader.car_key,0)     ,
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
	  ivh_driver -- PTS 48221 SGB 06/17/2010	
  FROM invoiceheader, company bcmp, company scmp, company ccmp, #batch    
  WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus,@dummystatus2) )     
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
-- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND   charindex(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
-- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND   charindex(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
-- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND   charindex(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
-- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND   charindex(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
  AND ( bcmp.cmp_id = invoiceheader.ivh_billto)    
  AND ( scmp.cmp_id = invoiceheader.ivh_shipper)    
  AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)    
  AND ( invoiceheader.ivh_batch_id = #batch.batch_id )     
--  AND ( @batch_id_1 in ( 'XXX' , invoiceheader.ivh_batch_id) )     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  and ivh_user_id1 = @user_id    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
  --And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))    --DPH PTS 23007
  -- PTS 28804 -- BL (start)
--  AND (@usr_id in ( CASE ivh_user_id2
  AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
  -- PTS 28804 -- BL (end)
    		    WHEN 'NULL' THEN ivh_user_id1
     		     ELSE ivh_user_id2
                    END,
		    'UNK'))
  --DPH PTS 23007     
	AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)   
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221   
 end    
    
 -- LOR PTS# 15300 do updates for Floridarock only    
 if (select Upper(gi_string1) from generalinfo where gi_name = 'SystemOwner') = 'FLORIDAROCK'    
 begin    
 -- Note trltype3 column is used for Florida Rock in d_invoices_view2    
 -- Provide a total linehaul charge for each invoice    
 UPDATE #invview    
 SET totallinehaul = (SELECT SUM(d.ivd_charge)    
    FROM  invoicedetail d, chargetype c    
    WHERE #invview.ivh_hdrnumber = d.ivh_hdrnumber    
     AND d.cht_itemcode = c.cht_itemcode    
     AND c.cht_primary = 'Y')    
 --dpete 4/29/99  ignore 'ORDFLT' when validating commodities    
 -- Count the  distinct commodities on the invoice    
 UPDATE  #invview     
 SET commodities =   (SELECT COUNT(DISTINCT(d.cmd_code))    
    FROM invoicedetail d, CHARGETYPE C    
    WHERE #invview.ivh_hdrnumber = d.ivh_hdrnumber    
     AND  d.cht_itemcode NOT IN ( 'MIN','ORDFLT')    
     AND d.ivd_type <> 'SUB'    
     AND d.cht_itemcode = c.cht_itemcode    
     AND   c.cht_primary = 'Y')    
       
 -- Count the commodities which match to the edicommodity table    
 UPDATE  #invview    
 SET validcommodities =  (SELECT COUNT(DISTINCT(d.cmd_code))    
    FROM invoicedetail d,  edicommodity e,chargetype c    
    WHERE #invview.ivh_hdrnumber = d.ivh_hdrnumber    
     AND  d.cht_itemcode NOT IN ( 'MIN','ORDFLT')    
     AND d.ivd_type <> 'SUB'    
     AND d.cht_itemcode = c.cht_itemcode    
     AND   c.cht_primary = 'Y'    
     AND e.cmp_id = #invview.ivh_billto    
     AND e.cmd_code = d.cmd_code)    

 -- Count the accessorial charge types on the invoice     
 UPDATE  #invview    
 SET accessorials = (SELECT COUNT(DISTINCT(d.cht_itemcode))    
    FROM invoicedetail d, chargetype c    
    WHERE d.ivh_hdrnumber = #invview.ivh_hdrnumber    
     AND d.cht_itemcode = c.cht_itemcode    
     AND c.cht_primary <> 'Y' )    
       
 -- Count the accessorial charge types on the invoice which      
 -- match the edicommodity table    
 UPDATE #invview    
 SET validaccessorials = (SELECT COUNT(DISTINCT(d.cht_itemcode))    
    FROM invoicedetail d, chargetype c, ediaccessorial e    
    WHERE d.ivh_hdrnumber = #invview.ivh_hdrnumber    
     AND d.cht_itemcode = c.cht_itemcode    
     AND c.cht_primary <> 'Y'    
     AND e.cmp_id = #invview.ivh_billto    
     AND e.cht_itemcode = d.cht_itemcode )    
     
 -- Count the number of charge lines which have either a negative qty or rate    
 Update #invview    
 SET negativecharges = (SELECT count(*)    
   FROM   invoicedetail d    
   WHERE  d.ivh_hdrnumber = #invview.ivh_hdrnumber    
    AND    (d.ivd_quantity < 0 OR d.ivd_rate < 0.0)     
    AND    d.ivd_charge <> 0.0  )     
    
 -- determine info for doing a max charge screen on edi transmission    
 UPDATE  #invview    
 SET #invview.trp_linehaulmax = t.trp_linehaulmax,    
  #invview.trp_totchargemax = t.trp_totchargemax    
 FROM edi_trading_partner t    
 WHERE t.cmp_id = #invview.ivh_billto    
 end    
 -- the reference number is not used on the 'standard' sp    
END    
    
-- for RTP masterbills (the invoice selection only allows masterbills    
-- requested for RTP status or status = "PRN' with a masterbill#    
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0    
BEGIN    
    IF @status = 'RTP'    
 IF @byuser = 'N'    
 INSERT INTO #invview     
 SELECT 0 mov_number,    
   ivh_invoicenumber = CASE max(company.cmp_mbgroup)    
          WHEN 'INV' THEN    
             min(invoiceheader.ivh_invoicenumber)    
          ELSE    
      'Master'    
       END,    
   min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
   min(invoiceheader.ivh_billto) ivh_billto,    
   @varchar30 billto_name,    
   ivh_shipper = CASE max(company.cmp_mbgroup)    
       WHEN 'SHPCON' THEN    
             min(invoiceheader.ivh_shipper)    
    WHEN 'ORGCMD' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'DRPUPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'DRPUCMDPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'PUPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'PUCMDPO' THEN    
       min(invoiceheader.ivh_shipper)    
     When 'CMDPO' Then 'ALL'    
          When 'DRCMDPO' Then 'ALL'    
          When 'DRPO' Then 'ALL'    
          When 'PO' Then 'ALL'    
       ELSE    
                     @shipper    
               END,    
   @varchar30 shipper_name,    
   ivh_consignee = CASE max(company.cmp_mbgroup)    
          WHEN 'SHPCON' THEN    
               min(invoiceheader.ivh_consignee)    
      WHEN 'ORGCMD' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPUPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPUCMDPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRCMDPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPO' THEN    
         min(invoiceheader.ivh_consignee)    
    When 'CMDPO' Then 'ALL'    
      WHEN 'PO' Then 'ALL'    
      When 'PUCMDPO' Then 'ALL'    
            When 'PUPO' Then 'ALL'    
         ELSE    
               @consignee    
   END,    
   @varchar30 consignee_name,    
   min(invoiceheader.ivh_shipdate) ivh_shipdate,    
   max(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
   ivh_revtype1 = CASE max(company.cmp_mbgroup)    
     WHEN 'REV1' THEN    
        min(invoiceheader.ivh_revtype1)    
     When 'CMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPUCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPUPO' Then min(invoiceheader.ivh_revtype1)    
     When 'PO' Then min(invoiceheader.ivh_revtype1)    
     When 'PUCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'PUPO' Then min(invoiceheader.ivh_revtype1)    
     WHEN 'ALL' THEN    
        'ALL'    
     ELSE    
        @rev1    
         END,     
  @rev2 ivh_revtype2,    
   @rev3 ivh_revtype3,      
  @rev4 ivh_revtype4,    
   sum(invoiceheader.ivh_totalweight) ivh_totalweight,    
   sum(invoiceheader.ivh_totalpieces) ivh_totalpieces,    
   sum(invoiceheader.ivh_totalmiles) ivh_totalmiles,    
   sum(invoiceheader.ivh_totalvolume) ivh_totalvolume,    
   max(invoiceheader.ivh_printdate) ivh_printdate,      
   min(invoiceheader.ivh_billdate) ivh_billdate,    
   max(invoiceheader.ivh_lastprintdate) ivh_lastprintdate,    
   @int0 ord_hdrnumber,    
   '' ivh_remark ,    
   min(invoiceheader.ivh_edi_flag) ivh_edi_flag,    
   sum(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
   'RevType1' revtype1,    
   'RevType2' Revtype2,    
   'RevType3' revtype3,    
   'RevType4' revtype4,    
   @int0 ivh_hdrnumber,    
   'UNKNOWN' ivh_order_by,    
   'N/A' ivh_user_id1,    
  @varchar8 ord_number,    
  @char3 ivh_terms,    
  @varchar8 ivh_trailer,    
  max(ivh_tractor) ivh_tractor,    
  @int0 commodities,    
  @int0 validcommodities,    
  @int0 accessorials,    
  @int0 validaccessorials,    
  @varchar6 trltype3,    
   -- @varchar6 cmp_subcompany,    

 Min(IsNull(ord_subcompany,'UNK')),    
  @money totallinehaul,    
  @int0 negativecharges,    
  @int0 edi_210_flag,    
  @chary ismasterbill,    
  'TrlType3' trltype3name,    
  MAX(company.cmp_mastercompany) cmp_mastercompany,    
  @varchar30 refnumber,    
  @char3 cmp_invoiceto,    
  @char1 cmp_invprintto,    
  @int0  cmp_invformat,    
  MAX(company.cmp_transfertype) cmp_transfertype,    
  @Status ivh_Mbstatus,    
  @money trp_linehaulmax,    
  @money trp_totchargemax,    
  max(company.cmp_invcopies) cmp_invcopies,    
  max(company.cmp_mbgroup) cmp_mbgroup,    
  max(invoiceheader.ivh_originpoint) ivh_originpoint,    
  max(invoiceheader.ivh_batch_id),    
  max(company.cmp_invoicetype) cmp_invoicetype,    
  max(isnull(invoiceheader.tar_tariffitem,'')),    
  max(IsNull(invoiceheader.tar_tarriffnumber,'')),    
  --max(IsNull(invoiceheader.ivh_ref_number,'')),    
  Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),    
  max(ivh_definition) ivh_definition,    
  max(ivh_applyto) ivh_applyto,    
  max(IsNull(orderheader.ord_fromorder,'')),    
  cmd_code = CASE max(company.cmp_mbgroup)    
          WHEN 'DRPUCMDPO' THEN    
    min(orderheader.cmd_code)     
      WHEN 'DRCMDPO' THEN min(orderheader.cmd_code)    
      WHEN 'PUCMDPO' THEN min(orderheader.cmd_code)    
      WHEN 'CMDPO' THEN min(orderheader.cmd_code)    
            WHEN 'ORGCMD' THEN   min(orderheader.cmd_code)     
    When 'DRPO' Then 'ALL'    
    When 'DRPUPO' Then 'ALL'    
    When 'PO' Then 'ALL'    
    When 'PUPO' Then 'ALL'    
       ELSE     
    'UNKNOWN'    
      END ,  
 production_year = Min( datepart(year,Dateadd(hour,-7,ivh_shipdate))) ,  
 production_month = Min(Datepart(month,Dateadd(hour,-7,ivh_shipdate))),
 @varchar254 cmp_image_routing1,
 @varchar254 cmp_image_routing2,
 @varchar254 cmp_image_routing3 ,
	max(IsNull(ivh_company, 'UNK')),
 max(IsNull(ivh_showshipper,'UNKNOWN')),
 max(IsNull(ivh_showcons,'UNKNOWN')) ,
 max( isnull(invoiceheader.car_key,0)) ,
 		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
	max(isnull(invoiceheader.ivh_driver,'UNKNOWN')) -- PTS 48221 SGB 06/17/2010	
-- INTO #invview    
  FROM invoiceheader
		Left Outer Join orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
		Join company on ( company.cmp_id = invoiceheader.ivh_billto )  
		Join #batch on ( invoiceheader.ivh_batch_id = #batch.batch_id )
--43745 recode PRB PTS32823 added Left Join of reftable
		LEFT OUTER JOIN referencenumber ON 	ref_tablekey = CASE (invoiceheader.ord_hdrnumber) 
																WHEN 0 then invoiceheader.ivh_hdrnumber 
																ELSE invoiceheader.ord_hdrnumber
															END
		and ref_table = CASE (invoiceheader.ord_hdrnumber) 
							WHEN 0 then 'invoiceheader' 
							ELSE 'orderheader' 
						END
		and ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
					WHEN '' THEN @cmp_dflt_reftype
					WHEN 'UNK' THEN @cmp_dflt_reftype
					ELSE company.cmp_reftype_unique
				     END
		and ref_sequence = CASE (invoiceheader.ord_hdrnumber)
						WHEN 0 THEN (SELECT MIN(ref_sequence)
						      		    FROM referencenumber r
						      		    WHERE r.ref_tablekey = invoiceheader.ivh_hdrnumber
						      		    AND ref_table = 'invoiceheader'
					              		    AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
									WHEN '' THEN @cmp_dflt_reftype
									WHEN 'UNK' THEN @cmp_dflt_reftype
									ELSE company.cmp_reftype_unique
								     END)
						ELSE	(SELECT MIN(ref_sequence)
						      		    FROM referencenumber r
						      		    WHERE r.ord_hdrnumber = invoiceheader.ord_hdrnumber
						      		    AND ref_table = 'orderheader'
					              		    AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
									WHEN '' THEN @cmp_dflt_reftype
									WHEN 'UNK' THEN @cmp_dflt_reftype
									ELSE company.cmp_reftype_unique
								     END)
						END
		--43745 END PRB       
 WHERE ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= (case when cmp_mbdays < 0 then '20491231 23:59' else @PrintDate end) )     --<= @PrintDate )            
  --AND (  @Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)       
  AND (  @Status = invoiceheader.ivh_mbstatus)     
  AND (company.cmp_invoicetype in ('BTH','MAS') )    
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
-- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND   charindex(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
-- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND   charindex(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
-- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND   charindex(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
-- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND   charindex(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
  --And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  --And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0)) not used except reprint of invoices    
	AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select MIN(stp_schdtearliest)  
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2) or
	invoiceheader.ord_hdrnumber = 0)
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
/*  
    group by CASE cmp_mbgroup 
    WHEN 'TRC'    then invoiceheader.ivh_billto + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + invoiceheader.ivh_revtype1    
    WHEN 'SHPCON' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber +    
                      invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
        WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee +    
                                     orderheader.cmd_code    
   WHEN 'DRPUPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
         isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
         invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
   + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto +IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +    
          isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'')  +     
          isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
   
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'')  
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_ref_number,'')   
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 

    ELSE invoiceheader.ivh_billto    
   END 
*/
 group by CASE cmp_mbgroup 
    WHEN 'CO' Then  invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
    WHEN 'TRC'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_revtype1    
    WHEN 'SHPCON' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_invoicenumber +    
                                     invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
    WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee +    
                                     orderheader.cmd_code    
   WHEN 'DRPUPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(invoiceheader.ivh_currency ,'') +     
         isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
         invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
   + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +    
          isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'')  +     
          isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
   
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(orderheader.ord_fromorder,'') 
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_ref_number,'') 
    
    When 'CMPREV2CUR' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) +IsNull(invoiceheader.ivh_company,'UNKNOWN')+IsNull(invoiceheader.ivh_revtype2,'UNK')
      + Case IsNull(invoiceheader.ivh_currency,'Z-C$') When 'UNK' Then 'Z-C$' else IsNull(invoiceheader.ivh_currency,'Z-C$') END  
    
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'ORD_HDRNUMBER' Then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + convert (varchar, invoiceheader.ord_hdrnumber) --PTS 25699 
    WHEN 'COMPREFTYPE' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ ISNULL(referencenumber.ref_number, '') -- PTS 32823
	--ILB/JJF 24619
    WHEN 'MASORD' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(orderheader.ord_fromorder,'')
    WHEN 'TCKTNUM' Then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
	--END ILB/JJF 24619
	WHEN 'CONSIGNEE' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
    WHEN 'SHIPPER' then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
    ELSE invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))   
   END   
, invoiceheader.ivh_batch_id		-- LOR PTS# 18983     
       
 IF @byuser = 'Y'    
 INSERT INTO #invview     
 SELECT 0 mov_number,    
   ivh_invoicenumber = CASE max(company.cmp_mbgroup)    
          WHEN 'INV' THEN    
             min(invoiceheader.ivh_invoicenumber)    
          ELSE    
      'Master'    
       END,    
   min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
   min(invoiceheader.ivh_billto) ivh_billto,    
   @varchar30 billto_name,    
   ivh_shipper = CASE max(company.cmp_mbgroup)    
       WHEN 'SHPCON' THEN    
             min(invoiceheader.ivh_shipper)    
    WHEN 'ORGCMD' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'DRPUPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'DRPUCMDPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'PUPO' THEN    
       min(invoiceheader.ivh_shipper)    
    WHEN 'PUCMDPO' THEN    
       min(invoiceheader.ivh_shipper)    
       ELSE    
                     @shipper    
               END,    
   @varchar30 shipper_name,    
   ivh_consignee = CASE max(company.cmp_mbgroup)    
          WHEN 'SHPCON' THEN    
               min(invoiceheader.ivh_consignee)    
      WHEN 'ORGCMD' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPUPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPUCMDPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRCMDPO' THEN    
         min(invoiceheader.ivh_consignee)    
      WHEN 'DRPO' THEN    
         min(invoiceheader.ivh_consignee)    
         ELSE    
               @consignee    
   END,    
   @varchar30 consignee_name,    
   min(invoiceheader.ivh_shipdate) ivh_shipdate,    
   max(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
   ivh_revtype1 = CASE max(company.cmp_mbgroup)    
     WHEN 'REV1' THEN    
        min(invoiceheader.ivh_revtype1)    
     When 'CMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPUCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'DRPUPO' Then min(invoiceheader.ivh_revtype1)    
     When 'PO' Then min(invoiceheader.ivh_revtype1)    
     When 'PUCMDPO' Then min(invoiceheader.ivh_revtype1)    
     When 'PUPO' Then min(invoiceheader.ivh_revtype1)    
     WHEN 'ALL' THEN    
        'ALL'    
     ELSE    
        @rev1    
         END,    
  @rev2 ivh_revtype2,    
   @rev3 ivh_revtype3,      
  @rev4 ivh_revtype4,    
   sum(invoiceheader.ivh_totalweight) ivh_totalweight,    
   sum(invoiceheader.ivh_totalpieces) ivh_totalpieces,    
   sum(invoiceheader.ivh_totalmiles) ivh_totalmiles,    
   sum(invoiceheader.ivh_totalvolume) ivh_totalvolume,    
   max(invoiceheader.ivh_printdate) ivh_printdate,      
   min(invoiceheader.ivh_billdate) ivh_billdate,    
   max(invoiceheader.ivh_lastprintdate) ivh_lastprintdate,    
   @int0 ord_hdrnumber,    
   '' ivh_remark ,    
   min(invoiceheader.ivh_edi_flag) ivh_edi_flag,    
   sum(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
   'RevType1' revtype1,    
   'RevType2' Revtype2,    
   'RevType3' revtype3,    
   'RevType4' revtype4,    
   @int0 ivh_hdrnumber,    
   'UNKNOWN' ivh_order_by,    
   'N/A' ivh_user_id1,    
  @varchar8 ord_number,    
  @char3 ivh_terms,    
  @varchar8 ivh_trailer,    
  max(ivh_tractor) ivh_tractor,    
  @int0 commodities,    
  @int0 validcommodities,    
  @int0 accessorials,    
  @int0 validaccessorials,    
  @varchar6 trltype3,    
  -- @varchar6 cmp_subcompany,    
 MIN(IsNull(ord_subcompany,'UNK')),    
  @money totallinehaul,    
  @int0 negativecharges,    
  @int0 edi_210_flag,    
  @chary ismasterbill,    
  'TrlType3' trltype3name,    
  MAX(company.cmp_mastercompany) cmp_mastercompany,    
  @varchar30 refnumber,    
  @char3 cmp_invoiceto,    
  @char1 cmp_invprintto,    
  @int0  cmp_invformat,    
  MAX(company.cmp_transfertype) cmp_transfertype,    
  @Status ivh_Mbstatus,    
  @money trp_linehaulmax,    
  @money trp_totchargemax,    
  max(company.cmp_invcopies) cmp_invcopies,    
  max(company.cmp_mbgroup) cmp_mbgroup,    
  max(invoiceheader.ivh_originpoint) ivh_originpoint,    
  max(invoiceheader.ivh_batch_id),    
  max(company.cmp_invoicetype) cmp_invoicetype,    
  max(isnull(invoiceheader.tar_tariffitem,'')),    
  max(IsNull(invoiceheader.tar_tarriffnumber,'')),    
  --max(IsNull(invoiceheader.ivh_ref_number,'')),    
  Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),    
  max(ivh_definition) ivh_definition,    
  max(ivh_applyto) ivh_applyto,    
      max(IsNull(orderheader.ord_fromorder,'')) ord_fromorder,    
  cmd_code = CASE max(company.cmp_mbgroup)    
          WHEN 'DRPUCMDPO' THEN    
    min(orderheader.cmd_code)     
      WHEN 'DRCMDPO' THEN min(orderheader.cmd_code)    
      WHEN 'PUCMDPO' THEN min(orderheader.cmd_code)    
      WHEN 'CMDPO' THEN min(orderheader.cmd_code)    
            WHEN 'ORGCMD' THEN   min(orderheader.cmd_code)     
    When 'DRPO' Then 'ALL'    
    When 'DRPUPO' Then 'ALL'    
    When 'PO' Then 'ALL'    
    When 'PUPO' Then 'ALL'    
       ELSE     
    'UNKNOWN'    
      END ,  
 production_year = Min( datepart(year,Dateadd(hour,-7,ivh_shipdate))) ,  
 production_month = Min(Datepart(month,Dateadd(hour,-7,ivh_shipdate))),
 @varchar254 cmp_image_routing1,
 @varchar254 cmp_image_routing2,
 @varchar254 cmp_image_routing3 ,
	max(IsNull(ivh_company, 'UNK')), 
 max(IsNull(ivh_showshipper,'UNKNOWN')),
 max(IsNull(ivh_showcons,'UNKNOWN')) ,
 max( isnull(invoiceheader.car_key,0))    ,
 		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')) -- PTS 48221 SGB 06/17/2010	
-- INTO #invview    
  FROM invoiceheader
		Left Outer Join orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
		Join company on ( company.cmp_id = invoiceheader.ivh_billto )  
		Join #batch on ( invoiceheader.ivh_batch_id = #batch.batch_id )  
--43745 recode PRB PTS32823 added Left Join of reftable
		LEFT OUTER JOIN referencenumber ON 	ref_tablekey = CASE (invoiceheader.ord_hdrnumber) 
																WHEN 0 then invoiceheader.ivh_hdrnumber 
																ELSE invoiceheader.ord_hdrnumber
															END
		and ref_table = CASE (invoiceheader.ord_hdrnumber) 
							WHEN 0 then 'invoiceheader' 
							ELSE 'orderheader' 
						END
		and ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
					WHEN '' THEN @cmp_dflt_reftype
					WHEN 'UNK' THEN @cmp_dflt_reftype
					ELSE company.cmp_reftype_unique
				     END
		and ref_sequence = CASE (invoiceheader.ord_hdrnumber)
						WHEN 0 THEN (SELECT MIN(ref_sequence)
						      		    FROM referencenumber r
						      		    WHERE r.ref_tablekey = invoiceheader.ivh_hdrnumber
						      		    AND ref_table = 'invoiceheader'
					              		    AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
									WHEN '' THEN @cmp_dflt_reftype
									WHEN 'UNK' THEN @cmp_dflt_reftype
									ELSE company.cmp_reftype_unique
								     END)
						ELSE	(SELECT MIN(ref_sequence)
						      		    FROM referencenumber r
						      		    WHERE r.ord_hdrnumber = invoiceheader.ord_hdrnumber
						      		    AND ref_table = 'orderheader'
					              		    AND ref_type = CASE ISNULL(company.cmp_reftype_unique, '')
									WHEN '' THEN @cmp_dflt_reftype
									WHEN 'UNK' THEN @cmp_dflt_reftype
									ELSE company.cmp_reftype_unique
								     END)
						END
		--43745 END PRB       
  WHERE( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= (case when cmp_mbdays < 0 then '20491231 23:59' else @PrintDate end) )     --<= @PrintDate )        
  --AND (  @Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)      
  AND (  @Status = invoiceheader.ivh_mbstatus)    
  AND (company.cmp_invoicetype in ('BTH','MAS') )    
  AND ( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) )     
  AND ( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) )     
  AND ( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) )     
  AND ( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) )     
  AND ( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 )     
  AND ( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 )     
-- AND  ( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) )     
  AND   charindex(',' + @rev1 + ',', ',UNK,' + ivh_revtype1 + ',') > 0 
-- AND  ( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) )     
  AND   charindex(',' + @rev2 + ',', ',UNK,' + ivh_revtype2 + ',') > 0 
-- AND  ( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )     
  AND   charindex(',' + @rev3 + ',', ',UNK,' + ivh_revtype3 + ',') > 0 
-- AND  ( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) )     
  AND   charindex(',' + @rev4 + ',', ',UNK,' + ivh_revtype4 + ',') > 0     
  AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )    
  and ivh_user_id1 = @user_id    
  AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and    
   ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2)     
     or invoiceheader.ivh_xferdate IS null)) or    
   @status not in ('XFR'))    
  --And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))    
  --And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0)) imagestatus only used for reprint of invoices    
	AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select MIN(stp_schdtearliest)  
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2) or
	invoiceheader.ord_hdrnumber = 0)
	AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221

/*  
    group by CASE cmp_mbgroup 
    WHEN 'TRC'    then invoiceheader.ivh_billto + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + invoiceheader.ivh_revtype1    
    WHEN 'SHPCON' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + invoiceheader.ivh_invoicenumber +    
                      invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
        WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee +    
                                     orderheader.cmd_code    
   WHEN 'DRPUPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
         isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
         invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
   + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto +IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +    
          isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'')  +     
          isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
   
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'')  
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + IsNull(invoiceheader.ivh_ref_number,'')   
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 

    ELSE invoiceheader.ivh_billto    
   END 
*/
   group by CASE cmp_mbgroup  
    WHEN 'CO' Then  invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_company     
    WHEN 'TRC'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_tractor    
    WHEN 'ORIGIN' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_originpoint    
    WHEN 'REV1'   then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_revtype1    
    WHEN 'SHPCON' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee    
    WHEN 'INV'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_invoicenumber +    
                                     invoiceheader.ivh_shipper + invoiceheader.ivh_consignee    
    WHEN 'ORGCMD' then invoiceheader.ivh_billto + invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee +    
                                     orderheader.cmd_code    
   WHEN 'DRPUPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(invoiceheader.ivh_currency ,'') +     
         isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
         invoiceheader.ivh_consignee + ivh_revtype1 + IsNull(ord_subcompany,'UNK')    
   + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(invoiceheader.ivh_currency ,'') +     
      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
      invoiceheader.ivh_consignee + orderheader.cmd_code  + ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRCMDPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUPO'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +    
      +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PUCMDPO' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper +     
          orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'PO'      then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +    
          isnull(invoiceheader.tar_tariffitem,'')  +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'CMDPO'   then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'')  +     
          isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code +  ivh_revtype1 + IsNull(ord_subcompany,'UNK')  
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
    WHEN 'DRPO'    then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_currency ,'') +     
          isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee +      
      ivh_revtype1 + IsNull(ord_subcompany,'UNK')   
  + Convert(char(4),datepart(year,Dateadd(hour,-7,ivh_deliverydate))) + Convert(char(2),Datepart(month,Dateadd(hour,-7,ivh_deliverydate)) )  
   
    WHEN 'FROMORD' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(orderheader.ord_fromorder,'') 
    WHEN 'REF#1' Then  invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) + IsNull(invoiceheader.ivh_ref_number,'') 
    
    When 'CMPREV2CUR' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0)) +IsNull(invoiceheader.ivh_company,'UNKNOWN')+IsNull(invoiceheader.ivh_revtype2,'UNK')
      + Case IsNull(invoiceheader.ivh_currency,'Z-C$') When 'UNK' Then 'Z-C$' else IsNull(invoiceheader.ivh_currency,'Z-C$') END  
    
    WHEN 'SHPCONREF' then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_shipper +     
                invoiceheader.ivh_consignee + IsNull(invoiceheader.ivh_ref_number,'') 
    WHEN 'ORD_HDRNUMBER' Then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + convert (varchar, invoiceheader.ord_hdrnumber) --PTS 25699 
    WHEN 'COMPREFTYPE' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ ISNULL(referencenumber.ref_number, '') -- PTS 32823
	--ILB/JJF 24619
    WHEN 'MASORD' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ IsNull(orderheader.ord_fromorder,'')
    WHEN 'TCKTNUM' Then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_invoicenumber
	--END ILB/JJF 24619
	WHEN 'CONSIGNEE' Then invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))+ invoiceheader.ivh_consignee --PTS 40126
    WHEN 'SHIPPER' then invoiceheader.ivh_billto+ convert(varchar(8),IsNull(invoiceheader.car_key,0)) + invoiceheader.ivh_shipper -- PTS 40126 exztra
    ELSE invoiceheader.ivh_billto + convert(varchar(8),IsNull(invoiceheader.car_key,0))   
   END       
, invoiceheader.ivh_batch_id		-- LOR PTS# 18983       
    
 END    
    
-- If selection datawindow has masterbills and status = 'PRN' the    
-- only parameter used is the master bill number    
    
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) > 0  and exists(select 1 from invoiceheader where ivh_mbnumber = @mbnumber)   
BEGIN    
 IF @byuser = 'N' 
 INSERT INTO #invview     
 SELECT 0 mov_number,    
   'Master' ivh_invoicenumber,    
   min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
   min(invoiceheader.ivh_billto) ivh_billto,    
   @varchar30 billto_name,    
   'UNKNOWN' ivh_shipper,    
   @varchar30 shipper_name,    
   'UNKNOWN' ivh_consignee,    
   @varchar30 consignee_name,    
   min(invoiceheader.ivh_shipdate) ivh_shipdate,    
   max(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
   @rev1 ivh_revtype1,      
  @rev2 ivh_revtype2,    
   @rev3 ivh_revtype3,      
  @rev4 ivh_revtype4,    
   sum(invoiceheader.ivh_totalweight) ivh_totalweight,    
   sum(invoiceheader.ivh_totalpieces) ivh_totalpieces,    
   sum(invoiceheader.ivh_totalmiles) ivh_totalmiles,    
   sum(invoiceheader.ivh_totalvolume) ivh_totalvolume,    
   max(invoiceheader.ivh_printdate) ivh_printdate,      
   min(invoiceheader.ivh_billdate) ivh_billdate,    
   max(invoiceheader.ivh_lastprintdate) ivh_lastprintdate,    
   @int0 ord_hdrnumber,    
   '' ivh_remark ,    
   min(invoiceheader.ivh_edi_flag) ivh_edi_flag,    
   sum(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
   'RevType1' revtype1,    
   'RevType2' Revtype2,    
   'RevType3' revtype3,    
   'RevType4' revtype4,    
   @int0 ivh_hdrnumber,    
   'UNKNOWN' ivh_order_by,    
   'N/A' ivh_user_id1,    
  @varchar8 ord_number,    
  @char3 ivh_terms,    
  @varchar8 ivh_trailer,    
  max(ivh_tractor) ivh_tractor,    
  @int0 commodities,    
  @int0 validcommodities,    
  @int0 accessorials,    
  @int0 validaccessorials,    
  @varchar6 trltype3,    
 cmp_subcompany = MIN(ord_subcompany),
  @money totallinehaul,    
  @int0 negativecharges,    
  @int0 edi_210_flag,    
  @chary ismasterbill,    
  'TrlType3' trltype3name,    
  MAX(company.cmp_mastercompany) cmp_mastercompany,    
  @varchar30 refnumber,    
  @char3 cmp_invoiceto,    
  @char1 cmp_invprintto,    
  @int0  cmp_invformat,    
  MAX(company.cmp_transfertype) cmp_transfertype,    
  min(invoiceheader.ivh_mbstatus)  ivh_Mbstatus,    
  @money trp_linehaulmax,    
  @money trp_totchargemax,    
  max(company.cmp_invcopies) cmp_invcopies,    
  max(company.cmp_mbgroup) cmp_mbgroup,    
  max(invoiceheader.ivh_originpoint) ivh_originpoint,    
  max(invoiceheader.ivh_batch_id),    
  max(company.cmp_invoicetype) cmp_invoicetype,    
  max(isnull(invoiceheader.tar_tariffitem,'')),    
  max(IsNull(invoiceheader.tar_tarriffnumber,'')),    
  --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
  Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),    
  max(ivh_definition) ivh_definition,    
  max(ivh_applyto) ivh_applyto,    
  '',    
  max(orderheader.cmd_code) orderheader_cmd_code  ,  
 production_year = Min( datepart(year,Dateadd(hour,-7,ivh_shipdate))) ,  
 production_month = Min(Datepart(month,Dateadd(hour,-7,ivh_shipdate))),
 @varchar254 cmp_image_routing1,
 @varchar254 cmp_image_routing2,
 @varchar254 cmp_image_routing3 ,
	max(IsNull(ivh_company, 'UNK')),
 max(IsNull(ivh_showshipper, 'UNKNOWN')),
 max(IsNull(ivh_showcons, 'UNKNOWN')),   --PTS39913 corrected spelling,
 max( isnull(invoiceheader.car_key,0)) ,
 		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')) -- PTS 48221 SGB 06/17/2010	
-- INTO #invview    
  FROM invoiceheader
		Left Outer Join orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
		Join company on ( company.cmp_id = invoiceheader.ivh_billto )  
		Join #batch on ( invoiceheader.ivh_batch_id = #batch.batch_id )    
 WHERE ( ivh_mbnumber = @mbnumber) 
/*      
  AND @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)    
  And invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end) and
	(((select MIN(stp_schdtearliest)  
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2) or
	invoiceheader.ord_hdrnumber = 0)  
*/ 
 group by invoiceheader.ivh_batch_id    
     
 IF @byuser = 'Y'    
 INSERT INTO #invview     
 SELECT 0 mov_number,    
   'Master' ivh_invoicenumber,    
   min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,    
   min(invoiceheader.ivh_billto) ivh_billto,    
   @varchar30 billto_name,    
   'UNKNOWN' ivh_shipper,    
   @varchar30 shipper_name,    
   'UNKNOWN' ivh_consignee,    
   @varchar30 consignee_name,    
   min(invoiceheader.ivh_shipdate) ivh_shipdate,    
   max(invoiceheader.ivh_deliverydate) ivh_deliverydate,    
   @rev1 ivh_revtype1,      
  @rev2 ivh_revtype2,    
   @rev3 ivh_revtype3,      
  @rev4 ivh_revtype4,    
   sum(invoiceheader.ivh_totalweight) ivh_totalweight,    
   sum(invoiceheader.ivh_totalpieces) ivh_totalpieces,    
   sum(invoiceheader.ivh_totalmiles) ivh_totalmiles,    
   sum(invoiceheader.ivh_totalvolume) ivh_totalvolume,    
   max(invoiceheader.ivh_printdate) ivh_printdate,      
   min(invoiceheader.ivh_billdate) ivh_billdate,    
   max(invoiceheader.ivh_lastprintdate) ivh_lastprintdate,    
   @int0 ord_hdrnumber,    
   '' ivh_remark ,    
   min(invoiceheader.ivh_edi_flag) ivh_edi_flag,    
   sum(invoiceheader.ivh_totalcharge) ivh_totalcharge,    
   'RevType1' revtype1,    
   'RevType2' Revtype2,    
   'RevType3' revtype3,    
   'RevType4' revtype4,    
   @int0 ivh_hdrnumber,    
   'UNKNOWN' ivh_order_by,    
   'N/A' ivh_user_id1,    
  @varchar8 ord_number,    
  @char3 ivh_terms,    
  @varchar8 ivh_trailer,    
  max(ivh_tractor) ivh_tractor,    
  @int0 commodities,    
  @int0 validcommodities,    
  @int0 accessorials,    
  @int0 validaccessorials,    
  @varchar6 trltype3,    
  cmp_subcompany = Min(ord_subcompany),    
  @money totallinehaul,    
  @int0 negativecharges,    
  @int0 edi_210_flag,    
  @chary ismasterbill,    
  'TrlType3' trltype3name,    
  MAX(company.cmp_mastercompany) cmp_mastercompany,    
  @varchar30 refnumber,    
  @char3 cmp_invoiceto,    
  @char1 cmp_invprintto,    
  @int0  cmp_invformat,    
  MAX(company.cmp_transfertype) cmp_transfertype,    
  min(invoiceheader.ivh_mbstatus)  ivh_Mbstatus,    
  @money trp_linehaulmax,    
  @money trp_totchargemax,    
  max(company.cmp_invcopies) cmp_invcopies,    
  max(company.cmp_mbgroup) cmp_mbgroup,    
  max(invoiceheader.ivh_originpoint) ivh_originpoint,    
  max(invoiceheader.ivh_batch_id),    
  max(company.cmp_invoicetype) cmp_invoicetype,    
  max(isnull(invoiceheader.tar_tariffitem,'')),    
  max(IsNull(invoiceheader.tar_tarriffnumber,'')),    
  --Max(IsNull(invoiceheader.ivh_ref_number,'')),    
  Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),    
  max(ivh_definition) ivh_definition,    
  max(ivh_applyto) ivh_applyto,    
  '',    
  max(orderheader.cmd_code) orderheader_cmd_code ,  
 production_year = Min( datepart(year,Dateadd(hour,-7,ivh_shipdate))) ,  
 production_month = Min(Datepart(month,Dateadd(hour,-7,ivh_shipdate))),
 @varchar254 cmp_image_routing1,
 @varchar254 cmp_image_routing2,
 @varchar254 cmp_image_routing3,
	max(IsNull(ivh_company, 'UNK')),
 max(IsNull(ivh_showshipper,'UNKNOWN')),
 max(IsNull(ivh_showcons,'UNKNOWN')) ,
 max( isnull(invoiceheader.car_key,0))    ,
 		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
	max(isnull(invoiceheader.ivh_driver,'UNKNOWN')) -- PTS 48221 SGB 06/17/2010	
-- INTO #invview    
  FROM invoiceheader
		Left Outer Join orderheader on orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber
		Join company on ( company.cmp_id = invoiceheader.ivh_billto )  
		Join #batch on ( invoiceheader.ivh_batch_id = #batch.batch_id )     
 WHERE ( ivh_mbnumber = @mbnumber)     
  and ivh_user_id1 = @user_id 
/*   
  AND @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)    
  And invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end) and
	(((select MIN(stp_schdtearliest)  
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and  stp_sequence = (select min(stp_sequence) from stops b where b.ord_hdrnumber = invoiceheader.ord_hdrnumber))
		between @sch_date1 and @sch_date2) or
	invoiceheader.ord_hdrnumber = 0)  
*/ 
 group by invoiceheader.ivh_batch_id    
END    
delete from #invview where ivh_billto is null    

UPDATE	#invview
   SET	#invview.cmp_image_routing1 = company.cmp_image_routing1,
		#invview.cmp_image_routing2 = company.cmp_image_routing2,
		#invview.cmp_image_routing3 = company.cmp_image_routing3
  FROM	company
 WHERE	#invview.ivh_billto = company.cmp_id

SELECT * from #invview      
    
 
GO
GRANT EXECUTE ON  [dbo].[d_invoices_printqueue3_batch] TO [public]
GO
