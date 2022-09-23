SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_inv_edit_detail_sp] (@stringparm  varchar(12),    
     @numberparm  int,    
     @retrieve_by varchar(8),    
     @suffix  varchar(6),    
     @trlrentcht varchar(254),
     @p_prerating char(1) )    
AS    
 set NOCOUNT on
/*                RETRIEVE OPTIONS
  Type ORDER
     inv_hdr is called with stringparm of ord_number and "ORDNUM"
     inv_det is called with numberparm of ord_hdrnumber and "ORDHDR" if invoice exists ,else "ORDNUM" if invoice does not exist
     (1) if an invoice exists with this order number in the header, retrieve by ordnum
     (2) If not and if a record exist for this order in the invoicemaster (orders on invoice by move) then 
           retrieve by the order number in the invoice master (lowest order number on move)
     (3) If not then check to see if the bill to company invoices by order or move
         (a) If inovice by order go ahead with retrieving information form the order
         (b) If invoice by move, check the following:
              i) If All orders on the move are ready to invoice, retrieve using cmp_invoiceby flag (ORD or MOV)
                 retrieval and the mov_number for the order.
  Type INVOICE (includes misc)
     inv_hdr is called with stringparm of invoice number and "INVNUM"
     inv_det is called with number parm of ivh_hdrnumber and "INVHDR"
  Type MOVE (called once for order selected from the move. Application changed
      to list orders by billto for the move and add an indication that the mov number can
      be found in the invoicemaster) 
      (1) if an order is select that has the invoicemaster flag on call
          this proc with the order number on the invoicemaster 
      (2) if the order does not have the invoicemaster flag set call proc with
          selected order number.
  Type Master Bill# (called once for each invoice in the master bill list as the queue is navigated)
      Calls are same as for invoice number lookup


Sample calls

execute dbo.d_inv_edit_detail_sp   '', 7382, 'ORDNUM', 'SUFFIX', '',  'Y'
execute dbo.d_inv_edit_detail_sp   @stringparm = '4005506', @numberparm = -1, @retrieve_by = 'ORDNUM', @suffix = 'SUFFIX', @trlrentcht = '', @p_prerating = 'Y'

*/
/***************** production *******************************/    
/* LOR 12/11/97 add suffix as parm and suffix/prefix, billto in return set for multinvoicing     
8760    10/7/00 return the new cols fgt_ratingquantity, fgt_ratingunit,    
				and fgt_quantity_type in anticipationof the day when we truly    
 				handle fix quantities in rate by detail in Order Entry    
  
-- JET - 3/17/2003 - PTS 17617, need to force this thing to recreate.  
        
dpete pts6945 12/22/99 details for multiple order invoices not retrieved when retrieveby invhdr    
dpete pts6691 change tmep table type for ivd_count to float    
change the UNION to UNION ALL #8177    
8760 read fgt_ratingquantity fgt_ratinunit (for future fix in rate by detail)    
        	and new ivd_quantity_type    
9974 3/9/01 For non PUP/DRP stops, pickup eventcode name for ivd_description    
11536 return ivd_charge_type    
10/23/2001 Vern Jewett (label=vmj1) PTS 11668: All-Inclusive charges.    
12523 12/04/01 DPETE add ivd_rate_type to return set    
pts12599 dpete 12/09/01 bring back cmp_geoloc for each stop    
PTS14101 DPETE 4/26/02 In order to get freightdetail in sequence fabricate an initial ivd_sequence from the     
          	stp_sequence and the freightsequence, assumes there are no more than 30 freightdetail on a stop    
          	and 30 stops on a trip (or you run over the accessorials and need to change the default number on    
           	accessorails created before invoicing to a number > 999  See (stops.stp_sequence * 30 + fgt_sequence)    
07/25/2002 Vern Jewett (label=vmj2) PTS 14924: lengthen ivd_description from 30 to 60 chars.    
07/31/02 DPETE 14202 add fgt_number to return set (added to invoicedetail)    
08/30/02 DPETE 14202 Failed QA wants the ref button color to be right  
09/12/02 KMM 15433, add ivd_paylgh_number to resultset  
09/12/02 KMM 15484, expand glnum variable to be char(32) not char(20) 
04/18/03 DPETE populate ivd_billto field 
9/8/3 DPETE 18414 noticed rate by miles trip with multiple freigt details sums miles for each freight detail on same stop
6/8/4 DPETE 19362 change a bit to allow retrieving rebill recs from the order change DSK code for length override at DSK request
11/29/2004	KWS 18526 Union all details created via the order services table
03/30/2005	KWS 27449 Subtract the tare_weight from the weight during the freightdetail retrieve if the setting is turned on
05/03/2005	KWS 18526 Only retrieve services where the rate and actual quantity are greater than 0 and calculate the charge
03/30/2006	DJM	32320	Add the ivd_hide and usr_supervisor fields to the datawindow that have been available
						in Dispatch for some time. 
05/19/2006	vjh	33030	Add CopyInvDetFromMaster
9/27/06		LOR	PTS# 33517	INVMISC
11/17/06	DPETE 33614 tax flags for commidites are incoorect where there are more than one commodity per stop
04/02/07	EMK PTS 35796 Add ivd_tollcost for toll costs display.
04/15/07 	EMK PTS 35555 Added ivd_ARTaxAuth
08/31/07 	DPETE 33644  (add on) add fgt_shipper to return set for future development
09/25/77 	EMK PTS 38777 Add ivd_tax_basis for Trimac Reintegration
10/1/2007   JDS PTS 38773 Add new columns for Trimac Reintegration { 9 areas }
10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
11/14/07 SR40230 (cons to 40012) add fgt_supplier to return set
12/11/07 39660 rebills of invoices with null in the tax flag fields do not compute taxes.
 2/18/08 EMK 38823
 5.30/08 PH recode add support for splitting freight records across multiple freight_by_compartment compartments (with 
          unique manifest numbers)
06/05/2008	pmill PTS42289 add ivd_showas_cmpid and stp_showas_cmpid columns
7/7/08 PTS 41691 DPETE decimal places are rounding on the volume field when lareg numbers entered with 4 decimal places
08/27/08 DPETE PTS 43756 Pauls recoded problems with reference numbers
11/11/08 DPETE 43837 add support for invoicing by move
2/13/09 44417 (check in 45772) DPETE add new invoice by - move & consingee
3/10/09 JBAUW  fix to check in with 45772
29jul08 KCD 43782 Modification to not return fgt_actual_quantity for 'credit' invoices.  Current case statement tests for >0 when it should test for <>0
9/15/09 DPETE PTS 48949 Need to handle over 1500 commodities on a stop
1/14/10 PETE 48966 Pass new argument toi signal pre rating . Assume order is to be rated by order if pre rating (as opposed to by mov ro by CON)
1/19/10 PTS 50347 (cons 48966) billing quantity appears to hav emany decimal places when it comes for Order Entry
      with 2 a billing quty of 14.16 will come throu to Invoicing as 14.159999999
 3/23/10 PTS 51331 do not override ivd_sequence for new invoices if GI ChargesModeForApp set to NVOCHarges for OE or Disp
9/16/10 PTS53991 sequence of line items with min charges geetting messed up in invoicing
7/21/11 PTS 56312 added new colum ivd_description_type will be used in Dedicated Billing
 9/19/11 DPETE PTS58090
 01/16/12 SGB SGB PTS58737 added new columns to support Dedicated Billing roll into ivd_rated_qty and ivd_rated_rate
 1/17/12 DPETE PTS60268 invoicing dot net pre rated orders is still having sequence problems.
03/28/12 NQIAO PTS 59136 
 08/14/12 DPETE PTS 63734  add ivd_customer_char1 field for CREngland
MTC PTS#70755 Changed 2 temp tables to table variables to reduce/eliminate chronic recompilation due to stats updates on temp objects
09/05/17 MBR NSUITE-106669 When a rate by detail order has been pre-rated in Ops, the invoicedetails will now already exist because Ops actually creates
             invoicedetails now.  When the order is first loaded into PB Invoicing it creates an invoicedetail for every freight record.  This
             is causing duplicates because now the pre-rated freight inovicedetail already exists.  I am deleting any freight record detail
             that has a corresponding pre-rated freight detail from Ops.			 
*/    
  
DECLARE @tmwuser varchar (255)
declare @consignee varchar(8)

declare @Unittypes table(labeldefinition varchar(50), abbr varchar(6))

declare @temp_inv table (    
	ivh_hdrnumber  int null,     
	ivd_number  int not null,     
	ivd_description  varchar(60) null,     
	ivd_quantity  decimal(18,6) null,   --41691 float(15) null,     
	ivd_rate  money null,     
	ivd_charge  money null,     
	ivd_taxable1  char(1) null,     
	ivd_taxable2  char(1) null,     
	ivd_taxable3  char(1) null,     
	ivd_taxable4  char(1) null,     
	ivd_unit  char(6) null,     
	cur_code  char(6) null,     
	ivd_currencydate datetime null,     
	ivd_glnum  char(32) null,     
	ord_hdrnumber  int null,     
	ivd_type  char(6) null,     
	ivd_rateunit  char(6) null,     
	ivd_billto  char(8) null,     
	ivd_itemquantity float(15) null,     
	ivd_subtotalptr  int null,     
	ivd_sequence  int null,     
	ivd_invoicestatus varchar(6) null,     
	mfh_hdrnumber  int null,     
	ivd_refnum  varchar(30) null,     
	cmp_id   varchar(8) null,     
	ivd_distance  float null,     
	ivd_distunit  varchar(6) null,     
	ivd_wgt   decimal(18,6) null, --float(15) null,  --DPH PTS 20013  
	ivd_wgtunit  varchar(6) null,     
	ivd_count decimal(18,2) null, -- 41691  float(15) null,     
	evt_number  int null,     
	ivd_reftype  varchar(6) null,     
	ivd_volume  decimal(18,6) null, -- 41691 float(15) null,     
	ivd_volunit  char(6) null,     
	ivd_orig_cmpid  char(8) null,     
	ivd_countunit  char(6) null,     
	cht_itemcode  char(6) null,     
	cmd_code  varchar(8) null,     
	cht_basis  varchar(6) null,      
	lowtemp   smallint null,       
	hightemp  smallint null,     
	ivd_sign  smallint null,     
	ivd_length  money null,     
	ivd_lengthunit  char(6) null,     
	ivd_width  money null,     
	ivd_widthunit  char(6) null,     
	ivd_height  money null,     
	ivd_heightunit  char(6) null,    
	cht_primary  char(1) null,     
	stp_number  int  null,    
	cht_basisunit  varchar(6) null,    
	ivd_remark  varchar(255) null,    
	tar_number  int null,    
	tar_tariffnumber varchar(12) null,    
	tar_tariffitem  varchar(12) null,    
	ivh_billto  varchar(8) null,    
	suffix_prefix  char(1) null,    
	ivd_fromord  char(1) null,    
	cht_rollintolh          int     null,    
	cty_nmstct  varchar(25) null,    
	stp_city  int null ,    
	origin_city  int null,     
	stp_zipcode             varchar(10) null,    
	origin_zipcode          varchar(10) null,    
	fgt_number  int null,    
	fgt_ratingquantity    decimal(18,6) null,   --   float(15) null,     
	fgt_ratingunit  varchar (6)  null,    
	ivd_quantity_type int null,    
	cht_class  varchar(6) null,    
	ivh_definition  varchar(6) null  
	, fgt_stackable  char(1) null,    
	ivd_mileagetable char(1) null,    
	ivd_charge_type  smallint NULL,    
	ref_stop_count  int null,    
	trlrentcht  varchar(254) null,    
	ivd_trl_rent  varchar(13) null,    
	ivd_trl_rent_start datetime null,    
	ivd_trl_rent_end  datetime null,    
	ivd_rate_type smallint null,    
	cmp_geoloc varchar(50) null,    
	cht_lh_min  char(1) null,    
	cht_lh_rev  char(1) null,    
	cht_lh_stl  char(1) null,    
	cht_lh_prn  char(1) null,    
	cht_lh_rpt  char(1) null,  
	ivd_paylgh_number int null,  
	ivd_tariff_type char(1) null,  
	ivd_taxid varchar (15) null,  
	cht_gp_tax smallint null,  
	ivd_ordered_volume float null,  
	ivd_ordered_loadingmeters float null,    
	ivd_ordered_count float null,    
	ivd_ordered_weight float null,  
	ivd_loadingmeters float null,  
	ivd_loadingmeters_unit varchar (6)  null  ,  
	ivd_revtype1 varchar(6) null,
	ivd_hide	char(1)		null,
	usr_supervisor char(1) Null,
	ivd_tollcost money null,  -- PTS 35976
	ivd_ARTaxAuth varchar(6) null,--PTS 35555 EMK
	cmd_class varchar(8) null, --pts36319
	fgt_shipper varchar(8) null,
	ivd_tax_basis money null, --PTS 38777

	ivd_actual_quantity float null,     -- PTS 38773 
	ivd_actual_unit varchar(6) null,    -- PTS 38773 
	fgt_actual_quantity float null,     -- PTS 38773 
	fgt_actual_unit varchar(6) null,    -- PTS 38773 
	fgt_billable_quantity float null,   -- PTS 38773 
	fgt_billable_unit varchar(6) null,  -- PTS 38773 
    fgt_supplier varchar(8) null,		-- 40230
    ivd_loaded_distance float null, 	--PTS 38823
	ivd_empty_distance float null,		--PTS 38823
	ivd_paid_indicator char (1) null,	--pts 41325
	ivd_paid_amount money null,			--pts 41325
	ivd_leaseassetid int null,			
	ivd_maskFromRating char(1) NULL,	--pts 40259
	ivd_car_key int NULL,				--pts 40259
	ivh_car_key int null,				--pts 40259
	ivd_showas_cmpid varchar(8) NULL,	--PTS 42289
	ivd_post_invoice	char(1)	NULL,		--PTS 35377
    ivd_billable_flag   char(1) NULL,
    ivd_ord_number varchar(13) null,    --PTS43837 for invoice by move
	dbsd_id_tariff int NULL,
	ivd_allocated_ivd_number INT NULL,
	ivd_allocation_type VARCHAR(6) NULL,
	ivd_allocated_qty FLOAT NULL,
	ivd_allocated_rate MONEY NULL,
	ivd_allocated_charge MONEY NULL,
	ivd_reconcile_tariff INT NULL, -- PTS 53514
	ivd_description_type smallint NULL,  -- PTS 56312 SGB
	cht_tax1			Varchar(1)	NULL,	-- MRH Calculated fields for taxes. Not stored on the invoice detail table.
	cht_tax2			Varchar(1)	NULL,
	cht_tax3			Varchar(1)	NULL,
	cht_tax4			Varchar(1)	NULL,
	cht_tax5			Varchar(1)	NULL,
	cht_tax6			Varchar(1)	NULL,
	cht_tax7			Varchar(1)	NULL,
	cht_tax8			Varchar(1)	NULL,
	cht_tax9			Varchar(1)	NULL,
	cht_tax10			Varchar(1)	NULL,
	ivd_rated_qty float null,	-- PTS 58737 SGB
	ivd_rated_rate	MONEY null,	-- PTS 58737 SGB
	dbst_rollinto_tar INT,		-- PTS 58737 SGB
	ivd_customer_char1 char(1) null
)

declare @temp_inv_collect table (ivh_hdrnumber  int null) --pts36319

declare @pupfgt table (cmp_id varchar(8)null,cmd_code varchar(8) null,pupident int identity)

--	LOR	PTS# 33517
declare  @temp_hdr table (ivh_hdrnumber int primary key)

--NSUITE-106669 MBR 09/05/17
DECLARE @preRatedDetails TABLE(
	prd_ident  INTEGER IDENTITY,
    cmd_code   VARCHAR(8),
    cmp_id     VARCHAR(8),
    fgt_number INTEGER)
						 
declare @ords table (ord_hdrnumber int,ord_number varchar(12) null)
declare @rowseq table (rs_ident int identity,fgt_number int)
declare @invoiceby varchar(3),@mov int,@ordbillto varchar(8), @ordcarkey int, @firststpnumber int

DECLARE  @dumdate  datetime,     
	@dummy6  varchar(6),     
	@glnum   varchar(32),    
	@suffix_prefix char(1),    
	@sDummyRefType  varchar(6),    
	@sDummyRefNum varchar(30),    
	@ctynmstct varchar(25),    
	@ctycode int,     
	@zipcode        varchar(10),    
	@ordhdrnumber int ,    
	@reftypetocopy varchar(6),    
	@invrefnum varchar(30)  ,
	@MinIvhHdrnumber int,
	@refnumsource char (1),
	@DeductTareWgtFromWgtinInvoice char(1),
	@v_CopyInvDetFromMaster char(1),
	@v_fromorder integer,
	@ordshipper varchar(8),
	@BillOption varchar(60),  --PTS 38823
	@defaultbillingqty CHAR(1), --PTS41488
        @gi_string2 CHAR(1)         --PTS41488
    ,@movnumber int   -- 40257
  ,@FBCRefType varchar(6) --40257
  ,@ivh_billto varchar(8) --40257 
  ,@v_GICHargesMode varchar(20), -- 51331
    @min_ident                     INTEGER,
    @cmp_id                        VARCHAR(8),
    @cmd_code                      VARCHAR(8),
    @fgt_number                    INTEGER
	
--GENERAL INFO MASTER LOOKUP BEGIN
  DECLARE
    @GI_VALUES_TO_LOOKUP TABLE(gi_name VARCHAR(30)
                               PRIMARY KEY);
  DECLARE
    @GIKEY TABLE(gi_name     VARCHAR(30)
                 PRIMARY KEY
               , gi_string1  VARCHAR(60)
               , gi_string2  VARCHAR(60)
               , gi_string3  VARCHAR(60)
               , gi_string4  VARCHAR(60)
               , gi_integer1 INT
               , gi_integer2 INT
               , gi_integer3 INT
               , gi_integer4 INT);
  INSERT INTO @GI_VALUES_TO_LOOKUP
  VALUES
--Replace these lookups with value(s) that match your needs.
  (
    'CopyInvDetFromMaster') , (
    'DeductTareWgtFromWgtinInvoice') , (
    'INVRefnum') , (
    'FrgtReftoInv') , (
    'BillingDistanceOption') , (
    'RefType-Manifest') , (
    'DefaultBillingQty') , (
    'InvDetResequenceCheck');
  INSERT INTO @GIKEY(
    gi_name
  , gi_string1
  , gi_string2
  , gi_string3
  , gi_string4
  , gi_integer1
  , gi_integer2
  , gi_integer3
  , gi_integer4)
  SELECT
    gi_name
  , gi_string1
  , gi_string2
  , gi_string3
  , gi_string4
  , gi_integer1
  , gi_integer2
  , gi_integer3
  , gi_integer4
  FROM
  (
  SELECT
    gvtlu.gi_name
  , g.gi_string1
  , g.gi_string2
  , g.gi_string3
  , g.gi_string4
  , gi_integer1
  , gi_integer2
  , gi_integer3
  , gi_integer4
   --What we're doing here is checking the date of the generalInfo row in case there are multiples.
   --This will order the rows in descending date order with the following exceptions.
   --Future dates are dropped to last priority by moving to less than the apocalypse.
   --Nulls are moved to second to last priority by using the apocalypse.
   --Everything else is ordered descending.
   --We then take the "newest". 
  , ROW_NUMBER() OVER(PARTITION BY gvtlu.gi_name 
                         ORDER BY CASE
                            WHEN g.gi_datein > GETDATE() THEN '1/1/1949'
                            ELSE COALESCE(g.gi_datein , '1/1/1950')
                         END DESC) RN
  FROM
    @GI_VALUES_TO_LOOKUP gvtlu
      LEFT OUTER JOIN
      dbo.generalinfo g ON
    gvtlu.gi_name = g.gi_name
  ) subQuery
  WHERE RN = 1; --   <---This is how we take the top 1.

--GENERAL INFO MASTER LOOKUP END


exec gettmwuser @tmwuser output

/* OBSOLETE  if set to NVO CHARGES sequecne for accessorial charges on new invoice hsoudl be left alone 
select @v_GICHargesMode = upper(COALESCE(gi_string2,'Window')) from generalinfo where gi_name = 'ChargesModeForApp'
If @v_GICHargesMode is null or  @v_GICHargesMode <> 'NVOCHARGES'
   select @v_GICHargesMode = upper(COALESCE(gi_string3,'Window')) from generalinfo where gi_name = 'ChargesModeForApp'
select @v_GICHargesMode = COALESCE(@v_GICHargesMode,'WINDOW')
*/
SELECT @ctynmstct = ''    
SELECT @ctycode = 0    
SELECT @zipcode = '' 
 
if @retrieve_by = 'ORDHDR'
  BEGIN -- invoice by ORDHDR setup (invoice exists for the order)
    IF exists (select 1 from invoicemaster where ord_hdrnumber = @numberparm )
      BEGIN     
         /* invoice was created for more than one order, go to invoicemaster to get the order on the invoice for retrieval */
         select @numberparm = ivm_invoiceordhdrnumber from invoicemaster where ord_hdrnumber = @numberparm
         select @invoiceby = COALESCE(cmp_invoiceby,'ORD') from orderheader join company on ord_billto = cmp_id where ord_hdrnumber = @numberparm
      END   
    ELSE
      IF  exists (select 1 from invoiceheader where ord_hdrnumber = @numberparm)
         /* invoice exists for this order, procede as usual  */
         select @numberparm = @numberparm 
         select @invoiceby = COALESCE(cmp_invoiceby,'ORD') from orderheader join company on ord_billto = cmp_id where ord_hdrnumber = @numberparm
  END    
IF  @retrieve_by = 'ORDNUM'  -- invoice does not exist yet for the order
  BEGIN  --  no invoice exists check to see how the bill to company is invoiced 
     select @invoiceby = COALESCE(cmp_invoiceby,'ORD'),@ordbillto = ord_billto 
       from orderheader 
       join company on ord_billto = cmp_id where ord_hdrnumber = @numberparm
     if @p_prerating = 'Y' select @invoiceby = 'ORD'  --48966
     select @retrieve_by = 'ORDNUM'
     IF @invoiceby = 'MOV'
        BEGIN  -- invoice by move number, no invoice exists
          select @mov = mov_number from orderheader where ord_hdrnumber = @numberparm
          insert into @ords select ord_hdrnumber,ord_number from orderheader where mov_number = @mov
            AND ord_billto = @ordbillto
			
		  SELECT TOP 1 @numberparm = ord_hdrnumber
		    FROM @ords
		  ORDER BY ord_number  -- invoice by move puts the lowest ord_number order on the invoice
		  
          select @ordcarkey = COALESCE(car_key,0) from orderheader where ord_hdrnumber = @numberparm
          select @firststpnumber = (select top 1 stp_number 
                                    from @ords ord
                                    join stops on ord.ord_hdrnumber = stops.ord_hdrnumber
                                    join eventcodetable on stp_event = abbr
                                    where ect_billable = 'Y'  
                                    order by stp_sequence,stp_arrivaldate )
          insert into @rowseq (fgt_number) -- create aritfical sequence number for new invoice using the identity in this temp table
            select fgt_number 
            from @ords ord
            join stops on ord.ord_hdrnumber = stops.ord_hdrnumber
            join freightdetail on stops.stp_number = freightdetail.stp_number
            where stops.stp_number <> @firststpnumber
            order by stp_arrivaldate,fgt_sequence
          
         END -- invoice by move number
     If @invoiceby = 'CON' 
        BEGIN  -- invoice by move number, no invoice exists
          select @mov = mov_number,@consignee = ord_consignee from orderheader where ord_hdrnumber = @numberparm
          insert into @ords select ord_hdrnumber,ord_number from orderheader where mov_number = @mov
            AND ord_billto = @ordbillto
            AND ord_consignee = @consignee
			
		  SELECT TOP 1 @numberparm = ord_hdrnumber 
		    FROM @ords
		  ORDER BY ord_number  -- invoice by move puts the lowest ord_number order on the invoice
         
          select @ordcarkey = COALESCE(car_key,0) from orderheader where ord_hdrnumber = @numberparm
          select @firststpnumber = (select top 1 stp_number from @ords ord
                                    join stops on ord.ord_hdrnumber = stops.ord_hdrnumber
                                    join eventcodetable on stp_event = abbr
                                    where ect_billable = 'Y'  
                                    order by stp_sequence,stp_arrivaldate)
          insert into @rowseq (fgt_number) -- create aritfical sequence number for new invoice using the identity in this temp table
            select fgt_number 
            from @ords ord
            join stops on ord.ord_hdrnumber = stops.ord_hdrnumber
            join freightdetail on stops.stp_number = freightdetail.stp_number
            where stops.stp_number <> @firststpnumber
            order by stp_arrivaldate,fgt_sequence
          
          
         END -- invoice by move number and consignee 
--     ELSE
      If @invoiceby = 'ORD'
         BEGIN  -- invoice is by order , no invoice exists
           insert into @ords select @numberparm,''
           select @mov = mov_number,@ordbillto = ord_billto,@ordcarkey = COALESCE(car_key,0) from orderheader where ord_hdrnumber = @numberparm
           select @firststpnumber = (select top 1 stp_number from stops join eventcodetable on stp_event = abbr
                                    where ord_hdrnumber = @numberparm
                                    and ect_billable = 'Y'  
                                    order by stp_sequence,stp_arrivaldate )
           insert into @rowseq (fgt_number)  -- create aritfical sequence number for new invoice using the identity in this temp table
             select fgt_number from stops join freightdetail on stops.stp_number = freightdetail.stp_number
             where ord_hdrnumber = @numberparm
             and stops.stp_number <> @firststpnumber
             order by stp_sequence,fgt_sequence
           
          END  -- invoice is by order 
  END -- invoice by ORDNUM setup
   


-- vjh 33030
SELECT	@v_CopyInvDetFromMaster = UPPER(LEFT(COALESCE(gi_string1, 'N'), 1))
FROM	@GIKEY WHERE gi_name = 'CopyInvDetFromMaster'
if @v_CopyInvDetFromMaster = 'Y' and @retrieve_by = 'ORDNUM' begin
	select @v_fromorder = om.ord_hdrnumber
	  from orderheader o1 join orderheader om on o1.ord_fromorder = om.ord_number
	  where o1.ord_fromorder is not null
	  and o1.ord_invoicestatus = 'AVL'
	  and om.ord_status  = 'MST'
	  and o1.ord_hdrnumber=@numberparm
	if @v_fromorder is not null
	begin
		exec copy_inv_det_sp @numberparm,  @v_fromorder
	end
end
-- vjh 33030
-- PTS 27449 KWS
SELECT	@DeductTareWgtFromWgtinInvoice = UPPER(LEFT(COALESCE(gi_string1, 'N'), 1))
FROM	@GIKEY WHERE gi_name = 'DeductTareWgtFromWgtinInvoice'
-- PTS 27449 KWS
Select @RefnumSource = Upper(Left(gi_string1,1)) From @GIKEY Where gi_name = 'INVRefnum'  
Select @RefnumSource = COALESCE(@RefnumSource,'S')   
-- If refnumbers to be pulled from freightdetail allow for GI setting specifying which ref type to show  
If @RefnumSource = 'F'    
  Select @reftypetocopy = Upper(gi_string1) from @GIKEY where gi_name='FrgtReftoInv'   
     
Select @reftypetocopy = COALESCE(@reftypetocopy,'NONE')
--PTS 38823 EMK - Get Billing Option
select @BillOption = 
 	    CASE 
		WHEN gi_string1 IS NULL THEN 'Standard'
		WHEN gi_string1 ='' THEN 'Standard'
		ELSE gi_string1
	END
from @GIKEY
WHERE gi_name = 'BillingDistanceOption'
--PTS 38823

  

if (@retrieve_by = 'INVMISC')    
BEGIN
    

	INSERT INTO @temp_hdr
	SELECT ihm_hdrnumber 
	FROM invoiceheader_misc 
	WHERE ihm_misc_number = @stringparm

	If (select count(*) from @temp_hdr) > 0
		INSERT INTO @temp_inv    
		SELECT invoicedetail.ivh_hdrnumber,     
		  invoicedetail.ivd_number,     
		  invoicedetail.ivd_description,     
		  invoicedetail.ivd_quantity,     
		  invoicedetail.ivd_rate,     
		  invoicedetail.ivd_charge,     
		  COALESCE(invoicedetail.ivd_taxable1,chargetype.cht_taxtable1), --invoicedetail.ivd_taxable1, 
		  COALESCE(invoicedetail.ivd_taxable2,chargetype.cht_taxtable2), --invoicedetail.ivd_taxable2,     
		  COALESCE(invoicedetail.ivd_taxable3,chargetype.cht_taxtable3), --invoicedetail.ivd_taxable3,     
		  COALESCE(invoicedetail.ivd_taxable4,chargetype.cht_taxtable4), --invoicedetail.ivd_taxable4,     
		  invoicedetail.ivd_unit,     
		  invoicedetail.cur_code,     
		  invoicedetail.ivd_currencydate,     
		  invoicedetail.ivd_glnum,     
		  invoicedetail.ord_hdrnumber,     
		  --invoicedetail.ivd_type,     -- NQIAO PTS 59136 <START>  
		  ivd_type = Case COALESCE(invoicedetail.ivd_type, 'NULL')
						When 'NULL' Then (
							Case COALESCE(invoicedetail.stp_number, 0)
								When 0 Then 'LI'
								Else 'DRP' End)
						Else invoicedetail.ivd_type End,		-- NQIAO PTS 59136 <END>
		  invoicedetail.ivd_rateunit,     
		  ivd_billto = CASE COALESCE(invoicedetail.ivd_billto, 'UNKNOWN') 
						  WHEN 'UNKNOWN' THEN invoiceheader.ivh_billto  
						  ELSE invoicedetail.ivd_billto 
					   END,     
		  invoicedetail.ivd_itemquantity,     
		  invoicedetail.ivd_subtotalptr,     
		  invoicedetail.ivd_sequence,     
		  invoicedetail.ivd_invoicestatus,     
		  invoicedetail.mfh_hdrnumber,     
		  invoicedetail.ivd_refnum,     
		  invoicedetail.cmp_id,     
		  invoicedetail.ivd_distance,     
		  invoicedetail.ivd_distunit,     
		  invoicedetail.ivd_wgt,     
		  invoicedetail.ivd_wgtunit,     
		  invoicedetail.ivd_count,     
		  invoicedetail.evt_number,     
		  invoicedetail.ivd_reftype,     
		  invoicedetail.ivd_volume,     
		  invoicedetail.ivd_volunit,     
		  invoicedetail.ivd_orig_cmpid,     
		  invoicedetail.ivd_countunit,     
		  invoicedetail.cht_itemcode,     
		  invoicedetail.cmd_code,     
		  chargetype.cht_basis,      
		  0 lowtemp,       
		  0 hightemp,     
		  invoicedetail.ivd_sign,     
		  invoicedetail.ivd_length,     
		  invoicedetail.ivd_lengthunit,     
		  invoicedetail.ivd_width,     
		  invoicedetail.ivd_widthunit,     
		  invoicedetail.ivd_height,     
		  invoicedetail.ivd_heightunit ,    
		  chargetype.cht_primary,     
		  invoicedetail.stp_number,    
		  invoicedetail.cht_basisunit,    
		  invoicedetail.ivd_remark,    
		  invoicedetail.tar_number,    
		  invoicedetail.tar_tariffnumber,    
		  invoicedetail.tar_tariffitem,    
		  ' ',    
		  ' ',    
		  invoicedetail.ivd_fromord,     
		  invoicedetail.cht_rollintolh,    
		  @ctynmstct cty_nmstct,    
		  @ctycode stp_city,    
		  @ctycode origin_city,     
		  @zipcode stp_zipcode,     
		  @zipcode origin_zipcode ,    
		  invoicedetail.fgt_number,    
		  fgt_ratingquantity = ivd_quantity,     
		  fgt_ratingunit = ivd_unit,    
		  ivd_quantity_type = COALESCE(ivd_quantity_type,0),    
		  invoicedetail.cht_class,    
		  '',   
		  '',    
		  ivd_mileagetable,    
		  ivd_charge_type = COALESCE(ivd_charge_type,0),    
		  0,    
		  @trlrentcht trlrentcht,    
		  ivd_trl_rent,    
		  ivd_trl_rent_start,    
		  ivd_trl_rent_end,    
		  COALESCE(ivd_rate_type,0) ivd_rate_type,    
		  cmp_geoloc = '',    
		  invoicedetail.cht_lh_min,    
		  invoicedetail.cht_lh_rev,    
		  invoicedetail.cht_lh_stl,    
		  invoicedetail.cht_lh_prn,    
		  invoicedetail.cht_lh_rpt,  
		  invoicedetail.ivd_paylgh_number,  
		  invoicedetail.ivd_tariff_type,  
		  ivd_taxid = COALESCE (invoicedetail.ivd_taxid, ''),  
		  cht_gp_Tax = COALESCE (chargetype.gp_Tax, 0),  
		  invoicedetail.ivd_ordered_volume ,  
		  invoicedetail.ivd_ordered_loadingmeters ,    
		  invoicedetail.ivd_ordered_count,  
		  invoicedetail.ivd_ordered_weight,  
		  invoicedetail.ivd_loadingmeters,  
		  invoicedetail.ivd_loadingmeters_unit  ,
		  invoicedetail.ivd_revtype1,
		  'N',
		  'N',
		  invoicedetail.ivd_tollcost,
		  ivd_ARTaxAuth = COALESCE(invoicedetail.ivd_ARTaxAuth,'UNK'),	-- PTS 35555 - EMK
		  commodity.cmd_class, -- pts 36316 os
          	  fgt_shipper = COALESCE(freightdetail.fgt_shipper,'UNKNOWN'), 
		  invoicedetail.ivd_tax_basis, --PTS 38778 EMK

		  ivd_actual_quantity,   -- PTS 38773 
		  ivd_actual_unit,		 -- PTS 38773		
		  fgt_actual_quantity,   -- PTS 38773 
		  fgt_actual_unit,       -- PTS 38773 
		  fgt_billable_quantity, -- PTS 38773 
		  fgt_billable_unit ,     -- PTS 38773 
          COALESCE(invoicedetail.fgt_supplier,'UNKNOWN'),	
		  ivd_loaded_distance, 	--PTS 38823
		  ivd_empty_distance,   --PTS 38823
	 COALESCE (ivd_paid_indicator, 'U'), --PTS 41325
                  ivd_paid_amount, --PTS 41325
		  ivd_leaseassetid
		,ivd_maskFromRating  = COALESCE(invoicedetail.ivd_MaskFromRating,'N')  --40257
		,ivd_car_key = COALESCE(ivd_car_key,0)  -- key to companyaddress for alt BT address --40257
		,ivh_carkey = COALESCE(invoiceheader.car_key,0),									--40257
		 COALESCE(invoicedetail.ivd_showas_cmpid, 'UNKNOWN'),		--PTS 42289
		 COALESCE(ivd_post_invoice, 'N'),
         ivd_billable_flag,
         ivd_ord_number,  --43837
		 invoicedetail.dbsd_id_tariff, /*PTS 52067*/
		 invoicedetail.ivd_allocated_ivd_number,  --PTS51296
		 invoicedetail.ivd_allocation_type,       --PTS51296
		 COALESCE(invoicedetail.ivd_allocated_qty, 0),	  --PTS51296
		 COALESCE(invoicedetail.ivd_allocated_rate, 0),	  --PTS51296
		 COALESCE(invoicedetail.ivd_allocated_charge, 0),	  --PTS51296
		 COALESCE(invoicedetail.ivd_reconcile_tariff, 0),	  --PTS53514
		 COALESCE(invoicedetail.ivd_description_type, 0),	  --PTS 56312
		 'N' cht_tax1,
		 'N' cht_tax2,
		 'N' cht_tax3,
		 'N' cht_tax4,
		 'N' cht_tax5,
		 'N' cht_tax6,
		 'N' cht_tax7,
		 'N' cht_tax8,
		 'N' cht_tax9,
		 'N' cht_tax10,
		 COALESCE(invoicedetail.ivd_rated_qty,0), -- PTS 58737 SGB
		 COALESCE(invoicedetail.ivd_rated_rate,0),	-- PTS 58737 SGB
		 COALESCE(invoicedetail.dbst_rollinto_tar,0),	-- PTS 58737 SGB
		 invoicedetail.ivd_customer_char1   -- 63734		 
		FROM invoicedetail
			join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber --40257
			Left Outer Join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			Join @temp_hdr t on invoicedetail.ivh_hdrnumber = t.ivh_hdrnumber
			left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code --pts 36319 os 
            left outer join freightdetail on invoicedetail.fgt_number = freightdetail.fgt_number and invoicedetail.fgt_number > 0 --41289
	Else
		select @retrieve_by = 'INVHDR'
END   
--	LOR
  
if (@retrieve_by = 'INVHDR')    
BEGIN  
    --os 37762
  
   INSERT INTO @temp_inv_collect
   SELECT ihm_hdrnumber 
   FROM invoiceheader_misc 
   WHERE ihm_misc_number like 'S' + CAST(@numberparm AS varchar(12)) + '%'
--37762 end 
	  
	SELECT @ordhdrnumber = ord_hdrnumber    
	FROM   invoiceheader    
	WHERE invoiceheader.ivh_hdrnumber = @numberparm    
	    
	IF @ordhdrnumber IS NOT NULL and @ordhdrnumber > 0    
	BEGIN    
		SELECT @retrieve_by = 'ORDHDR'    
		SELECT @numberparm = @ordhdrnumber    
	END    
	ELSE
		
		-- 41289
		if not exists (select ivh_hdrnumber from @temp_inv_collect where ivh_hdrnumber = @numberparm)
		begin
			INSERT INTO @temp_inv_collect values(@numberparm) 
		end
		-- 41289 End
    
		INSERT INTO @temp_inv    
		SELECT invoicedetail.ivh_hdrnumber,     
			  invoicedetail.ivd_number,     
			  invoicedetail.ivd_description,     
			  invoicedetail.ivd_quantity,     
			  invoicedetail.ivd_rate,     
			  invoicedetail.ivd_charge,     
			  COALESCE(invoicedetail.ivd_taxable1,chargetype.cht_taxtable1), --invoicedetail.ivd_taxable1, 
		      COALESCE(invoicedetail.ivd_taxable2,chargetype.cht_taxtable2), --invoicedetail.ivd_taxable2,     
		      COALESCE(invoicedetail.ivd_taxable3,chargetype.cht_taxtable3), --invoicedetail.ivd_taxable3,     
		      COALESCE(invoicedetail.ivd_taxable4,chargetype.cht_taxtable4), --invoicedetail.ivd_taxable4,       
			  invoicedetail.ivd_unit,     
			  invoicedetail.cur_code,     
			  invoicedetail.ivd_currencydate,     
			  invoicedetail.ivd_glnum,     
			  invoicedetail.ord_hdrnumber,     
			   --invoicedetail.ivd_type,				-- NQIAO PTS 59136 <START>  
			  ivd_type = Case COALESCE(invoicedetail.ivd_type, 'NULL')
							When 'NULL' Then (
								Case COALESCE(invoicedetail.stp_number, 0)
									When 0 Then 'LI'
									Else 'DRP' End)
							Else invoicedetail.ivd_type End,		-- NQIAO PTS 59136 <END>    
			  invoicedetail.ivd_rateunit,     
			  ivd_billto = CASE COALESCE(invoicedetail.ivd_billto,'UNKNOWN') 
                              WHEN 'UNKNOWN' THEN invoiceheader.ivh_billto
                              WHEN '' THEN invoiceheader.ivh_billto   
                              ELSE invoicedetail.ivd_billto 
						   END,       
 			  invoicedetail.ivd_itemquantity,     
			  invoicedetail.ivd_subtotalptr,     
			  invoicedetail.ivd_sequence,     
			  invoicedetail.ivd_invoicestatus,     
			  invoicedetail.mfh_hdrnumber,     
			  invoicedetail.ivd_refnum,     
			  invoicedetail.cmp_id,     
			  invoicedetail.ivd_distance,     
			  invoicedetail.ivd_distunit,     
			  invoicedetail.ivd_wgt,     
			  invoicedetail.ivd_wgtunit,     
			  invoicedetail.ivd_count,     
			  invoicedetail.evt_number,     
			  invoicedetail.ivd_reftype,     
			  invoicedetail.ivd_volume,     
			  invoicedetail.ivd_volunit,     
			  invoicedetail.ivd_orig_cmpid,     
			  invoicedetail.ivd_countunit,     
			  invoicedetail.cht_itemcode,     
			  invoicedetail.cmd_code,     
			  chargetype.cht_basis,      
			  0 lowtemp,       
			  0 hightemp,     
			  invoicedetail.ivd_sign,     
			  invoicedetail.ivd_length,     
			  invoicedetail.ivd_lengthunit,     
			  invoicedetail.ivd_width,     
			  invoicedetail.ivd_widthunit,     
			  invoicedetail.ivd_height,     
			  invoicedetail.ivd_heightunit ,    
			  chargetype.cht_primary,     
			  invoicedetail.stp_number,    
			  invoicedetail.cht_basisunit,    
			  invoicedetail.ivd_remark,    
			  invoicedetail.tar_number,    
			  invoicedetail.tar_tariffnumber,    
			  invoicedetail.tar_tariffitem,    
			  ' ',    
			  ' ',    
			  invoicedetail.ivd_fromord,     
			--  LOR      chargetype.cht_rollintolh,    
			  invoicedetail.cht_rollintolh,    
			  @ctynmstct cty_nmstct,    
			  @ctycode stp_city,    
			  @ctycode origin_city,     
							@zipcode stp_zipcode,     
							@zipcode origin_zipcode ,    
			  invoicedetail.fgt_number,    
			  fgt_ratingquantity = ivd_quantity,     
			  fgt_ratingunit = ivd_unit,    
			  ivd_quantity_type = COALESCE(ivd_quantity_type,0),    
			  invoicedetail.cht_class,    
			  '',   
			  '',    
			  ivd_mileagetable,    
			  ivd_charge_type = COALESCE(ivd_charge_type,0),    
			  0,    
			  @trlrentcht trlrentcht,    
			  ivd_trl_rent,    
			  ivd_trl_rent_start,    
			  ivd_trl_rent_end,    
			  COALESCE(ivd_rate_type,0) ivd_rate_type,    
			  cmp_geoloc = '',    
			  invoicedetail.cht_lh_min,    
			  invoicedetail.cht_lh_rev,    
			  invoicedetail.cht_lh_stl,    
			  invoicedetail.cht_lh_prn,    
			  invoicedetail.cht_lh_rpt,  
			  invoicedetail.ivd_paylgh_number,  
			 invoicedetail.ivd_tariff_type,  
			  ivd_taxid = COALESCE (invoicedetail.ivd_taxid, ''),  
			  cht_gp_Tax = COALESCE (chargetype.gp_Tax, 0),  
			  invoicedetail.ivd_ordered_volume ,  
			  invoicedetail.ivd_ordered_loadingmeters ,    
			  invoicedetail.ivd_ordered_count,  
			  invoicedetail.ivd_ordered_weight,  
			  invoicedetail.ivd_loadingmeters,  
			  invoicedetail.ivd_loadingmeters_unit  ,
			  invoicedetail.ivd_revtype1,
			  'N',
			  'N',
			  invoicedetail.ivd_tollcost, 
		 	  ivd_ARTaxAuth = COALESCE(invoicedetail.ivd_ARTaxAuth,'UNK'),	-- PTS 35555 - EMK
			  commodity.cmd_class , -- pts 36316 os
			  fgt_shipper = COALESCE(freightdetail.fgt_shipper,'UNKNOWN'),
			  invoicedetail.ivd_tax_basis,
			  ivd_actual_quantity,   -- PTS 38773 
			  ivd_actual_unit,		 -- PTS 38773		
			  fgt_actual_quantity,   -- PTS 38773
			  fgt_actual_unit,       -- PTS 38773 
			  fgt_billable_quantity, -- PTS 38773 
			  fgt_billable_unit,      -- PTS 38773 
              COALESCE(invoicedetail.fgt_supplier,'UNKNOWN') fgt_supplier,
			  ivd_loaded_distance, 	--PTS 38823
		  	  ivd_empty_distance ,	 
			  COALESCE (ivd_paid_indicator, 'U'), --PTS 41325
              ivd_paid_amount, --PTS 41325
			  ivd_leaseassetid,
			  ivd_maskFromRating  = COALESCE(invoicedetail.ivd_MaskFromRating,'N'), --40259
			  ivd_car_key = COALESCE(ivd_car_key,0),  -- key to companyaddress for alt BT address  --40259
			  ivh_carkey = COALESCE(invoiceheader.car_key,0),--40259 
			  ivd_showas_cmpid = COALESCE(invoicedetail.ivd_showas_cmpid, 'UNKNOWN'),  --PTS 42289
			  ivd_post_invoice = COALESCE(invoicedetail.ivd_post_invoice, 'N'),
 --PTS 38778 EMK
            ivd_billable_flag,
              ivd_ord_number,
			invoicedetail.dbsd_id_tariff, /*PTS 52067*/
			invoicedetail.ivd_allocated_ivd_number,   --PTS51296
			invoicedetail.ivd_allocation_type,        --PTS51296
			COALESCE(invoicedetail.ivd_allocated_qty, 0),    --PTS51296
		 	COALESCE(invoicedetail.ivd_allocated_rate, 0),   --PTS51296
		 	COALESCE(invoicedetail.ivd_allocated_charge, 0),  --PTS51296
		 	COALESCE(invoicedetail.ivd_reconcile_tariff, 0), --PTS 53514
		 	COALESCE(invoicedetail.ivd_description_type, 0),	  --PTS 56312
			 'N' cht_tax1,
			 'N' cht_tax2,
			 'N' cht_tax3,
			 'N' cht_tax4,
			 'N' cht_tax5,
			 'N' cht_tax6,
			 'N' cht_tax7,
			 'N' cht_tax8,
			 'N' cht_tax9,
			 'N' cht_tax10,
		 	COALESCE(invoicedetail.ivd_rated_qty,0), -- PTS 58737 SGB
			COALESCE(invoicedetail.ivd_rated_rate,0),	-- PTS 58737 SGB
			COALESCE(invoicedetail.dbst_rollinto_tar,0),	-- PTS 58737 SGB
			invoicedetail.ivd_customer_char1   -- 63734			 
		FROM invoicedetail
			Left Outer Join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
			left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code --pts 36319 os
			Join @temp_inv_collect tc on invoicedetail.ivh_hdrnumber = tc.ivh_hdrnumber --pts 41289	
		    left outer join freightdetail on invoicedetail.fgt_number = freightdetail.fgt_number 
			join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber  --PTS 40259
	   -- Commented out following lines for PTS 41289
	   -- WHERE invoicedetail.ivh_hdrnumber = @numberparm 
	   -- or invoicedetail.ivh_hdrnumber in (select ivh_hdrnumber from @temp_inv_collect) --os 37762 
	   -- End PTS 41289
END    
    
if (@retrieve_by = 'ORDHDR')  /* invoice exists for order */

	INSERT INTO @temp_inv    
	SELECT invoicedetail.ivh_hdrnumber,     
	  invoicedetail.ivd_number,     
	  invoicedetail.ivd_description,     
	  invoicedetail.ivd_quantity,     
	  invoicedetail.ivd_rate,     
	  invoicedetail.ivd_charge,     
	  COALESCE(invoicedetail.ivd_taxable1,chargetype.cht_taxtable1), --invoicedetail.ivd_taxable1, 
	  COALESCE(invoicedetail.ivd_taxable2,chargetype.cht_taxtable2), --invoicedetail.ivd_taxable2,     
	  COALESCE(invoicedetail.ivd_taxable3,chargetype.cht_taxtable3), --invoicedetail.ivd_taxable3,     
	  COALESCE(invoicedetail.ivd_taxable4,chargetype.cht_taxtable4), --invoicedetail.ivd_taxable4,   
	  invoicedetail.ivd_unit,     
	  invoicedetail.cur_code,     
	  invoicedetail.ivd_currencydate,     
	  invoicedetail.ivd_glnum,     
	  invoicedetail.ord_hdrnumber,     
	  --invoicedetail.ivd_type,				-- NQIAO PTS 59136 <START>  
	  ivd_type = Case COALESCE(invoicedetail.ivd_type, 'NULL')
					When 'NULL' Then (
						Case COALESCE(invoicedetail.stp_number, 0)
							When 0 Then 'LI'
							Else 'DRP' End)
					Else invoicedetail.ivd_type End,		-- NQIAO PTS 59136 <END>  
	  invoicedetail.ivd_rateunit,     
	  ivd_billto = CASE COALESCE(invoicedetail.ivd_billto, 'UNKNOWN') 
					  WHEN 'UNKNOWN' THEN invoiceheader.ivh_billto
                      WHEN '' THEN invoiceheader.ivh_billto   
					  ELSE invoicedetail.ivd_billto 
				   END,     
	  invoicedetail.ivd_itemquantity,     
	  invoicedetail.ivd_subtotalptr,     
	  invoicedetail.ivd_sequence,     
	  invoicedetail.ivd_invoicestatus,     
	  invoicedetail.mfh_hdrnumber,     
	  invoicedetail.ivd_refnum,     
	  invoicedetail.cmp_id,     
	  invoicedetail.ivd_distance,     
	  invoicedetail.ivd_distunit,     
	  invoicedetail.ivd_wgt,     
	  invoicedetail.ivd_wgtunit,     
	  invoicedetail.ivd_count,     
	  invoicedetail.evt_number,     
	  invoicedetail.ivd_reftype,     
	  invoicedetail.ivd_volume,     
	  invoicedetail.ivd_volunit,     
	  invoicedetail.ivd_orig_cmpid,     
	  invoicedetail.ivd_countunit,     
	  invoicedetail.cht_itemcode,     
	  invoicedetail.cmd_code,     
	  chargetype.cht_basis,      
	  0 lowtemp,       
	  0 hightemp,     
	  invoicedetail.ivd_sign,     
	  invoicedetail.ivd_length,     
	  invoicedetail.ivd_lengthunit,     
	  invoicedetail.ivd_width,     
	  invoicedetail.ivd_widthunit,     
	  invoicedetail.ivd_height,     
	  invoicedetail.ivd_heightunit ,    
	  chargetype.cht_primary,     
	  invoicedetail.stp_number,    
	  invoicedetail.cht_basisunit,    
	  invoicedetail.ivd_remark,    
	  invoicedetail.tar_number,    
	  invoicedetail.tar_tariffnumber,    
	  invoicedetail.tar_tariffitem,    
	  ' ',    
	  ' ',    
	  invoicedetail.ivd_fromord,     
	--  LOR      chargetype.cht_rollintolh,    
	  invoicedetail.cht_rollintolh,    
	  @ctynmstct cty_nmstct,    
	  @ctycode stp_city,    
	  @ctycode origin_city,     
					@zipcode stp_zipcode,     
					@zipcode origin_zipcode,    
	  invoicedetail.fgt_number,    
	  fgt_ratingquantity = ivd_quantity,     
	  fgt_ratingunit = ivd_unit,    
	  ivd_quantity_type = COALESCE(ivd_quantity_type,0),    
	  invoicedetail.cht_class,    
	  '',  
	  '',    
	  ivd_mileagetable,    
	  ivd_charge_type = COALESCE(ivd_charge_type,0),    
	  0,    
	  @trlrentcht trlrentcht,    
	  ivd_trl_rent,    
	  ivd_trl_rent_start,    
	  ivd_trl_rent_end,    
	  COALESCE(ivd_rate_type,0) ivd_rate_type,    
	  cmp_geoloc = '',    
	  invoicedetail.cht_lh_min,    
	  invoicedetail.cht_lh_rev,    
	  invoicedetail.cht_lh_stl,    
	  invoicedetail.cht_lh_prn,    
	  invoicedetail.cht_lh_rpt,  
	  invoicedetail.ivd_paylgh_number,  
	  invoicedetail.ivd_tariff_type,  
	  ivd_taxid = COALESCE (invoicedetail.ivd_taxid, ''),  
	  cht_gp_Tax = COALESCE (chargetype.gp_Tax, 0),  
	  invoicedetail.ivd_ordered_volume ,  
	  invoicedetail.ivd_ordered_loadingmeters ,    
	  invoicedetail.ivd_ordered_count,  
	  invoicedetail.ivd_ordered_weight,  
	  invoicedetail.ivd_loadingmeters,  
	  invoicedetail.ivd_loadingmeters_unit ,  
	  invoicedetail.ivd_revtype1,   
	  'N' ivd_hide,
	  'N' usr,
	  invoicedetail.ivd_tollcost, 
	  ivd_ARTaxAuth = COALESCE(invoicedetail.ivd_ARTaxAuth,'UNK'), -- PTS 35555 - EMK
	  commodity.cmd_class, -- pts 36316 os
      	  fgt_shipper = COALESCE(freightdetail.fgt_shipper,'UNKNOWN'),
	  invoicedetail.ivd_tax_basis, --PTS 38778 EMK
	  
	--CASE WHEN invoicedetail.ivd_actual_quantity > 0 THEN invoicedetail.ivd_actual_quantity
    CASE WHEN invoicedetail.ivd_actual_quantity <> 0 THEN invoicedetail.ivd_actual_quantity --43782
           ELSE freightdetail.fgt_actual_quantity
		   END ivd_actual_quantity, -- PTS 38773 

	 -- this (below) is not a mistake - if qty > 0 use its UOM.	
	 -- CASE WHEN invoicedetail.ivd_actual_quantity > 0 THEN invoicedetail.ivd_actual_unit
        CASE WHEN invoicedetail.ivd_actual_quantity <> 0 THEN invoicedetail.ivd_actual_unit --PTS 43782    
           ELSE freightdetail.fgt_actual_unit
		   END ivd_actual_unit,  -- PTS 38773 	
           
		  fgt_actual_quantity,   -- PTS 38773 
		  fgt_actual_unit,       -- PTS 38773 
		  fgt_billable_quantity, -- PTS 38773 
		  fgt_billable_unit,      -- PTS 38773 	
           COALESCE(invoicedetail.fgt_supplier,'UNKNOWN') fgt_supplier,
		  ivd_loaded_distance, 	--PTS 38823
		  ivd_empty_distance,   --PTS 38823  
	 COALESCE (ivd_paid_indicator, 'U'), --PTS 41325
                  ivd_paid_amount, --PTS 41325
		  ivd_leaseassetid,		--PTS 40259	
		  ivd_maskFromRating  = COALESCE(invoicedetail.ivd_MaskFromRating,'N'),--PTS 40259	
		  ivd_car_key = COALESCE(ivd_car_key,0),--PTS 40259	
          ivh_carkey = COALESCE(invoiceheader.car_key,0), --PTS 40259	
		  ivd_showas_cmpid = COALESCE(invoicedetail.ivd_showas_cmpid, 'UNKNOWN'),  --PTS 42289
		  COALESCE(ivd_post_invoice, 'N'),
         ivd_billable_flag,
         COALESCE(ivd_ord_number,invoiceheader.ord_number),
		invoicedetail.dbsd_id_tariff, /*PTS 52067*/
		invoicedetail.ivd_allocated_ivd_number,  --PTS51296
		invoicedetail.ivd_allocation_type,       --PTS51296
		COALESCE(invoicedetail.ivd_allocated_qty, 0),	 --PTS51296
		COALESCE(invoicedetail.ivd_allocated_rate, 0),	 --PTS51296
		COALESCE(invoicedetail.ivd_allocated_charge, 0),	 --PTS51296
		COALESCE(invoicedetail.ivd_reconcile_tariff, 0), --PTS 53514
		COALESCE(invoicedetail.ivd_description_type, 0),	  --PTS 56312		
		 'N' cht_tax1,
		 'N' cht_tax2,
		 'N' cht_tax3,
		 'N' cht_tax4,
		 'N' cht_tax5,
		 'N' cht_tax6,
		 'N' cht_tax7,
		 'N' cht_tax8,
		 'N' cht_tax9,
		 'N' cht_tax10,
		COALESCE(invoicedetail.ivd_rated_qty,0), -- PTS 58737 SGB
		COALESCE(invoicedetail.ivd_rated_rate,0),	-- PTS 58737 SGB		
		COALESCE(invoicedetail.dbst_rollinto_tar,0),	-- PTS 58737 SGB
		invoicedetail.ivd_customer_char1   -- 63734		 
	FROM invoicedetail
		Left Outer Join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
		left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code --pts 36319 os
        left outer join freightdetail on invoicedetail.fgt_number = freightdetail.fgt_number
		left outer join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber  --PTS 40259
	WHERE (invoicedetail.ord_hdrnumber = @numberparm) and 
			invoicedetail.ivh_hdrnumber > 0  

    
-- RETURNS INVOICE DETAILS FROM STOPS - CREATES NEW INVOICE */    
-- PTS #2890 - MLS added 3rd union to pickup non pup/drp billable events */    
    
-- PTS #3149 - MLS 10/17/97 Do not check to see if the event is    billable.  For non billable stops the ord_hdrnumber in the    
-- stops table will be zero.      
    
-- PTS #2980 - ILB Modified the WHERE CLAUSE in the third select.Removed the join freightDetail.stp_number = Stops.stp_number    
-- and created two dummy fields for the freightdetail ref_type and ref_num. The Dummy fields will replace the actual freightDetail    
-- columns to keep the number of columns selected consistent for the UNION to execute properly.       
    
if (@retrieve_by = 'ORDNUM') /* first time retrieve for an order invoice does nto exist */  
BEGIN 

  -- code at top populated a table @ords with the order(s) to be on this invoice. If aggregate invoicing is done
  -- the invoice will have the lowest ord_hdrnumber and its ord_number on the invoice  
  -- if retrieving for rebill, must retrieve manual accessorials for the first invoice only   
  Select @MinIvhHdrnumber = Min(ivh_hdrnumber) From invoiceheader where ord_hdrnumber = @numberparm  
  Select @MinIvhHdrnumber = COALESCE(@MinIvhHdrnumber,0)    
  --  if exists ( select * from generalinfo where gi_name = 'INVREFNUM' and gi_string1 = 'FREIGHT') 
    If @RefnumSource <> 'M'   -- new ref num source          
   
	INSERT INTO @temp_inv    
	SELECT     
		0 ivh_hdrnumber,     
		0 ivd_number,    
		ivd_description =     
		CASE stops.stp_type    
		WHEN 'PUP' THEN COALESCE(freightdetail.fgt_description,'UNKNOWN')    
		WHEN 'DRP' THEN COALESCE(freightdetail.fgt_description,'UNKNOWN')    
		ELSE COALESCE((SELECT name FROM eventcodetable where abbr = stops.stp_event),'')    
		END,    
		COALESCE(freightdetail.fgt_quantity,0) ivd_quantity,     
		COALESCE(freightdetail.fgt_rate,0.0) ivd_rate,     
		COALESCE(freightdetail.fgt_charge,0.0) ivd_charge,      
		commodity.cmd_taxtable1 ivd_taxable1,    
		commodity.cmd_taxtable2 ivd_taxable2,     
		commodity.cmd_taxtable3 ivd_taxable3,     
		commodity.cmd_taxtable4 ivd_taxable4,     
		COALESCE(freightdetail.fgt_unit,'UNK') ivd_unit,     
		@dummy6 cur_code,     
		@dumdate currencydate,     
		@glnum ivd_glnum,      
		@numberparm,  -- 43837  stops.ord_hdrnumber,
		-- stops.stp_type, -- JD 24305 replace with case statement    
		Case stops.stp_type WHEN 'PUP' THEN 'PUP' WHEN 'DRP' THEN 'DRP' ELSE 'DRP' END, -- JD 24305     
		COALESCE(freightdetail.fgt_rateunit,'UNK') shp_rateunit,     
		-- @dummy6 shp_billto,   
		ivd_billto = @ordbillto, --(Select ord_billto From orderheader h Where h.ord_hdrnumber = @numberparm),   
		0 ivd_itemquantity,     
		0 ivd_subtotalptr,
/*      
		-- PTS 23628 -- BL (start)
		--  (stops.stp_sequence * 30 + freightdetail.fgt_sequence),      
		(Select Count(*)
				 From stops s2, freightdetail f2
				 Where s2.stp_number = f2.stp_number
			and (s2.stp_sequence * 1000 + f2.fgt_sequence) <= (stops.stp_sequence * 1000 + freightdetail.fgt_sequence)
			and s2.ord_hdrnumber = @numberparm) As RowNum,
		-- PTS 23628 -- BL (end)
*/
        (rowseq.rs_ident + 5) as RowNum, -- allow for non billable stops at front
		@dummy6 shp_invoicestatus,     
					-- JET - 6/19/00 - PTS #8263, changed mfh_number to mov_number    
		stops.mov_number,     
		--freightdetail.fgt_refnum, 
		ivd_refnum = Case @RefnumSource When 'F' Then freightdetail.fgt_refnum
										When 'I' Then ''		--69445 there is no other place to input ivd_refnum, initialize new inv to blank
										Else stops.stp_refnum End,                 
		stops.cmp_id,     
		ivd_distance = Case freightdetail.fgt_sequence When 1 Then stops.stp_ord_mileage else 0 end,     
		'MIL' ivd_distunit,
		-- PTS 27449 KWS
		ivd_wgt = COALESCE(freightdetail.fgt_weight,0) - (CASE @DeductTareWgtFromWgtinInvoice WHEN 'Y' THEN COALESCE(freightdetail.tare_weight,0) ELSE 0 END),
		-- PTS 27449 KWS
		COALESCE(freightdetail.fgt_weightunit,'LBS') ivd_wgtunit,     
		COALESCE(freightdetail.fgt_count,0) ivd_count,     
		event.evt_number,     
		--freightdetail.fgt_reftype,
		ivd_reftype = Case @RefnumSource When 'F' Then freightdetail.fgt_reftype Else stops.stp_reftype End,            
		COALESCE(freightdetail.fgt_volume,0) ivd_volume,     
		COALESCE(freightdetail.fgt_volumeunit,'CUB') ivd_volunit,     
		stops.cmp_id shp_originpoint,     
		COALESCE(freightdetail.fgt_countunit,'PCS') ivd_countunit,     
					-- JET - 2/3/99 - PTS#4702    
		-- freightdetail.cht_itemcode cht_itemcode,      
					COALESCE(freightdetail.cht_itemcode, 'UNK') cht_itemcode,    
		COALESCE(freightdetail.cmd_code,'UNKNOWN') cmd_code,     
		'DEL' cht_basis,     
		freightdetail.fgt_lowtemp,     
		freightdetail.fgt_hitemp,     
		1 ivd_sign,    
		--  replacing fgt length,width or height with ord values moved from below (see 18529)
		--DPH PTS 18529 7/13/04 Only take the header (if larger) if it is rate by TOTAL   
		ivd_length = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_length,0) > COALESCE(freightdetail.fgt_length,0) 
				Then ord_length Else COALESCE(freightdetail.fgt_length,0) End) 
				Else COALESCE(freightdetail.fgt_length,0) End,
		   
		ivd_lengthunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_length,0) > COALESCE(freightdetail.fgt_length,0) 
				Then COALESCE(ord_lengthunit,'UNK') Else COALESCE(freightdetail.fgt_lengthunit,'UNK') End) 
				Else COALESCE(freightdetail.fgt_lengthunit,'UNK') End,       

		ivd_width = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_width,0) > COALESCE(fgt_width,0) 
				Then COALESCE(ord_width,0) Else COALESCE(freightdetail.fgt_width,0) End) 
				Else COALESCE(freightdetail.fgt_width,0) End,       

		ivd_widthunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_width,0) > COALESCE(fgt_width,0) 
				Then COALESCE(ord_widthunit,'UNK') Else COALESCE(freightdetail.fgt_widthunit,'UNK') End) 
				Else COALESCE(freightdetail.fgt_widthunit,'UNK') End,        

		ivd_height = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_height,0) > COALESCE(fgt_height,0) 
				Then COALESCE(ord_height,0) Else COALESCE(freightdetail.fgt_height,0) End) 
				Else COALESCE(freightdetail.fgt_height,0) End,      

		ivd_heightunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_height,0) > COALESCE(fgt_height,0) 
				Then COALESCE(ord_heightunit,'UNK') Else COALESCE(freightdetail.fgt_heightunit,'UNK') End) 
				Else COALESCE(freightdetail.fgt_heightunit,'UNK') End,    
		--  ivd_length = freightdetail.fgt_length,
		--  ivd_lengthunit = freightdetail.fgt_lengthunit,
		--  ivd_width = freightdetail.fgt_width,  
		--  ivd_widthunit = freightdetail.fgt_widthunit,
		--  ivd_height = freightdetail.fgt_height,
		--  ivd_heightunit = freightdetail.fgt_heightunit,   
		'Y' cht_primary,     
		stops.stp_number,     
		COALESCE(freightdetail.cht_basisunit,'UNK') cht_basisunit,    
		'' ivd_remark,    
		freightdetail.tar_number,    
		freightdetail.tar_tariffnumber,    
		freightdetail.tar_tariffitem,    
		' ',    
		' ',    
		' ',     
					0 cht_rollintolh,    
		@ctynmstct cty_nmstct,    
		@ctycode stp_city,    
		@ctycode origin_city,     
					@zipcode stp_zipcode,     
					@zipcode origin_zipcode,    
		freightdetail.fgt_number,    
		fgt_ratingquantity = COALESCE(freightdetail.fgt_ratingquantity,freightdetail.fgt_quantity),    
		fgt_ratingunit = COALESCE(freightdetail.fgt_ratingunit,freightdetail.fgt_unit),    
		ivd_quantity_type = COALESCE(freightdetail.fgt_quantity_type,0),    
		'' cht_class,    
		'',  
		'',    
		'',    
		ivd_charge_type = COALESCE(freightdetail.fgt_charge_type,0),    
		0,    
		@trlrentcht trlrentcht,    
		'',    
		@dumdate ivd_trl_rent_start,    
		@dumdate ivd_trl_rent_end,    
		ivd_rate_type = COALESCE(freightdetail.fgt_rate_type,0),    
		cmp_geoloc = '',    
		'' cht_lh_min,    
		'' cht_lh_rev,    
		'' cht_lh_stl,    
		'' cht_lh_prn,    
		'' cht_lh_rpt,  
		0 ivd_paylgh_number,  
		'' ivd_tariff_type,  
		'' ivd_taxid,  
		0 cht_gp_tax,  
		freightdetail.fgt_ordered_volume ,  
		freightdetail.fgt_ordered_loadingmeters ,    
		freightdetail.fgt_ordered_count,  
		freightdetail.fgt_ordered_weight,  
		freightdetail.fgt_loadingmeters,  
		freightdetail.fgt_loadingmetersunit ,
		'',   
		'N' ivd_hide,
		'N' usr ,   
		ivd_tollcost = Case freightdetail.fgt_sequence When 1 Then stops.stp_ord_toll_cost else 0 end,
	  	'UNK' ivd_ARTaxAuth,
		commodity.cmd_class, -- pts 36316 os
        	fgt_shipper = COALESCE(freightdetail.fgt_shipper,'UNKNOWN'),
		--ivd_tollcost = stops.stp_ord_toll_cost
		0 ivd_tax_basis, --PTS 38778 EMK

		fgt_actual_quantity, -- PTS 38773 for the ivd_actual_quantity
		fgt_actual_unit,      -- PTS 38773 for the ivd_actual_unit
		
		fgt_actual_quantity,   -- PTS 38773 
		fgt_actual_unit,       -- PTS 38773 
		fgt_billable_quantity, -- PTS 38773 
		fgt_billable_unit,      -- PTS 38773 
        COALESCE(fgt_supplier,'UNKNOWN') fgt_supplier,
		0 ivd_loaded_distance, 	--PTS 38823
		0 ivd_empty_distance,   	--PTS 38823
		'U' ivd_paid_indicator, --PTS 41325
		 0  ivd_paid_amount, --PTS 41325
		0 ivd_leaseassetid,
		ivd_maskFromRating  = Case stp_type When 'DRP' Then  'N' Else 'Y' ENd , --40259
--		ivd_car_key = COALESCE(orderheader.car_key,0),							--40259
--		ivh_carkey = COALESCE(orderheader.car_key,0),								--40259
        ivd_car_key = @ordcarkey,							--40259
    	ivh_carkey = @ordcarkey	,						--40259
		ivd_showas_cmpid = COALESCE(stops.stp_showas_cmpid, 'UNKNOWN'),	--PTS 42289
		ivd_post_invoice = 'N',
        '' ivd_billable_flag,
        orderheader.ord_number,
		0 as dbsd_id_tariff, /*PTS 52067*/
		0 ivd_allocated_ivd_number,  --PTS51296
                '' ivd_allocation_type,      --PTS51296
		0 ivd_allocated_qty,	     --PTS51296
		0 ivd_allocated_rate,	     --PTS51296
		0 ivd_allocated_charge,	     --PTS51296,
		0 ivd_reconcile_tariff,		--PTS 53514
		0 ivd_description_type,	  --PTS 56312 
		 'N' cht_tax1,
		 'N' cht_tax2,
		 'N' cht_tax3,
		 'N' cht_tax4,
		 'N' cht_tax5,
		 'N' cht_tax6,
		 'N' cht_tax7,
		 'N' cht_tax8,
		 'N' cht_tax9,
		 'N' cht_tax10,
		0 ivd_rated_qty, -- PTS 58737 SGB
		0 ivd_rated_rate,	-- PTS 58737 SGB
		0 dbst_rollinto_tar,	-- PTS 58737 SGB
		'' ivd_customer_char1   -- 63734		 
	FROM  @ords ords --orderheader
          join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber
          join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
          join freightdetail on stops.stp_number = freightdetail.stp_number
          join @rowseq rowseq on freightdetail.fgt_number = rowseq.fgt_number  -- added to sequence records
          left outer join commodity on freightdetail.cmd_code = commodity.cmd_code
          join event on stops.stp_number = event.stp_number
          join eventcodetable on event.evt_eventcode = eventcodetable.abbr 
--freightdetail, stops, event, eventcodetable, commodity  ,orderheader
	WHERE --orderheader.ord_hdrnumber = @numberparm and  
        ( evt_sequence = 1) and  
		( eventcodetable.ect_billable = 'Y') 
/* this drops the first billable stop 
	AND ( stops.stp_sequence > (SELECT MIN ( stp_sequence )     
								FROM stops, eventcodetable     
								WHERE ord_hdrnumber = @numberparm AND    
									stp_event = abbr AND    
									ect_billable = 'Y' )) AND    
									( event.evt_sequence = 1 )
*/    
        and stops.stp_number <> @firststpnumber  -- replacement for mfh_sequence > code below  
        AND stops.stp_type <> (select Case 
									when @BillOption='IgnoreAllPUP' then 'PUP'
								 	else 'UNMATCHABLE' end) --PTS 38823
    
/* LOR 4.0 fix for billable/non-billable stops    
       AND    
                        (eventcodetable.fgt_event = 'PUP' OR    
                         eventcodetable.fgt_event = 'DRP') */    
 	-- JET - 6/19/00 - PTS #8257, make sure stops are sorted correctly before computing mileages    
	-- EMK - 05/17/07 -PTS 37260, Retrieve billto from orderheader if invoice detail AND invoiceheader billto are both NULL
  Else  -- where INVREFNUM = MANIFEST (this option used the freigth_by_compartment to retrieve delivered goods ) 
   BEGIN  
    -- I do not think they will ever cross dock bulk liquid,  if so must change   
    -- From clause  
    Select @movnumber = mov_number From Orderheader where ord_hdrnumber = @numberparm  
 
    Select @FBCRefType = RTRIM(COALESCE(gi_string1,''))  
    From @GIKEY Where gi_name = 'RefType-Manifest'  
    If COALESCE(@FBCRefType,'') = '' Select @FBCRefType = COALESCE(@FBCRefType,'MAN#')  
  
    INSERT INTO @temp_inv      
    SELECT       
     0 ivh_hdrnumber,       
    0 ivd_number,      
    ivd_description =       
      CASE stops.stp_type      
      WHEN 'PUP' THEN COALESCE(freightdetail.fgt_description,'UNKNOWN')      
      WHEN 'DRP' THEN COALESCE(freightdetail.fgt_description,'UNKNOWN')      
      ELSE COALESCE((SELECT name FROM eventcodetable where abbr = stops.stp_event),'')      
      END,      
    ivd_quantity =  Case  
      When COALESCE(FBC.fgt_number,0) = 0 Then COALESCE(freightdetail.fgt_quantity,0) 
      When fgt_unit = 'UNK' Then 0
/* attempt to apportion when the freight record is spit across compartments  */
      Else Case (select min(labeldefinition) from labelfile where abbr = fgt_unit and (labeldefinition
                 = 'WeightUnits' or labeldefinition = 'VolumeUnits' or labeldefinition = 'CountUnits'))
           when 'WeightUnits' then  case fgt_weight when 0 then fgt_quantity else fgt_quantity * (fbc.fbc_weight / fgt_weight) end
           when 'VolumeUnits' then case fgt_volume when 0 then fgt_quantity else fgt_quantity * (fbc.fbc_volume / fgt_volume) end
           when 'CountUnits' then case fgt_count when 0 then fgt_quantity else fgt_quantity * (fbc.fbc_net_volume / fgt_count) end

        /*   When fgt_weight <> 0 and fgt_quantity = fgt_weight * (Select unc_factor from unitconversion where unc_from = fgt_weightunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then fgt_quantity * (fbc.fbc_weight / fgt_weight)
                  When fgt_volume <> 0 and fgt_quantity = fgt_volume * (Select unc_factor from unitconversion where unc_from = fgt_volumeunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then fgt_quantity * (fbc.fbc_volume / fgt_volume)
*/          
           Else COALESCE(fgt_quantity,0)
           End
      End, 
    COALESCE(freightdetail.fgt_rate,0.0) ivd_rate,       
    ivd_charge = Case   
      When COALESCE(FBC.fgt_number,0)  = 0 Then COALESCE(freightdetail.fgt_charge,0.0)   
      When freightdetail.fgt_quantity = 0 Then 0  
/* attempt to apportion when the freight record is spit across compartments  */
      Else Case (select min(labeldefinition) from labelfile where abbr = fgt_unit and (labeldefinition
         = 'WeightUnits' or labeldefinition = 'VolumeUnits' or labeldefinition = 'CountUnits'))
         when 'WeightUnits' then case fgt_weight when 0 then fgt_charge else Round(COALESCE(fgt_charge,0.0) * (FBC.fbc_weight / fgt_weight), 2) end
         when 'VolumeUnits' then case fgt_volume when 0 then fgt_charge else Round(COALESCE(fgt_charge,0.0) * (FBC.fbc_volume / fgt_volume),2) end 
         /* customer uses count field for net volume recorded in fbc table */
         when 'CountUnits' then case fgt_count when 0 then fgt_charge else Round(COALESCE(fgt_charge,0.0) * (FBC.fbc_net_volume / fgt_count),2) end
/*
         When fgt_quantity = fgt_weight * (Select unc_factor from unitconversion where unc_from = fgt_weightunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q')  Then Round(COALESCE(fgt_charge,0.0) * (FBC.fbc_weight / fgt_weight), 2)  
         WHen fgt_quantity = fgt_volume * (Select unc_factor from unitconversion where unc_from = fgt_volumeunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then Round(COALESCE(fgt_charge,0.0) * (FBC.fbc_volume / fgt_volume),2) 
         when fgt_quantity = fgt_count * (Select unc_factor from unitconversion where unc_from = fgt_countunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then ROund(COALESCE(fgt_charge,0.0) * (FBC.fbc_volume / fgt_volume),2) 
*/
         ELse COALESCE(freightdetail.fgt_charge,0.0) 
         End  
      End ,       
    commodity.cmd_taxtable1 ivd_taxable1,      
    commodity.cmd_taxtable2 ivd_taxable2,       
    commodity.cmd_taxtable3 ivd_taxable3,       
    commodity.cmd_taxtable4 ivd_taxable4,       
    COALESCE(freightdetail.fgt_unit,'LBS') ivd_unit,       
    @dummy6 cur_code,       
    @dumdate currencydate,       
    @glnum ivd_glnum,        
    @numberparm,  --43837  stops.ord_hdrnumber,  
    Case stops.stp_type WHEN 'PUP' THEN 'PUP' WHEN 'DRP' THEN 'DRP' ELSE 'DRP' END, -- JD 24305       
    COALESCE(freightdetail.fgt_rateunit,'UNK') shp_rateunit,         
    ivd_billto = (Select ord_billto From orderheader h Where h.ord_hdrnumber = @numberparm),   
    0 ivd_itemquantity,    
    0 ivd_subtotalptr,
/*        
-- PTS 23628 -- BL (start)  
--  (stops.stp_sequence * 30 + freightdetail.fgt_sequence),        
   (Select Count(*)  
             From stops s2, freightdetail f2  
             Where s2.stp_number = f2.stp_number  
  and (s2.stp_sequence * 1000 + f2.fgt_sequence) <= (stops.stp_sequence * 1000 + freightdetail.fgt_sequence)  
  and s2.ord_hdrnumber = @numberparm) As RowNum,  
-- PTS 23628 -- BL (end) 
*/
    (rowseq.rs_ident + 5) as RowNum, 
    @dummy6 shp_invoicestatus,          
    stops.mov_number,       
    ivd_refnum = 
      Case @RefnumSource 
         When 'F' Then freightdetail.fgt_refnum 
         When 'S' Then stops.stp_refnum
         When 'M' then      
            Case Rtrim(COALESCE(FBC.fbc_refnumber,''))  
              When '' Then  COALESCE((Select Max(ref_number) From referencenumber Where ref_table = 'freightdetail'  
                        and ref_tablekey = freightdetail.fgt_number and ref_type = @FBCRefType),'')  
                           Else FBC.fbc_refnumber  
              End
         Else stops.stp_refnum End,          
    stops.cmp_id,       
    ivd_distance = Case freightdetail.fgt_sequence When 1 Then stops.stp_ord_mileage else 0 end,       
   'MIL' ivd_distunit,       
 --  COALESCE(freightdetail.fgt_weight,0) ivd_wgt,  
   ivd_weight = Case COALESCE(FBC.fgt_number,0)  
     When 0 then   COALESCE(freightdetail.fgt_weight,0)   
     Else FBC.fbc_weight  
     End,     
   COALESCE(freightdetail.fgt_weightunit,'LBS') ivd_wgtunit,       
--   COALESCE(freightdetail.fgt_count,0) ivd_count, 
   ivd_count = 
     Case COALESCE(FBC.fgt_number,0)  
       When 0 Then  COALESCE(freightdetail.fgt_count,0)  
       Else FBC.fbc_net_volume 
       End,  
   event.evt_number,       
  ivd_reftype = 
    Case @RefnumSource 
         When 'F' Then freightdetail.fgt_reftype 
         When 'S' Then stops.stp_reftype
         When 'M' then @FBCRefType     
         Else stops.stp_reftype End,    
 --  COALESCE(freightdetail.fgt_volume,0) ivd_volume,  
   ivd_volume =   
     Case COALESCE(FBC.fgt_number,0)  
       When 0 Then  COALESCE(freightdetail.fgt_volume,0)  
       Else FBC.fbc_Volume  
       End,  
   COALESCE(freightdetail.fgt_volumeunit,'CUB') ivd_volunit,       
   stops.cmp_id shp_originpoint, 
   COALESCE(freightdetail.fgt_countunit,'PCS') ivd_countunit,      
   -- JET - 2/3/99 - PTS#4702      
   -- freightdetail.cht_itemcode cht_itemcode,        
   COALESCE(freightdetail.cht_itemcode, 'UNK') cht_itemcode,      
   COALESCE(freightdetail.cmd_code,'UNKNOWN') cmd_code,       
   'DEL' cht_basis,       
   freightdetail.fgt_lowtemp,       
   freightdetail.fgt_hitemp,       
   1 ivd_sign,      
  --  replacing fgt length,width or height with ord values moved from below (see 18529)  
  --DPH PTS 18529 7/13/04 Only take the header (if larger) if it is rate by TOTAL     
   ivd_length = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_length,0) > COALESCE(freightdetail.fgt_length,0)   
   Then ord_length Else COALESCE(freightdetail.fgt_length,0) End)   
   Else COALESCE(freightdetail.fgt_length,0) End,  
         
   ivd_lengthunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_length,0) > COALESCE(freightdetail.fgt_length,0)   
   Then COALESCE(ord_lengthunit,'UNK') Else COALESCE(freightdetail.fgt_lengthunit,'UNK') End)   
   Else COALESCE(freightdetail.fgt_lengthunit,'UNK') End,         
    
   ivd_width = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_width,0) > COALESCE(fgt_width,0)   
   Then COALESCE(ord_width,0) Else COALESCE(freightdetail.fgt_width,0) End)   
   Else COALESCE(freightdetail.fgt_width,0) End,         
    
   ivd_widthunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_width,0) > COALESCE(fgt_width,0)   
   Then COALESCE(ord_widthunit,'UNK') Else COALESCE(freightdetail.fgt_widthunit,'UNK') End)   
   Else COALESCE(freightdetail.fgt_widthunit,'UNK') End,          
    
   ivd_height = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_height,0) > COALESCE(fgt_height,0)   
   Then COALESCE(ord_height,0) Else COALESCE(freightdetail.fgt_height,0) End)   
   Else COALESCE(freightdetail.fgt_height,0) End,        
    
   ivd_heightunit = Case When UPPER(RTRIM(LTRIM(ord_rateby))) = 'T' Then (Case When COALESCE(ord_height,0) > COALESCE(fgt_height,0)   
   Then COALESCE(ord_heightunit,'UNK') Else COALESCE(freightdetail.fgt_heightunit,'UNK') End)   
   Else COALESCE(freightdetail.fgt_heightunit,'UNK') End,      
    'Y' cht_primary,       
    stops.stp_number,       
    COALESCE(freightdetail.cht_basisunit,'UNK') cht_basisunit,      
    '' ivd_remark,      
    freightdetail.tar_number,      
    freightdetail.tar_tariffnumber,      
    freightdetail.tar_tariffitem,      
    ' ',      
    ' ',      
    ' ',       
    0 cht_rollintolh,      
    @ctynmstct cty_nmstct,      
    @ctycode stp_city,      
    @ctycode origin_city,       
    @zipcode stp_zipcode,       
    @zipcode origin_zipcode,      
    freightdetail.fgt_number,      
    fgt_ratingquantity = Case  
      When COALESCE(FBC.fgt_number,0) = 0 Then COALESCE(freightdetail.fgt_ratingquantity,0) 
      When fgt_ratingunit = 'UNK' Then 0
/* attempt to apportion when the freight record is spit across compartments  */
      ELSE Case (select min(labeldefinition) from labelfile where abbr = fgt_unit and (labeldefinition
                 = 'WeightUnits' or labeldefinition = 'VolumeUnits' or labeldefinition = 'CountUnits'))
         when 'WeightUnits' then case fgt_weight when 0 then fgt_ratingquantity else Round(COALESCE(fgt_ratingquantity,0.0) * (FBC.fbc_weight / fgt_weight), 2) end
         when 'VolumeUnits' then case fgt_volume when 0 then fgt_ratingquantity else Round(COALESCE(fgt_ratingquantity,0.0) * (FBC.fbc_volume / fgt_volume),2) end 
         /* customer uses count field for net volume recorded in fbc table */
         when 'CountUnits' then case fgt_count when 0 then fgt_ratingquantity else Round(COALESCE(fgt_ratingquantity,0.0) * (FBC.fbc_net_volume / fgt_count),2) end
/*
      Else Case When fgt_weight <> 0 and fgt_quantity = fgt_weight * (Select unc_factor from unitconversion where unc_from = fgt_weightunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then fgt_quantity * (fbc.fbc_weight / fgt_weight)
                  When fgt_volume <> 0 and fgt_quantity = fgt_volume * (Select unc_factor from unitconversion where unc_from = fgt_volumeunit
                  and unc_to = fgt_unit and  unc_convflag = 'Q') Then fgt_quantity * (fbc.fbc_volume / fgt_volume)
*/
         Else COALESCE(freightdetail.fgt_ratingquantity,0)
         End
      End, 
    fgt_ratingunit = COALESCE(freightdetail.fgt_ratingunit,freightdetail.fgt_unit),      
    ivd_quantity_type = COALESCE(freightdetail.fgt_quantity_type,0),      
    '' cht_class,      
    '',    
    '',      
    '',      
    ivd_charge_type = COALESCE(freightdetail.fgt_charge_type,0),      
    0,      
    @trlrentcht trlrentcht,      
    '',      
    @dumdate ivd_trl_rent_start,   
    @dumdate ivd_trl_rent_end,      
    ivd_rate_type = COALESCE(freightdetail.fgt_rate_type,0),      
    cmp_geoloc = '',      
    '' cht_lh_min,      
    '' cht_lh_rev,      
    '' cht_lh_stl,      
    '' cht_lh_prn,      
    '' cht_lh_rpt,    
    0 ivd_paylgh_number,    
    '' ivd_tariff_type,    
    '' ivd_taxid,    
    0 cht_gp_tax,    
    freightdetail.fgt_ordered_volume ,    
    freightdetail.fgt_ordered_loadingmeters ,      
    freightdetail.fgt_ordered_count,    
    freightdetail.fgt_ordered_weight,    
    freightdetail.fgt_loadingmeters,    
    freightdetail.fgt_loadingmetersunit ,  
    '' ,
    'N' ivd_hide,
		'N' usr ,   
		ivd_tollcost = Case freightdetail.fgt_sequence When 1 Then stops.stp_ord_toll_cost else 0 end,
	  	'UNK' ivd_ARTaxAuth,
		commodity.cmd_class, -- pts 36316 os
        	fgt_shipper = COALESCE(freightdetail.fgt_shipper,'UNKNOWN'),
		--ivd_tollcost = stops.stp_ord_toll_cost
		0 ivd_tax_basis, --PTS 38778 EMK

		fgt_actual_quantity, -- PTS 38773 for the ivd_actual_quantity
		fgt_actual_unit,      -- PTS 38773 for the ivd_actual_unit
		
		fgt_actual_quantity,   -- PTS 38773 
		fgt_actual_unit,       -- PTS 38773 
		fgt_billable_quantity, -- PTS 38773 
		fgt_billable_unit,      -- PTS 38773 
        COALESCE(fgt_supplier,'UNKNOWN') fgt_supplier,
		0 ivd_loaded_distance, 	--PTS 38823
		0 ivd_empty_distance,   	--PTS 38823
		'U' ivd_paid_indicator, --PTS 41325
		 0  ivd_paid_amount, --PTS 41325
		0 ivd_leaseassetid 
    ,ivd_maskFromRating  = Case stp_type When 'DRP' Then  'N' Else 'Y' ENd 
    ,ivd_car_key = COALESCE(orderheader.car_key,0)
    ,ivh_carkey = COALESCE(orderheader.car_key,0),
	ivd_showas_cmpid = COALESCE(stops.stp_showas_cmpid, 'UNKNOWN'),	--PTS 42289      
	ivd_post_invoice = 'N',
    '' ivd_billable_flag,
    orderheader.ord_number,
	0 as dbsd_id_tariff, /*PTS 52067*/
	0 ivd_allocated_ivd_number,  --PTS51296
        '' ivd_allocation_type,      --PTS51296
	0 ivd_allocated_qty,	     --PTS51296
	0 ivd_allocated_rate,	     --PTS51296
	0 ivd_allocated_charge,	     --PTS51296
	0 ivd_reconcile_tariff, --PTS 53514
	0 ivd_description_type,	  --PTS 56312			
	 'N' cht_tax1,
	 'N' cht_tax2,
	 'N' cht_tax3,
	 'N' cht_tax4,
	 'N' cht_tax5,
	 'N' cht_tax6,
	 'N' cht_tax7,
	 'N' cht_tax8,
	 'N' cht_tax9,
	 'N' cht_tax10,
	0 ivd_rated_qty, -- PTS 58737 SGB
	0 ivd_rated_rate,	-- PTS 58737 SGB
	0 dbst_rollinto_tar,	-- PTS 58737 SGB
	'' ivd_customer_char1   -- 63734	 
/*    
    FROM  freightdetail  
    Left Outer Join (Select fgt_number  
                     , fbc_refnumber = COALESCE(fbc_refnumber,'')  
                     , fbc_volume = sum(COALESCE(fbc_volume,0))  
                     , fbc_weight = sum(COALESCE(fbc_weight,0))
                     ,fbc_net_volume = sum(COALESCE(fbc_net_volume,0))   
                     From freight_by_compartment BC  
                     Where  bc.mov_number = @movnumber  
                     Group by fgt_number,fbc_refnumber) FBC on fbc.fgt_number = freightdetail.fgt_number  
    , stops  
    Left Outer Join commodity on commodity.cmd_code = stops.cmd_code  
    , event  
    , eventcodetable   
    ,orderheader    
    WHERE orderheader.ord_hdrnumber = @numberparm     
    And stops.ord_hdrnumber = orderheader.ord_hdrnumber          
    And stops.stp_number = event.stp_number        
    And freightdetail.stp_number = stops.stp_number       
    And event.evt_eventcode = eventcodetable.abbr         
    And eventcodetable.ect_billable = 'Y'    
    And stops.stp_sequence > (SELECT MIN ( stp_sequence )       
         FROM stops, eventcodetable       
         WHERE ord_hdrnumber = @numberparm AND      
         stp_event = abbr AND      
         ect_billable = 'Y' )       
    And event.evt_sequence = 1  
*/
/* note this option does not support invoicing by multiple orders per invoice */
    FROM  orderheader
    join stops on orderheader.ord_hdrnumber = stops.ord_hdrnumber
    join freightdetail  on stops.stp_number = freightdetail.stp_number
    left outer join @rowseq rowseq on freightdetail.fgt_number = rowseq.fgt_number
    join event on stops.stp_number = event.stp_number and evt_sequence = 1
    join eventcodetable on event.evt_eventcode = eventcodetable.abbr and   eventcodetable.ect_billable = 'Y'  
    Left Outer Join (Select fgt_number  
                     , fbc_refnumber = COALESCE(fbc_refnumber,'')  
                     , fbc_volume = sum(COALESCE(fbc_volume,0))  
                     , fbc_weight = sum(COALESCE(fbc_weight,0))
                     ,fbc_net_volume = sum(COALESCE(fbc_net_volume,0))   
                     From freight_by_compartment BC  
                     Where  bc.mov_number = @movnumber  
                     Group by fgt_number,fbc_refnumber) FBC on fbc.fgt_number = freightdetail.fgt_number    
    Left Outer Join commodity on commodity.cmd_code = stops.cmd_code 
    WHERE orderheader.ord_hdrnumber = @numberparm  
    and stops.stp_number <> @firststpnumber  -- replacement for mfh_sequence > code below  
 /*    
    And stops.stp_sequence > (SELECT MIN ( stp_sequence )     
								FROM stops, eventcodetable     
								WHERE mov_number = @mov
                                and ord_hdrnumber =  @numberparm  
								and	stp_event = abbr    
								and	ect_billable = 'Y' )  
*/  
  
     
   END  

 --UNION ALL 
 insert into @temp_inv   
 SELECT invoicedetail.ivh_hdrnumber,     
  invoicedetail.ivd_number,     
  invoicedetail.ivd_description,     
  invoicedetail.ivd_quantity,     
  invoicedetail.ivd_rate,     
  invoicedetail.ivd_charge,     
  COALESCE(invoicedetail.ivd_taxable1,chargetype.cht_taxtable1), --invoicedetail.ivd_taxable1, 
  COALESCE(invoicedetail.ivd_taxable2,chargetype.cht_taxtable2), --invoicedetail.ivd_taxable2,     
  COALESCE(invoicedetail.ivd_taxable3,chargetype.cht_taxtable3), --invoicedetail.ivd_taxable3,     
  COALESCE(invoicedetail.ivd_taxable4,chargetype.cht_taxtable4), --invoicedetail.ivd_taxable4,   
  invoicedetail.ivd_unit,     
  invoicedetail.cur_code,     
  invoicedetail.ivd_currencydate,     
  invoicedetail.ivd_glnum,     
  invoicedetail.ord_hdrnumber,     
  --invoicedetail.ivd_type,				-- NQIAO PTS 59136 <START>  
  ivd_type = Case COALESCE(invoicedetail.ivd_type, 'NULL')
				When 'NULL' Then (
					Case COALESCE(invoicedetail.stp_number, 0)
						When 0 Then 'LI'
						Else 'DRP' End)
				Else invoicedetail.ivd_type End,		-- NQIAO PTS 59136 <END>    
  invoicedetail.ivd_rateunit,     
  ivd_billto = CASE COALESCE(invoicedetail.ivd_billto, 'UNKNOWN') --PTS 37260
				  WHEN 'UNKNOWN' THEN ord_billto
                  WHEN '' THEN ord_billto
				  ELSE invoicedetail.ivd_billto 
			   END, 
  invoicedetail.ivd_itemquantity,     
  invoicedetail.ivd_subtotalptr,     
  --case @v_GICHargesMode when 'NVOCHARGES' then invoicedetail.ivd_sequence else 9999 end, --invoicedetail.ivd_sequence,  
  case  invoicedetail.ivd_sequence when 999 then 9999 else   invoicedetail.ivd_sequence end,     
  invoicedetail.ivd_invoicestatus,     
  invoicedetail.mfh_hdrnumber,     
  invoicedetail.ivd_refnum,     
  invoicedetail.cmp_id,     
  invoicedetail.ivd_distance,     
  invoicedetail.ivd_distunit,     
  invoicedetail.ivd_wgt,     
  invoicedetail.ivd_wgtunit,     
  invoicedetail.ivd_count,     
  invoicedetail.evt_number,     
  invoicedetail.ivd_reftype,     
  invoicedetail.ivd_volume,     
  invoicedetail.ivd_volunit,     
  invoicedetail.ivd_orig_cmpid,     
  invoicedetail.ivd_countunit,     
  invoicedetail.cht_itemcode,     
  invoicedetail.cmd_code,     
  chargetype.cht_basis,      
  0 lowtemp,       
  0 hightemp,     
  invoicedetail.ivd_sign,     
  invoicedetail.ivd_length,     
  invoicedetail.ivd_lengthunit,     
  invoicedetail.ivd_width,     
  invoicedetail.ivd_widthunit,     
  invoicedetail.ivd_height,     
  invoicedetail.ivd_heightunit ,    
  chargetype.cht_primary,     
  invoicedetail.stp_number,    
  invoicedetail.cht_basisunit,    
  invoicedetail.ivd_remark,    
  invoicedetail.tar_number,    
  invoicedetail.tar_tariffnumber,    
  invoicedetail.tar_tariffitem,    
  ' ',    
  ' ',    
  invoicedetail.ivd_fromord,     
--  LOR      chargetype.cht_rollintolh,    
  invoicedetail.cht_rollintolh,    
  @ctynmstct cty_nmstct,    
  @ctycode stp_city,    
  @ctycode origin_city,     
  @zipcode stp_zipcode,     
  @zipcode origin_zipcode,    
  invoicedetail.fgt_number,    
  fgt_ratingquantity = ivd_quantity,     
  fgt_ratingunit = ivd_unit,    
  IVD_quantity_type = COALESCE(IVD_quantity_type,0),    
  invoicedetail.cht_class,    
  '',  
  '',    
  ivd_mileagetable,    
  ivd_charge_type = COALESCE(ivd_charge_type,0),    
  0,    
  @trlrentcht trlrentcht,    
  ivd_trl_rent,    
  ivd_trl_rent_start,    
  ivd_trl_rent_end,    
  ivd_rate_type = COALESCE(ivd_rate_type,0),    
  cmp_geoloc = '',    
  invoicedetail.cht_lh_min,    
  invoicedetail.cht_lh_rev,    
  invoicedetail.cht_lh_stl,    
  invoicedetail.cht_lh_prn,    
  invoicedetail.cht_lh_rpt,  
  invoicedetail.ivd_paylgh_number,  
 invoicedetail.ivd_tariff_type,  
  ivd_taxid = COALESCE (invoicedetail.ivd_taxid, ''),  
  COALESCE (chargetype.gp_tax, 0),  
  invoicedetail.ivd_ordered_volume ,  
  invoicedetail.ivd_ordered_loadingmeters ,    
  invoicedetail.ivd_ordered_count,  
  invoicedetail.ivd_ordered_weight,  
  invoicedetail.ivd_loadingmeters,  
  invoicedetail.ivd_loadingmeters_unit,        
  invoicedetail.ivd_revtype1,   
  'N' ivd_hide,
  'N' usr,
  invoicedetail.ivd_tollcost,
  ivd_ARTaxAuth = COALESCE(invoicedetail.ivd_ARTaxAuth,'UNK'), -- PTS 35555 - EMK 
  commodity.cmd_class ,-- pts 36316 os
  'UNKNOWN' fgt_shipper,
  invoicedetail.ivd_tax_basis, --PTS 38778 EMK	      

  ivd_actual_quantity,  -- PTS 38773 
   ivd_actual_unit,  -- PTS 38773 
   0    fgt_actual_quantity,   -- PTS 38773 
  'UNK' fgt_actual_unit,       -- PTS 38773 
   0    fgt_billable_quantity, -- PTS 38773 
  'UNK'	fgt_billable_unit ,     -- PTS 38773 
  'UNKNOWN' fgt_supplier,
  invoicedetail.ivd_loaded_distance, 	--PTS 38823
  invoicedetail.ivd_empty_distance,   --PTS 38823
  COALESCE (ivd_paid_indicator, 'U'), --PTS 41325
  ivd_paid_amount, --PTS 41325
  ivd_leaseassetid,
  ivd_maskFromRating  = COALESCE(invoicedetail.ivd_MaskFromRating,'N'),  --40257
  ivd_car_key = COALESCE(orderheader.car_key,0),--PTS 40259
  ivh_carkey = COALESCE(orderheader.car_key,0), --PTS 40259
  ivd_showas_cmpid = COALESCE(invoicedetail.ivd_showas_cmpid, 'UNKNOWN'),	--PTS 42289
  ivd_post_invoice = COALESCE(invoicedetail.ivd_post_invoice, 'N'),
            ivd_billable_flag,
  ivd_ord_number,
  invoicedetail.dbsd_id_tariff, /*PTS 52067*/
  invoicedetail.ivd_allocated_ivd_number,  --PTS51296
  invoicedetail.ivd_allocation_type,       --PTS51296
  COALESCE(invoicedetail.ivd_allocated_qty, 0),	   --PTS51296
  COALESCE(invoicedetail.ivd_allocated_rate, 0),	   --PTS51296
  COALESCE(invoicedetail.ivd_allocated_charge, 0),	   --PTS51296
  COALESCE(invoicedetail.ivd_reconcile_tariff, 0), --PTS 53514
  COALESCE(invoicedetail.ivd_description_type, 0),	  --PTS 56312		  
 'N' cht_tax1,
 'N' cht_tax2,
 'N' cht_tax3,
 'N' cht_tax4,
 'N' cht_tax5,
 'N' cht_tax6,
 'N' cht_tax7,
 'N' cht_tax8,
 'N' cht_tax9,
 'N' cht_tax10,
  COALESCE(invoicedetail.ivd_rated_qty,0), -- PTS 58737 SGB
  COALESCE(invoicedetail.ivd_rated_rate,0),	-- PTS 58737 SGB
  COALESCE(invoicedetail.dbst_rollinto_tar,0),	-- PTS 58737 SGB
  invoicedetail.ivd_customer_char1   -- 63734
FROM @ords ords
 join invoicedetail on ords.ord_hdrnumber = invoicedetail.ord_hdrnumber 
		Left Outer Join chargetype on invoicedetail.cht_itemcode = chargetype.cht_itemcode
		left outer join commodity on invoicedetail.cmd_code = commodity.cmd_code --pts 36319 os 
		join orderheader on invoicedetail.ord_hdrnumber = orderheader.ord_hdrnumber  --PTS 40259
 WHERE ----(invoicedetail.ord_hdrnumber = @numberparm) AND
		 (COALESCE(ivd_fromord,'&')  = Case Ivh_hdrnumber 
										When  0 Then COALESCE(ivd_fromord,'&') 
										Else 'Y' End    -- if retrieving for rebill only want manual accessorials  
			OR COALESCE(ivd_fromord,'&')  = Case ivh_hdrnumber 
										When  0 Then COALESCE(ivd_fromord,'&') 
										Else 'D' End  )  
		AND ivh_hdrnumber in (0,@MinIvhHdrnumber)  -- if retrieving first time will be zero if retrieve for rebill get acc on first invoice  
        
    
 UNION ALL    
  SELECT 0 ivh_hdrnumber,     
  0 ivd_number,    
  ' ' ivd_description,     
  cht_quantity ivd_quantity,     
  cht_rate ivd_rate,     
  0 ivd_charge,    cht_taxtable1 ivd_taxable1,    
  cht_taxtable2 ivd_taxable2,     
  cht_taxtable3 ivd_taxable3,     
  cht_taxtable4 ivd_taxable4,     
  cht_unit ivd_unit,     
  @dummy6 cur_code,     
  @dumdate currencydate,     
  @glnum ivd_glnum,      
  stops.ord_hdrnumber,     
 -- stops.stp_type, -- JD 24305 replace with case statement    
  Case stops.stp_type WHEN 'PUP' THEN 'PUP' WHEN 'DRP' THEN 'DRP' ELSE 'DRP' END, -- JD 24305  cht_rateunit shp_rateunit,     
  cht_rateunit shp_rateunit,
  --@dummy6 shp_billto,  
  ivd_billto = (Select ord_billto From orderheader h Where h.ord_hdrnumber = @numberparm),      
  0 ivd_itemquantity,     
  0 ivd_subtotalptr,      
  stops.stp_sequence,      
  @dummy6 shp_invoicestatus,     
                -- JET - 6/19/00 - PTS #8263, changed mfh_number to mov_number    
  stops.mov_number,     
  @sDummyRefNum fgt_refnum,     
  stops.cmp_id,     
--   ivd_distance = Case freightdetail.fgt_sequence When 1 then stops.stp_ord_mileage else 0 end , 
  stops.stp_ord_mileage ivd_distance,          
   ' ' ivd_distunit,     
  0 ivd_wgt,     
  ' ' ivd_wgtunit,     
  0 ivd_count,     
  event.evt_number,     
  @sDummyRefType fgt_reftype,     
  0 ivd_volume,     
  ' ' ivd_volunit,     
  stops.cmp_id shp_originpoint,     
  ' ' ivd_countunit,     
  chargetype.cht_itemcode,     
                ' ',     
  chargetype.cht_basis,     
  0,     
  0,     
  1 ivd_sign,    
  0 ivd_length,     
  ' ' ivd_lengthunit,     
  0 ivd_width,     
  ' ' ivd_widthunit,      
  0 ivd_height,    
    
  ' ' ivd_heightunit,     
  cht_primary,    
  stops.stp_number,     
  chargetype.cht_basisunit,    
  '' ivd_remark,    
  0 tar_number,    
  '' tar_tariffnumber,    
  '' tar_tariffitem,    
  ' ',    
  ' ',    
  ' ',     
                chargetype.cht_rollintolh,    
  @ctynmstct cty_nmstct,    
  @ctycode stp_city,    
  @ctycode origin_city,     
                @zipcode stp_zipcode,     
                @zipcode origin_zipcode,    
  0,    
  --fgr_ratingquantity = cht_quantity,   
  fgt_ratingquantity = cht_quantity,   
  fgt_ratingunit = cht_unit,    
  ivd_quantity_type = 0,    
  chargetype.cht_class,    
  '',   
  '',    
  '',    
  ivd_charge_type = 0,    
  0,    
  @trlrentcht trlrentcht,    
  '',    
  @dumdate ivd_trl_rent_start,    
  @dumdate ivd_trl_rent_end,    
  ivd_rate_type = 0,    
  cmp_geoloc = '',    
  chargetype.cht_lh_min,    
  chargetype.cht_lh_rev,    
  chargetype.cht_lh_stl,    
  chargetype.cht_lh_prn,    
  chargetype.cht_lh_rpt,  
  0 ,  
 '' ivd_tariff_type,  
  '' ivd_taxid,  
  COALESCE (chargetype.gp_tax, 0),  
  (select sum (freightdetail.fgt_ordered_volume)  
                            from freightdetail  
      where freightdetail.stp_number = stops.stp_number and  
     freightdetail.fgt_volumeunit = stops.stp_volumeunit),  
  (select sum (freightdetail.fgt_ordered_loadingmeters)  
                            from freightdetail  
      where freightdetail.stp_number = stops.stp_number and  
     freightdetail.fgt_loadingmetersunit = stops.stp_loadingmetersunit),  
  (select sum (freightdetail.fgt_ordered_count)  
                            from freightdetail  
      where freightdetail.stp_number = stops.stp_number and  
     freightdetail.fgt_countunit = stops.stp_countunit),  
  (select sum (freightdetail.fgt_ordered_weight)  
                            from freightdetail  
      where freightdetail.stp_number = stops.stp_number and  
     freightdetail.fgt_weightunit = stops.stp_weightunit),  
  0 ivd_loadingmeters,  
  '' ivd_loadingmeters_unit,
  '' ivd_revtype1,   
  'N' ivd_hide,
  'N' usr,
  stops.stp_ord_toll_cost ivd_tollcost, 
  'UNK' ivd_ARTaxAuth,	-- PTS 35555 - EMK
  'UNKNOWN' cmd_class, -- pts 36316 os
  'UNKNOWN' fgt_shipper,
  0 ivd_tax_basis, --PTS 38778 EMK


					------ PTS 38773  
   0 ivd_actual_quantity,      -- PTS 38773 
  'UNK' ivd_actual_unit,       -- PTS 38773 
   0    fgt_actual_quantity,   -- PTS 38773 
  'UNK' fgt_actual_unit,       -- PTS 38773 
   0    fgt_billable_quantity, -- PTS 38773 
  'UNK'	fgt_billable_unit,      -- PTS 38773 
  'UNKNOWN' fgt_supplier,
  0 ivd_loaded_distance, 	--PTS 38823
  0 ivd_empty_distance,   --PTS 38823
 'U' ivd_paid_indicator, --PTS 41325
  0  ivd_paid_amount, --PTS 41325
  NULL ivd_leaseassetid,	
 ivd_maskFromRating  = Case stp_type When 'DRP' Then  'N' Else 'Y' ENd, --40259
 ivd_car_key = COALESCE(orderheader.car_key,0),--40259
 ivh_carkey = COALESCE(orderheader.car_key,0), --40259
 ivd_showas_cmpid = COALESCE(stops.stp_showas_cmpid, 'UNKNOWN'),	--PTS 42289
 'N' as ivd_post_invoice,
  '' ivd_billable_flag,
  orderheader.ord_number,
 0 as dbsd_id_tariff, /*PTS 52067*/
 0 ivd_allocated_ivd_number,  --PTS51296
 '' ivd_allocation_type,      --PTS51296
 0 ivd_allocated_qty,	      --PTS51296
 0 ivd_allocated_rate,	      --PTS51296
 0 ivd_allocated_charge,	      --PTS51296
 0 ivd_reconcile_tariff, --PTS 53514
 0 ivd_description_type,	  --PTS 56312		
 'N' cht_tax1,
 'N' cht_tax2,
 'N' cht_tax3,
 'N' cht_tax4,
 'N' cht_tax5,
 'N' cht_tax6,
 'N' cht_tax7,
 'N' cht_tax8,
 'N' cht_tax9,
 'N' cht_tax10,
 0 ivd_rated_qty, -- PTS 58737 SGB
 0 ivd_rated_rate,	-- PTS 58737 SGB		
 0 dbst_rollinto_tar,	-- PTS 58737 SGB 
 '' ivd_customer_char1   -- 63734
/*   I doubt this ever brings back anything with that join to chargetype
FROM  chargetype, stops, event, eventcodetable
WHERE stops.ord_hdrnumber = @numberparm AND    
    ( event.evt_eventcode = chargetype.cht_itemcode) AND 
	( stops.stp_number = event.stp_number ) AND    
  	( event.evt_eventcode = eventcodetable.abbr) AND    
  	( eventcodetable.ect_billable = 'Y') --AND    
 neW ANSI JOINS FOLLOW
*/
FROM  stops
      join event on stops.stp_number = event.stp_number
      join eventcodetable on event.evt_eventcode = eventcodetable.abbr
      join chargetype on event.evt_eventcode = chargetype.cht_itemcode
	  join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
WHERE stops.ord_hdrnumber = @numberparm AND     
  	( eventcodetable.ect_billable = 'Y') --AND    
    AND stops.stp_type <> (select Case 
									when @BillOption='IgnoreAllPUP' then 'PUP'
								 	else 'UNMATCHABLE' end) --PTS 38823  
-- PTS 18526 KWS Add order services generated invoice detail records

 UNION ALL
	SELECT 0 ivh_hdrnumber,     
	0 ivd_number,    
	svc_description ivd_description,     
	COALESCE(actual_qty, 0) ivd_quantity,
	charge_rate ivd_rate,
	COALESCE(actual_qty, 0) * COALESCE(charge_rate, 0) ivd_charge,
	chargetype.cht_taxtable1, --invoicedetail.ivd_taxable1, 
  chargetype.cht_taxtable2, --invoicedetail.ivd_taxable2,     
  chargetype.cht_taxtable3, --invoicedetail.ivd_taxable3,     
  chargetype.cht_taxtable4, --invoicedetail.ivd_taxable4,   
	cht_unit ivd_unit,
	@dummy6 cur_code,
	@dumdate currencydate,
	@glnum ivd_glnum,
	order_services.ord_hdrnumber,
	CASE WHEN stops.stp_type <> 'PUP' THEN 'DRP' ELSE stops.stp_type END,
	cht_rateunit shp_rateunit,
	ivd_billto = (Select ord_billto From orderheader h Where h.ord_hdrnumber = @numberparm),      
	0 ivd_itemquantity,
	0 ivd_subtotalptr,      
	9999 ivd_sequence, --999 ivd_sequence,      
	@dummy6 shp_invoicestatus,     
	order_services.mov_number,     
	@sDummyRefNum fgt_refnum,     
	stops.cmp_id,
	stops.stp_ord_mileage ivd_distance,          
	' ' ivd_distunit,     
	0 ivd_wgt,     
	' ' ivd_wgtunit,     
	0 ivd_count,     
	event.evt_number,     
	@sDummyRefType fgt_reftype,     
	0 ivd_volume,     
	' ' ivd_volunit,     
	stops.cmp_id shp_originpoint,     
	' ' ivd_countunit,     
	chargetype.cht_itemcode,     
	' ',     
	chargetype.cht_basis,     
	0,     
	0,     
	1 ivd_sign,    
	0 ivd_length,     
	'' ivd_lengthunit,     
	0 ivd_width,     
	'' ivd_widthunit,      
	0 ivd_height,    
	'' ivd_heightunit,     
	cht_primary,    
	stops.stp_number,     
	chargetype.cht_basisunit,    
	'' ivd_remark,    
	0 tar_number,    
	'' tar_tariffnumber,    
	'' tar_tariffitem,    
	'',    
	'',    
	'',     
	chargetype.cht_rollintolh,    
	@ctynmstct cty_nmstct,    
	@ctycode stp_city,    
	@ctycode origin_city,     
	@zipcode stp_zipcode,     
	@zipcode origin_zipcode,    
	0,    
	actual_qty fgt_ratingquantity,
	cht_unit fgt_ratingunit,
	0 ivd_quantity_type,    
	chargetype.cht_class,    
	'',   
	'',    
	'',    
	0 ivd_charge_type,    
	0,    
	@trlrentcht trlrentcht,    
	'',    
	@dumdate ivd_trl_rent_start,    
	@dumdate ivd_trl_rent_end,    
	0 ivd_rate_type,    
	'' cmp_geoloc,    
	chargetype.cht_lh_min,    
	chargetype.cht_lh_rev,    
	chargetype.cht_lh_stl,    
	chargetype.cht_lh_prn,    
	chargetype.cht_lh_rpt,  
	0,
	'' ivd_tariff_type,  
	'' ivd_taxid,  
	COALESCE (chargetype.gp_tax, 0),  
	0,  
	0,  
	0,  
	0,  
	0 ivd_loadingmeters,  
	'' ivd_loadingmeters_unit,
	'' ivd_revtype1,   
  'N' ivd_hide,
  'N' usr,
	stops.stp_ord_toll_cost ivd_tollcost,
  'UNK' ivd_ARTaxAuth,	  -- PTS 35555 - EMK 
  'UNKNOWN' cmd_class, -- pts 36316 os 
  'UNKNOWN' fgt_shipper,
	0 ivd_tax_basis, --PTS 38778 EMK


						------ PTS 38773 
  0 ivd_actual_quantity,  -- PTS 38773 
  'UNK' ivd_actual_unit,  -- PTS 38773 
  0    fgt_actual_quantity,   -- PTS 38773 
  'UNK' fgt_actual_unit,       -- PTS 38773 
  0    fgt_billable_quantity, -- PTS 38773 
  'UNK'	fgt_billable_unit ,     -- PTS 38773 
  'UNKNOWN' fgt_supplier,
  0 ivd_loaded_distance, 	--PTS 38823
  0 ivd_empty_distance,   --PTS 38823
 'U' ivd_paid_indicator, --PTS 41325
  0  ivd_paid_amount, --PTS 41325
  NULL,
 ivd_maskFromRating  = 'N', --40259
 ivd_car_key = COALESCE(orderheader.car_key,0),--40259
 ivh_carkey = COALESCE(orderheader.car_key,0), --40259
 ivd_showas_cmpid = COALESCE(stops.stp_showas_cmpid, 'UNKNOWN'),  --42289
 'N' ivd_post_invoice,
 '' ivd_billable_flag,
 orderheader.ord_number,
 0 as dbsd_id_tariff, /*PTS 52067*/
 0 ivd_allocated_ivd_number,  --PTS51296
 '' ivd_allocation_type,      --PTS51296
 0 ivd_allocated_qty,	      --PTS51296
 0 ivd_allocated_rate,	      --PTS51296
 0 ivd_allocated_charge,	      --PTS51296
 0 ivd_reconcile_tariff, --PTS 53514
 0 ivd_description_type,	  --PTS 56312		
 'N' cht_tax1,
 'N' cht_tax2,
 'N' cht_tax3,
 'N' cht_tax4,
 'N' cht_tax5,
 'N' cht_tax6,
 'N' cht_tax7,
 'N' cht_tax8,
 'N' cht_tax9,
 'N' cht_tax10,
 0 ivd_rated_qty, -- PTS 58737 SGB
 0 ivd_rated_rate,	-- PTS 58737 SGB
 0 dbst_rollinto_tar,	-- PTS 58737 SGB
 '' ivd_customer_char1   -- 63734
FROM	order_services
	INNER JOIN services ON order_services.svc_code = services.svc_code
	INNER JOIN chargetype ON services.svc_chargetype = chargetype.cht_itemcode
	LEFT OUTER JOIN stops ON order_services.mov_number = stops.mov_number AND
		order_services.ord_hdrnumber = stops.ord_hdrnumber AND
		order_services.stp_number = stops.stp_number
	LEFT OUTER JOIN event ON order_services.stp_number = event.stp_number
	join orderheader ON order_services.ord_hdrnumber = orderheader.ord_hdrnumber   --40257

WHERE	order_services.ord_hdrnumber = @numberparm AND
		COALESCE(order_services.actual_qty, 0) > 0 AND
		COALESCE(order_services.charge_rate, 0) > 0
		
-- PTS 18526 KWS
   --PTS40594 MBR 01/25/08
   SELECT @defaultbillingqty = UPPER(LEFT(COALESCE(gi_string1, 'N'), 1)),
          @gi_string2 = COALESCE(gi_string2, '1')
     FROM @GIKEY
    WHERE gi_name = 'DefaultBillingQty'
   IF @defaultbillingqty = 'Y'
   BEGIN
      IF @gi_string2 = '1'
         UPDATE @temp_inv
            SET ivd_volume = COALESCE(fgt_volume2,0),
                --ivd_volunit = COALESCE(fgt_volumeunit2, 'GAL') PTS 50008 SGB 12/10/09 correction for Fuel Dispatch using fgt_volume2unit
                ivd_volunit = COALESCE(fgt_volumeunit2,COALESCE(fgt_volume2unit, 'GAL'))
           FROM freightdetail f 
			inner join @temp_inv ti on f.fgt_number = ti.fgt_number
			inner join commodity c on ti.cmd_code = c.cmd_code 
			inner join  billto_cmd_billingqty_relations b on b.billto_id = ti.ivd_billto and b.cmd_class = c.cmd_class
          WHERE  b.gross_net_flag = 'N'

      IF @gi_string2 = '2'
         UPDATE @temp_inv
            SET ivd_volume = COALESCE(fgt_volume2,0),
                ivd_volunit = COALESCE(fgt_volumeunit2,COALESCE(fgt_volume2unit, 'GAL')) 
           FROM freightdetail f
			inner join @temp_inv ti on f.fgt_number = ti.fgt_number 
			inner join commodity c on ti.cmd_code = c.cmd_code
			inner join billto_cmd_billingqty_relations b on b.billto_id = ti.ivd_billto and b.cmd_class = c.cmd_class2
          WHERE b.gross_net_flag = 'N' 
   END
   
   --NSUITE-106669 MBR 09/05/17   
    IF EXISTS (SELECT *
                 FROM orderheader
                WHERE ord_hdrnumber = @numberparm AND 
				      ord_rateby = 'D')
    BEGIN
      INSERT @preRatedDetails
      SELECT cmd_code, 
	         cmp_id, 
			 fgt_number
        FROM @temp_inv
       WHERE ivd_fromord = 'P' AND
             tar_number > 0 AND 
			 ivd_number > 0 AND 
			 ivd_type = 'DRP'
			 
      IF EXISTS (SELECT *
                   FROM @preRatedDetails)
      BEGIN
        SET @min_ident = 0
        WHILE 1 = 1
        BEGIN
          SELECT @min_ident = MIN(prd_ident)
            FROM @preRatedDetails
           WHERE prd_ident > @min_ident
		   
          IF @min_ident IS NULL
          BEGIN
            BREAK
          END
		  
          SELECT @fgt_number = fgt_number
            FROM @preRatedDetails
           WHERE prd_ident = @min_ident
		   
          DELETE FROM @temp_inv
          WHERE fgt_number = @fgt_number AND 
		        ivd_type = 'DRP' AND 
				ivd_number = 0
        END
      END
	END
END    
   
UPDATE @temp_inv    
SET ivh_billto = ivh.ivh_billto,    
 ivh_definition = ivh.ivh_definition,    
 suffix_prefix =     
   Case @suffix    
  When 'SUFFIX' Then SUBSTRING(LTRIM(REVERSE(ivh.ivh_invoicenumber)), 1, 1)    
  WHEN 'PREFIX'  Then SUBSTRING(LTRIM(ivh.ivh_invoicenumber), 1, 1)    
  ELSE ' '    
   END    
 FROM invoiceheader ivh  inner join @temp_inv ti on   
  ivh.ivh_hdrnumber = ti.ivh_hdrnumber    
    
--LOR PTS#4233 missing GL number from system code charge types    
UPDATE @temp_inv    
SET ivd_glnum = cht_glnum    
FROM chargetype c inner join @temp_inv ti on   
 c.cht_itemcode = ti.cht_itemcode    
--LOR    
    
UPDATE @temp_inv    
SET cty_nmstct = c.cty_nmstct,    
 stp_city   = s.cmp_city,     
    stp_zipcode = s.cmp_zip,    
 cmp_geoloc = COALESCE(s.cmp_geoloc,'')    
FROM company s  LEFT OUTER JOIN  city c  ON  s.cmp_city  = c.cty_code  
inner join @temp_inv ti on ti.cmp_id = s.cmp_id 
WHERE ti.cmp_id <> 'UNKNOWN'    

UPDATE @temp_inv    
SET cty_nmstct = c.cty_nmstct,    
 stp_city   = s.stp_city,     
        stp_zipcode = s.stp_zipcode     
FROM city c  RIGHT OUTER JOIN  stops s  ON  c.cty_code  = s.stp_city   
inner join @temp_inv ti on  s.stp_number = ti.stp_number  
WHERE ti.stp_city = 0    
 
--JD    
     
 -- If Ref type to copy is set for Freight ref numbers and if current ref type is not the type to copy, look for the correct type    
If @RefnumSource = 'F' and  @reftypetocopy <>'NONE' and @reftypetocopy > '' and      
  Exists(Select ord_hdrnumber from @temp_inv where ord_hdrnumber > 0) and Not exists (Select  ivh_hdrnumber From @temp_inv where ivh_hdrnumber > 0)      
 Begin      
    Update @temp_inv set 
	ivd_reftype=@reftypetocopy, 
	ivd_refnum=a.minref from
	(
	SELECT ref_tablekey, MIN(ref_number) as minref from referencenumber  
	inner join @temp_inv ti on ref_tablekey = ti.fgt_number
    Where ref_table = 'freightdetail' and ref_type = @reftypetocopy
	group by ref_tablekey
	) a inner join @temp_inv ti1 -- on a.minref = ti1.fgt_number -- PTS 93628 nloke
    on a.ref_tablekey = ti1.fgt_number		--93628
          
 End      

UPDATE  @temp_inv    
SET    fgt_stackable = freightdetail.fgt_stackable    
FROM freightdetail inner join @temp_inv ti on    
 freightdetail.stp_number = ti.stp_number    
 
If Exists(Select ref_stop_count from @temp_inv where ord_hdrnumber > 0) 
	If @RefNumSource = 'F' 
		Update @temp_inv Set ref_stop_count = 2 
		from @temp_inv ti inner join referencenumber r on ti.fgt_number = r.ref_tablekey
		where r.ref_table = 'freightdetail' and r.ref_sequence = 2
	Else
		Update @temp_inv Set ref_stop_count = 2 
		from @temp_inv ti inner join referencenumber r on ti.stp_number = r.ref_tablekey
		where r.ref_table = 'stops' and r.ref_sequence = 2

/* try to figure out where freight was picked up */
select @ordhdrnumber = max(ord_hdrnumber) from @temp_inv
If @ordhdrnumber > 0 
  BEGIN

   
    insert into @pupfgt (cmp_id,cmd_code) select cmp_id, f.cmd_code
    from stops s join freightdetail f on s.stp_number = f.stp_number
    where ord_hdrnumber = @ordhdrnumber
    and stp_type = 'pup' 
    order by stp_arrivaldate

    If exists (select 1 from @pupfgt where cmd_code = 'UNKNOWN')
     /* no pickup commodities recorded the fgt_shipper is the ord shipper */
      BEGIN 

        select @ordshipper = ord_shipper from orderheader where ord_hdrnumber = @ordhdrnumber

        update @temp_inv
        set fgt_shipper = @ordshipper
        where ivd_type = 'DRP' and fgt_shipper = 'UNKNOWN' and cmd_code <> 'UNKNOWN'

      END
    ELSE
      update @temp_inv
      set fgt_shipper = a.mincmp
	  from @temp_inv t inner join 
	  (select ti.cmd_code, COALESCE(min(p.cmp_id),'UNKNOWN') as mincmp from @pupfgt p inner join @temp_inv ti on p.cmd_code = ti.cmd_code group by ti.cmd_code) a
      on t.cmd_code = a.cmd_code
      where t.ivd_type = 'DRP' and t.fgt_shipper = 'UNKNOWN' and t.cmd_code <> 'UNKNOWN'

    --where ivd_type = 'DRP' and fgt_shipper = 'UNKNOWN' 
    update @temp_inv  --default is first pickup
    set fgt_shipper = (select top 1 cmp_id from @pupfgt )
    where ivd_type = 'DRP' and fgt_shipper = 'UNKNOWN' 
      
  END
 /* moved into select statement from order retrieve, left alone if invoice exists
-- dsk pts 18529    
IF (SELECT MAX(ivh_hdrnumber) FROM @temp_inv) = 0 -- new invoice details being created  
BEGIN  
 UPDATE @temp_inv  
 SET ivd_length = orderheader.ord_length  
 FROM orderheader  
 WHERE ivd_length = (SELECT MAX(ivd_length) FROM @temp_inv)  
   AND ivd_length < orderheader.ord_length  
  
 UPDATE @temp_inv  
 SET ivd_height = orderheader.ord_height  
 FROM orderheader  
 WHERE ivd_height = (SELECT MAX(ivd_height ) FROM @temp_inv)  
   AND ivd_height  < orderheader.ord_height   
  
 UPDATE @temp_inv  
 SET ivd_width = orderheader.ord_width  
 FROM orderheader  
 WHERE ivd_width = (SELECT MAX(ivd_width) FROM @temp_inv)  
   AND ivd_width  < orderheader.ord_width   
END  
*/   

/* PTS 32320 - DJM					*/
Update @temp_inv
set ivd_hide = COALESCE(i.ivd_hide, 'N' ),
	usr_supervisor = (select COALESCE(usr_supervisor, 'N') from ttsusers where ttsusers.usr_userid = @tmwuser)
from invoicedetail i inner join @temp_inv ti on ti.ivd_number = i.ivd_number

--	LOR	PTS# 59132
Declare @resequence int, 
		@InvDetResequenceCheck char(1),
		@minSUB int,
		@maxLI	int
select @resequence = 0

SELECT	@InvDetResequenceCheck = UPPER(LEFT(COALESCE(gi_string1, 'N'), 1))
FROM	@GIKEY 
WHERE gi_name = 'InvDetResequenceCheck'

If @InvDetResequenceCheck = 'Y'
-- DPETE 60268
  BEGIN
   update @temp_inv
   set ivd_sequence = 9998 
   from @temp_inv ti
   where ti.ivh_hdrnumber = 0 and ti.ivd_type = 'SUB' and ti.ivd_sequence <> 9998
   
   update @temp_inv
   set ivd_sequence = 9999 
   from @temp_inv ti
   where ti.ivh_hdrnumber = 0 and ti.ivd_type = 'LI' and ti.ivd_sequence <> 9999
  END
/*
begin
                select @maxLI = max(ivd_sequence) from  @temp_inv where ivd_type = 'LI' and @retrieve_by = 'ORDNUM' and ivh_hdrnumber = 0
                select @minSUB = min(ivd_sequence) from  @temp_inv where ivd_type = 'SUB' and @retrieve_by = 'ORDNUM' and ivh_hdrnumber = 0
                if @maxLI < @minSUB
                                select @resequence = 1
end
--             LOR
*/

--vjh pts8616  rather than return *, return list    
--             of fields so we can add other columns to temp table    
select --fgt_number as debugnumber,ivd_sequence,
  ti.ivh_hdrnumber,    
  ti.ivd_number,    
  ti.ivd_description,    
  ti.ivd_quantity,    
  ti.ivd_rate,    
  ti.ivd_charge,    
  ti.ivd_taxable1,    
  ti.ivd_taxable2,    
  ti.ivd_taxable3,    
  ti.ivd_taxable4,    
  ti.ivd_unit,    
  ti.cur_code,    
  ti.ivd_currencydate,    
  ti.ivd_glnum,    
  ti.ord_hdrnumber,    
  ti.ivd_type,    
  ti.ivd_rateunit,    
  ti.ivd_billto,    
  ti.ivd_itemquantity,    
  ti.ivd_subtotalptr,    
  --	LOR	PTS# 59132
  ti.ivd_sequence,
  /*
  case 
	when ti.ivd_type = 'SUB' and @retrieve_by = 'ORDNUM' and ti.ivh_hdrnumber = 0 and @resequence = 1 then 9998
	when ti.ivd_type = 'LI' and @retrieve_by = 'ORDNUM' and ti.ivh_hdrnumber = 0 and @resequence = 1 then 9999
	else ti.ivd_sequence
  end   ivd_sequence,   
  --	LOR	 */ 
  ti.ivd_invoicestatus,    
  ti.mfh_hdrnumber,    
  ti.ivd_refnum,    
  ti.cmp_id,        
  ti.ivd_distance,    
  ti.ivd_distunit,    
  ti.ivd_wgt,    
  ti.ivd_wgtunit,    
  ti.ivd_count,    
  ti.evt_number,    
  ti.ivd_reftype,    
  ti.ivd_volume,    
  ti.ivd_volunit,    
  ti.ivd_orig_cmpid,    
  ti.ivd_countunit,    
  ti.cht_itemcode,    
  ti.cmd_code,    
  ti.cht_basis,    
  ti.lowtemp,    
  ti.hightemp,    
  ti.ivd_sign,    
  ti.ivd_length,    
  ti.ivd_lengthunit,    
  ti.ivd_width,    
  ti.ivd_widthunit,    
  ti.ivd_height,    
  ti.ivd_heightunit,    
  ti.cht_primary,    
  ti.stp_number,    
  ti.cht_basisunit,    
  ti.ivd_remark,    
  ti.tar_number,    
  ti.tar_tariffnumber,    
  ti.tar_tariffitem,    
  ti.ivh_billto,    
  ti.suffix_prefix,    
  ti.ivd_fromord,    
  ti.cht_rollintolh,    
  ti.cty_nmstct,    
  ti.stp_city,    
  ti.origin_city,    
  ti.stp_zipcode,    
  ti.origin_zipcode,    
  ti.fgt_ratingquantity,    
  ti.fgt_ratingunit,    
  ti.ivd_quantity_type,    
  ti.cht_class,    
  ti.ivh_definition,     
  ti.fgt_stackable,    
  ti.ivd_mileagetable,    
  ti.ivd_charge_type,    
  ti.ref_stop_count,   
  --vmj1+ This computed column controls properties on a single detail row at a     
  -- time (usually the LineHaul charge row only is affected by All-Inclusive     
  -- functionality)..    
  'N' as all_inclusive_indc,    
  --vmj1-    
  ti.trlrentcht,    
  ti.ivd_trl_rent,    
  ti.ivd_trl_rent_start,    
  ti.ivd_trl_rent_end,    
  ti.ivd_rate_type,    
  ti.cmp_geoloc,    
 cht_lh_min,    
 cht_lh_rev,    
 cht_lh_stl,    
 cht_lh_prn,    
 cht_lh_rpt,    
 ti.fgt_number,  
 ti.ivd_paylgh_number,  
 ti.ivd_tariff_type,  
  ti.ivd_taxid,  
  ti.cht_gp_tax,    
  ti.ivd_ordered_volume ,  
  ti.ivd_ordered_loadingmeters,    
  ti.ivd_ordered_count,    
  ti.ivd_ordered_weight ,  
  ti.ivd_loadingmeters,  
  ti.ivd_loadingmeters_unit,
  ti.ivd_revtype1 ,
  'RevType1' revtype1_t ,
  'ChrgTypeClass' chrgtypeclass_t,
  ti.ivd_hide,
  ti.usr_supervisor,
  ti.ivd_tollcost,
  ti.ivd_ARTaxAuth,	  -- PTS 35555 - EMK
  ti.cmd_class, --pts 36319 os 
  ti.fgt_shipper, 
  ti.ivd_tax_basis, --PTS 38778 EMK   

  COALESCE(ti.ivd_actual_quantity, 0) ivd_actual_quantity,     -- PTS 38773 
  COALESCE(ti.ivd_actual_unit, 'UNK') ivd_actual_unit,         -- PTS 38773 
  COALESCE(ti.fgt_actual_quantity, 0) fgt_actual_quantity,     -- PTS 38773 
  COALESCE(ti.fgt_actual_unit, 'UNK') fgt_actual_unit,         -- PTS 38773 
  COALESCE(ti.fgt_billable_quantity, 0) fgt_billable_quantity, -- PTS 38773 
  COALESCE(ti.fgt_billable_unit, 'UNK')fgt_billable_unit,       -- PTS 38773 
  fgt_supplier,
  ti.ivd_loaded_distance, 	--PTS 38823
  ti.ivd_empty_distance,	--PTS 38823
  ti.ivd_paid_indicator,	--pts 41325
  ti.ivd_paid_amount,		--pts 41325
  ti.ivd_leaseassetid,
  ivd_MaskFromRating,		--pts 40259
  ivd_car_key,				--pts 40259
  ivh_car_key,				--pts 40259
  ti.ivd_showas_cmpid,		--PTS 42289
  ti.ivd_post_invoice,		--PTS 35377
  ti.ivd_billable_flag,
  ti.ivd_ord_number,         --43837 provides ref to order when invoicing in aggregae
  ti.dbsd_id_tariff, /*PTS 52067*/
  ti.ivd_allocated_ivd_number,  --PTS51296
  ti.ivd_allocation_type,       --PTS51296
  ti.ivd_allocated_qty,		--PTS51296
  ti.ivd_allocated_rate,	--PTS51296
  ti.ivd_allocated_charge,	--PTS51296
  ti.ivd_reconcile_tariff, --PTS 53514
  ti.ivd_description_type,	-- PTS 56312
  COALESCE(cht_tax1, 'N') cht_tax1,
  COALESCE(cht_tax2, 'N') cht_tax2,
  COALESCE(cht_tax3, 'N') cht_tax3,
  COALESCE(cht_tax4, 'N') cht_tax4,
  COALESCE(cht_tax5, 'N') cht_tax5,
  COALESCE(cht_tax6, 'N') cht_tax6,
  COALESCE(cht_tax7, 'N') cht_tax7,
  COALESCE(cht_tax8, 'N') cht_tax8,
  COALESCE(cht_tax9, 'N') cht_tax9,
  COALESCE(cht_tax10, 'N') cht_tax10,
  COALESCE(ti.ivd_rated_qty,0), -- PTS 58737 SGB
  COALESCE(ti.ivd_rated_rate,0),	-- PTS 58737 SGB
  COALESCE(ti.dbst_rollinto_tar,0),	-- PTS 58737 SGB
  ti.ivd_customer_char1   -- 63734
from  @temp_inv ti  
order by ivh_hdrnumber,ivd_sequence /* ###### debug only */  

GO
GRANT EXECUTE ON  [dbo].[d_inv_edit_detail_sp] TO [public]
GO
