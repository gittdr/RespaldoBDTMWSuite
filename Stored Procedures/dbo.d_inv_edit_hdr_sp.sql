SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[d_inv_edit_hdr_sp] ( @stringparm             varchar(12),
								@numberparm             int,
								@retrieve_by   		varchar(8),
								@process           varchar(10),
								@paperworkmarked	varchar(3),
				        		@FromOrder char(1),
                @P_prerating  char(1) 
        )
as
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
  Type INVOICE
     inv_hdr is called with stringparm of invoice number and "INVNUM"
     inv_det is called with number parm of ivh_hdrnumber and "INVHDR"
  Type MOVE (called once for order selected from the move. Application changed
      to list orders by billto for the move and add an indication that the mov number can
      be found in the invoicemaster) 
      (1) if an order is select that has the invoicemaster flag on call
          this proc with the order number on the invoicemaster 
      (2) if the order does not have the invoicemaster flag set call proc with
          selected order number.
  Type Master Bill# (called once for each invoice in the master bill list)
      Calls are same as for invoice number lookup
Sample calls

execute dbo.d_inv_edit_hdr_sp   @stringparm = '4005506', @numberparm = -1, @retrieve_by = 'ORDNUM', @process = 'x', @paperworkmarked = 'ONE', @FromOrder = 'N', @P_prerating = 'N'
*/


/****** Object:  Stored Procedure dbo.d_inv_edit_hdr_spz    updatet Date: 5/29/00 10:30:12 PM ******/
/* jyang pts7945 change  d_notes_check_sp execute mode to 1, so need driver,tractor,trailer, carrier
 as parameter for @notes_count
   dpete pys8760 add ivh_ratingquantity and ivh_ratingunit to return set
  dpete pts11059 provide a mileage add on for G&RG for computing charges
10/22/2001	Vern Jewett (label=vmj1)	PTS 11668, DD&S Express:  support "All-Inclusive" billing feature.
	dpete pts12523 add rate_type to return set
	dpete PTS12600 add contact name to return set (add invoice type just to remove funciton from the datawindow)
 2/26/02 dpete pts 13279 Add ivh_cmrbill_link (ivh_hdrnumber pointer to record this is a credit or rebill of)
 02/27/02 dpete pts 13099 Return cmp_min_charge for bill to company
3/20/02 dpete pts 13099 getting subquery returning more than one row error on multi invoice orders.  Adjust setting min charge from subcompany
6/17/02 14486 Dpete Remove 'CAN$' as the default for ord_currency
DPETE 17751 Add ivh_mileage_adj_pct to return set
19362 DPETE add argument for rebill from order to retrieve from order regardless of presence of invoice data  
DPETE 23957 add trlconfiguration to return set
DPETE PTS25273 return ord_mileagetable
LOR	PTS# 26547 return ord_rate_mileagetable instead
PTS 26793 (recode 20297) - DJM - Added the localization settings for the Origin/Destination of the Order
LOR	PTS# 15776	add trltype1-4
DPETE 33614 add ordboookdate to return set for tax effective date
EMK 34878 Moved from order select to main select because it is needed in queues
EMK 36869 Added check for required field when checking paperwork counts
DPETE 39359 performance issues
       39280 consolidated to 39359 customer wants to see "Dispatch" (last HLT arrival date on invioce
LOR	PTS# 38776	add ivh_exchangerate
EMK 38823 Add loaded and empty miles for trimac.
DPETE 40260 Pauls recode (plus added code for JFALL)
      recode DPETE 23776  add ivh_nomincharges to return
      recode DPETE PH28283  add cmp_splibillonrefnbr
      recode DPETE PTS30355 add ivh_billto_addrtype and multi addr on flag  to return set
      recode DPETE PTS30583 add ord_no_recalc_miles flag to return set
DPETE 43837 Invoice by move changes (remove paperwork chaecks. All done from w_inv_edit calls to procs
SGB PTS 45309  Add isnull to cmp_min_charge when updating #temp
 DPETE PTS 44417 invoice by move / consignee
 DPET PTS46700 stopped working for invoice by move with the ansii nulls off setting of gorgo
  DPETE PTS 47148 (47895) Kenan process is creating a ref nubmer for hte order without updating the order ref ino
  SGB PTS 49466 changed logic to switch from Invoice lookup to Order lookup to populate @stringparm instead of @numberparm
  PTS48966 step 2 in moving rating to nvo that can be used by order entry
      handle bringing back the correct assets and all assets
      add fields   ivh_trailer2 (new field)
      Add argument to indicate pre rating is being done to remove requirement that order be invoicable
      If company invoices by move and we are pre rating, change the option to invoice by order
1/19/10 PTS 50347 (cons 48966) billing quantity appears to hav emany decimal places when it comes for Order Entry
      with 2 a billing quty of 14.16 will come throu to Invoicing as 14.159999999
PMILL 49221 some information is needed for rating when running through QUEUE
 9/14/10 DPETE PTS46534 Mileer does nto want to create invoice if no Line haul charge is on order.
 vjh 53851 add ivh_reprint
 SGB 60008 add dbh_id 11/10/11 REMEMBER REQUIRES PTS52067
 SGB 61225 check for ord_charge fails if it is null
 * NQIAO PTS# 58978  to retrieve 3 new fields (ord_ratemode, ord_servicelevel, ord_servicedays) from orderheader table.
 *                   If it's a miscellaneous invoice set all 3 to null
 * NQIAO PTS# 63136	 output dedbillingheader.dbh_custinvnum for dedicated invoices.
MTC PTS#70754 Changed 2 temp tables to table variables to reduce/eliminate chronic recompilation due to stats updates on temp objects
PTS 102044 - for 3PL Allocate only invoice
PTS 94775 - Added columns for invoice and rollinto LH totals
*/

declare @temp table  (
ivh_invoicenumber char(12) null, 
ivh_billto char(8) null,
ivh_terms char(3) null, 
ivh_totalcharge money null,    
ivh_shipper char(8) null, 
ivh_consignee char(8) null, 
ivh_originpoint char(8) null,    
ivh_destpoint char(8) null, 
ivh_invoicestatus char(6) null, 
ivh_origincity int null,     
ivh_destcity int null, 
ivh_originstate varchar(6) null, 
ivh_deststate varchar(6) null,      
ivh_originregion1 char(6) null, 
ivh_destregion1 char(6) null, 
ivh_supplier char(8) null,       
ivh_shipdate datetime null, 
ivh_deliverydate datetime null, 
ivh_revtype1 char(6) null,       
ivh_revtype2 char(6) null, 
ivh_revtype3 char(6) null, 
ivh_revtype4 char(6) null, 
ivh_totalweight float(15)  null, 
ivh_totalpieces float(15) null, 
ivh_totalmiles float(15) null,     
ivh_currency char(6) null,
ivh_currencydate datetime null, 
ivh_totalvolume float(15) null,    
ivh_taxamount1 money null, 
ivh_taxamount2 money null,       
ivh_taxamount3 money null, 
ivh_taxamount4 money null,
ivh_transtype char(6) null,
ivh_creditmemo char(1) null,     
ivh_applyto char(12) null, 
ivh_printdate datetime null, 
ivh_billdate datetime null, 
ivh_lastprintdate datetime null,   
ivh_hdrnumber int null, 
ord_hdrnumber int null, 
ivh_originregion2 char(6) null,  
ivh_originregion3 char(6) null, 
ivh_originregion4 char(6) null, 
ivh_destregion2 char(6) null,    
ivh_destregion3 char(6) null, 
ivh_destregion4 char(6) null, 
ivh_mbnumber int null, 
ivh_remark char(254) null, 
ivh_driver char(8) null, 
ivh_driver2 char(8) null, 
ivh_tractor char(8) null,
ivh_trailer char(13) null, 
mov_number int null, 
ivh_edi_flag char(30) null,
revtype1 char(8) null, 
revtype2 char(8) null, 
revtype3 char(8) null, 
revtype4 char(8) null, 
ivh_freight_miles float null, 
ivh_priority char(6) null,
ivh_low_temp int null,
ivh_high_temp int null,
events_count int null,
comments_count int null,
notes_count int null,
loadreq_count int null,
ref_count int null,
paperwork_required int null,
paperwork_received int null,
ivh_order_by char(8) null,
tar_tarriffnumber char(12) null, 
tar_number int null, 
ivh_user_id1 char(20) null, 
ivh_user_id2 char(20) null, 
ivh_ref_number char(30) null,
invoiceheader_ivh_bookyear int null,
invoiceheader_ivh_bookmonth int null,
tar_tariffitem char(12) null,
ivh_mbstatus char(6) null,
calc_maxstatus char(6) null,
ord_number char(12) null,
ivh_quantity decimal(18,6) null,   --float(15) null,
ivh_rate money  null, -- was decimal (4) jude 4/29/97 
ivh_charge money null,-- was decimal (4) jude 4/29/97 
cht_itemcode char(6) null,
ivh_splitbill_flag char(1) null,
dummy_ordstatus char(6) null,
ivh_company char(8) null,
ivh_carrier char(8) null,
ivh_archarge money null,-- was decimal (4) jude 4/29/97 
ivh_arcurrency char(6) null,
ivh_loadtime int null,
ivh_unloadtime int null,
ivh_drivetime int null,
ivh_totaltime int null,
ivh_rateby char(1) null,
ivh_unit char(6) null,
ivh_rateunit char(6) null,
lgh_count int NULL,
ord_remark char(254) null,
billto_altid	varchar(25) null,
ivh_revenue_date datetime null,
ivh_batch_id	varchar(10) null,
mailto_flag char(1) null,
ivh_stopoffs smallint null,
--vmj1+
ivh_quantity_type int null,
--ivh_quantity_type smallint null,
--vmj1-
ivh_charge_type smallint null,
ivh_originzipcode varchar(10) null, 
ivh_destzipcode varchar(10) null,
--vmj1+
trc_type4 varchar(8) null,
--trc_type4 varchar(6) null,
--vmj1-
opt_trc_type4 varchar(20) null,
--vmj1+
trl_type4 varchar(8) null,
--trl_type4 varchar(6) null,
--vmj1-
opt_trl_type4 varchar(20) null,
ivh_ratingquantity   decimal(18,6) null,   --float(15) null,
ivh_ratingunit varchar(6)null,
ivh_definition varchar(6) null,
ivh_applyto_definition varchar(6) null,
ivh_hideshipperaddr char(1) null,
ivh_hideconsignaddr char(1) null,
ivh_showshipper varchar(8) null,
ivh_showcons varchar(8) null,
ivh_mileage_adjustment decimal(9,1) null,
ivh_paperworkstatus varchar(6) null,
ivh_order_cmd_code varchar(8) null,
--vmj1+
ivh_allinclusivecharge	money	null,
all_inclusive_indc		char(1)	null,
--vmj1-
ivh_reftype varchar(6) null,
ivh_attention char(254) null,
ivh_rate_type smallint null,
billto_cmp_contact varchar(30) null,
ivh_paperwork_override char(1) null,
ivh_cmrbill_link int null,
cmp_min_charge money null,
cmp_mastercompany varchar(8),	 
paperworkmarked varchar(3) null,
inv_revenue_pay_fix int null,
inv_revenue_pay money null,
ivh_block_printing char(1) null,
ivh_custdoc int null,
ivh_entryport varchar (8) null,
ivh_exitport varchar (8) null,
ivh_mileage_adj_pct dec(9,2) NULL,
ivh_pay_status char(1) null,
-- PTS 18878 -- BL (start)
ivh_paid_amount money null,
-- PTS 18878 -- BL (end)
-- PTS 32620 -- BL (start)
--ivh_dimfactor dec(9,4) NULL
ivh_dimfactor dec(12,4) NULL
-- PTS 32620 -- BL (end)
,ivh_trlconfiguration varchar(6) NULL
,ivh_trlconfiguration_t varchar(20) null
,ord_rate_mileagetable varchar(2) NULL
--PTS# 23583 ILB 02/14/2005
,ord_bookedby varchar(20) null
--PTS# 23583 ILB 02/14/2005
,ivh_charge_type_lh smallint null,
ivh_booked_revtype1 varchar(12) null,
branch_t varchar(15) null,
	origin_servicezone	varchar(6) 	NULL,
	origin_servicearea	varchar(6) 	NULL,
	origin_servicecenter	varchar(6) 	NULL,
	origin_serviceregion	varchar(6) 	NULL,
	dest_servicezone	varchar(6) 	NULL,
	dest_servicearea	varchar(6) 	NULL,
	dest_servicecenter	varchar(6) 	NULL,
	dest_serviceregion	varchar(6) 	NULL,
trl_type1			varchar(6) 	NULL,
trl_type1_name		varchar(8) 	NULL,
ord_trl_type2		varchar(6) 	NULL,
ord_trl_type2_name	varchar(8) 	NULL,
ord_trl_type3	varchar(6) 	NULL,
ord_trl_type3_name	varchar(8) 	NULL,
ord_trl_type4	varchar(6) 	NULL,
ord_trl_type4_name	varchar(8) 	NULL,
ord_fromorder	varchar(12) NULL,	
ivh_misc_number	varchar(12) NULL,
ord_bookdate datetime NULL, --os 4/17/07
ord_availabledate datetime NULL,	--pts 36001
ivh_exchangerate numeric (19, 4)  NULL ,
ivh_loaded_distance float NULL, --PTS 38823
ivh_empty_distance float NULL, --PTS 38823
stlmnt_amt	MONEY NULL, --PTS40482 MBR 01/18/08
ivh_paid_indicator char (1) null , --PTS 41235
ivh_lastchecknumber varchar (25) null, --PTS 41235
ivh_lastcheckamount money null, --PTS 41235
 ivh_totalpaid money null,         --PTS 41235
ivh_lastcheckdate datetime null, --PTS 41235
ivh_leaseid	int	NULL,
ivh_leaseperiodenddate datetime NULL
, ivh_gp_gl_postdate DATETIME NULL
, ivh_noMinCharges char(1) NULL
, orders_on_move varchar(256) NULL
,cmp_splitbillonrefnbr char(1) NULL
,multiaddrcount smallint NULL
,car_key int NULL
,ord_no_recalc_miles char(1) NULL
--PTS 51570 JJF 20100510
--,ivh_belongsto varchar(6) NULL	--PTS 42432 JJF 20080421
--END PTS 51570 JJF 20100510
,ivh_invoiceby varchar(3) NULL
,ordercount int null
,ivh_furthestpointconsignee  VARCHAR(8) NULL
,ord_roundbillqty int null  --48966
,ivh_trailer2 varchar(13) null  -- 48966
,ivh_reprint char(1) null
,ord_pallet_type	varchar(6) null
,ord_pallet_count	int null
,ivh_dbh_id int null -- 60008
,ord_ratemode			varchar(6)	null	-- 03/29/2012 NQIAO PTS 58978
,ord_servicelevel		varchar(6)	null	-- 03/29/2012 NQIAO PTS 58978
,ord_servicedays		int			null	-- 03/29/2012 NQIAO PTS 58978
,dbh_custinvnum			varchar(30) null	-- 08/01/2012 NQIAO PTS 63136
,ivh_gpserver			VARCHAR(25) NULL	--PTS69481 MBR 07/12/13
,ivh_gpdatabase			VARCHAR(25) NULL	--PTS69481 MBR 07/12/13
,ivh_splitgroup			VARCHAR(6)  NULL	-- PTS 63450 nloke
,ivh_donotprint			CHAR(1)     NULL        --PTS66727 MBR 11/04/13
,ord_miscqty decimal(12, 4) null --PTS63937 JJF 20120927
,ord_miscqty_t varchar(10) null --PTS63937 JJF 20120927
,ivh_subcompany varchar(8) null	--PTS87839 nloke 3/4/2015
,ivh_lh_charge	money null	--PTS 94775 nloke
,ivh_lh_charge_with_rollin	money null	--PTS 94775 nloke
,ivh_rollin_lh_rate decimal(12,4) null	--PTS 94775 nloke
)

declare @calcmaxstat		varchar(6), 
	@dummydate              datetime, 
	@remarks                varchar(254), 
	@fill6                  varchar(6), 
	@fill3                  varchar(3), 
	@fill13                 varchar(13),    
	@fill8                  varchar(8),     
	@fill20                 varchar(20), 
	@edi                    varchar(30), 
	@invnum                 varchar(12), 
	@comments_count         int,
	@notes_count            int,
	@loadreq_count          int,
	@ref_count              int,
	@pwork_req_count        int,
	@pwork_rec_count        int,
	@lgh_count		int, 
	@vchar6			varchar(6),
	@ish_status		char(3),
	@min_date		int,
	@billto_altid		varchar(8),
	@ivh_revenue_date 	datetime,
	@ivh_batch_id		varchar(10),
	@first_invoice_number	varchar(12),
	@first_origin		varchar(8),
	@first_dest		varchar(8),
	@first_billto		varchar(8),
	@mov_number		int,
	@ord_hdrnumber		int,
	@invoicecount           int,
	@ivhhdrnumber		int,
	@driver          varchar(8),
	@driver2         varchar(8),
	@tractor         varchar(8),
	@trailer         varchar(13),
	@carrier         varchar(8),
	@contact			varchar(30),
	@cmpmincharge  money,
	@master varchar(8),
	@delivery_date 		varchar(25),
	@cons_date 		datetime,
	@paperworkmode		char(1),
	@o_servicezone 		varchar(6),
	@o_servicecenter 	varchar(6),
	@o_serviceregion 	varchar(6),
	@o_sericearea 		varchar(6),
	@dest_servicezone 	varchar(6),
	@dest_servicecenter	varchar(6),
	@dest_serviceregion 	varchar(6),
	@dest_sericearea 	varchar(6),
	@service_revtype	varchar(12),
	@localization		varchar(6),
	@misc			varchar(12),
    @v_ordbookdate datetime,
    @v_npeventcount  int,  -- 39359
    @v_lastHLTarrivaldate datetime, -- 39280 (cons with 39359)
    @v_CmpFieldForRequireLHFlag  varchar(50), --46534
    @v_LHChargerequired char(1)   --46534
--PTS 40929 JJF 20071211
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510
--PTS 40929 JJF 29971211
declare @cmpinvoiceby varchar(3),@movnumber int ,@billto varchar(8),@firstpupstp int ,@lastdrpstp int,@firstleg int,@ordscount int
declare  @ordsoninvoice table (ord_hdrnumber int null,ord_number varchar(12) null)
declare @billdoctypesforbillto table (bdt_doctype varchar(6) )
declare @tempparm int
declare @firstpup_cmpid varchar(8), @lastdrop_cmpid varchar(8),@firstpup_stp_city int,@lastdrop_stp_city int
declare @firstpup_stp_state varchar(6),@lastdrop_stp_state varchar(6),@firstpup_stp_arrivaldate datetime
declare @lastdrop_stp_arrivaldate datetime,@lgh_driver1 varchar(8),@lgh_driver2 varchar(8),@lgh_tractor varchar(8)
declare @lgh_primary_trailer varchar(13),@sum_ord_totalweight float,@sum_ord_totalvolume float,@sum_ord_totalcount dec(9,2)
declare @sum_ord_totalcharge money,@sum_ord_charge money,@sum_ord_accessorial_chrg money
declare @consignee varchar(8), @minord varchar(12), @maxord varchar(12)
declare @ordrefnum varchar(30),@ordreftype varchar(6)  --47148 (47895)
declare @tempordparm varchar(12) -- 49466 SGB
declare @driver1 varchar(8),@trailer2 varchar(13),@trailer1 varchar(13)
declare @UseMaxOrderOnMov char(1)
declare @subcharge MONEY

select @ordscount = 0
declare  @temp_hdr table (ivh_hdrnumber int primary key)		--	LOR	PTS# 33517


select @v_npeventcount = 0 --  39359

/* used when bringing back an order for invoicing */
select @driver1 = 'UNKNOWN'
,@driver2 = 'UNKNOWN'
,@tractor = 'UNKNOWN'
,@trailer = 'UNKNOWN'
,@trailer2 = 'UNKNOWN'
,@carrier = 'UNKNOWN'

select @delivery_date = gi_string1 from generalinfo where gi_name = 'InvDeliveryDate'
Select @FromOrder = UPPER(IsNull(@Fromorder,'N'))
/*  43837 ppwk processing taking out of htis proc
-- KM PTS 16282
SELECT 	@paperworkmode = IsNull(gi_string1, 'A')
FROM	generalinfo
WHERE	gi_name = 'PaperWorkMode'
-- END PTS 16282
*/

/*	PTS 26793 - DJM - Determine if Localization values should be calculated			*/
select @localization = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'ServiceLocalization'

select @UseMaxOrderOnMov = Upper(LTRIM(RTRIM(isNull(gi_string1,'N')))) from generalinfo where gi_name = 'InvoiceMaxOrderOnMove'

/* 46534 provide default value of field to a field that would never hold the flag value we are looking for */
Select @v_LHChargerequired = 'N'

/* retrieve is by invoice number and invoice is for an order, switch to order lookup */

IF @retrieve_by = 'INVNUM'
   BEGIN
	 --SELECT @tempparm = ord_hdrnumber,@cmpinvoiceby = isnull(ivh_invoiceby,'ORD')PTS 49466 add ord_number
	 SELECT @tempparm = ord_hdrnumber,@tempordparm = ord_number, @cmpinvoiceby = isnull(ivh_invoiceby,'ORD')
	 FROM  invoiceheader
     WHERE ivh_invoicenumber = @stringparm

     If @tempparm > 0 
       BEGIN
         --Select @numberparm = @tempparm PTS 49466 SGB @numberparm is repopulated based on value in @stringparm
         Select @stringparm = @tempordparm
         Select @retrieve_by = 'ORDNUM'
       END
   END
-- initialize invoicecount
select @invoicecount = 0
-- determine the ord_hdrnumber and the invoice count		
IF @retrieve_by = 'ORDNUM'
   BEGIN
      select  @v_CmpFieldForRequireLHFlag = gi_string1
      from generalinfo where gi_name = 'CompanyDoNotBillWithoutLHField'
      Select @v_CmpFieldForRequireLHFlag = isnull(@v_CmpFieldForRequireLHFlag,'')  -- again set to fake field if null

	  SELECT @numberparm = ord_hdrnumber ,@contact = ISNULL(ord_contact,''),@v_ordbookdate = ord_bookdate,
    @cmpinvoiceby = isnull(cmp_invoiceby,'ORD'),@billto = ord_billto,@movnumber = mov_number,@consignee = ord_consignee
    ,@v_LHChargerequired = case @v_CmpFieldForRequireLHFlag
       when 'MISC1' then Case left(cmp_misc1,5) when 'LHREQ' then 'Y' else 'N' end
	   when 'MISC2' then Case left(cmp_misc2,5) when 'LHREQ' then 'Y' else 'N' end
       when 'MISC3' then Case left(cmp_misc3,5) when 'LHREQ' then 'Y' else 'N' end
       when 'MISC4' then Case left(cmp_misc4,5) when 'LHREQ' then 'Y' else 'N' end
       when 'OTHERTYPE1' then Case left(cmp_othertype1,5) when 'LHREQ' then 'Y' else 'N' end
       when 'OTHERTYPE2' then Case left(cmp_othertype2,5) when 'LHREQ' then 'Y' else 'N' end
       else 'N'
       END
	  FROM orderheader join company on ord_billto = cmp_id 
	  WHERE ord_number = @stringparm

    if @p_prerating = 'Y' select @cmpinvoiceby  = 'ORD'  /*  Assume invoice by order when pre rating */
		  
    SELECT @numberparm = ISNULL(@numberparm,-1),@cmpinvoiceby = isnull(@cmpinvoiceby,'ORD')
    /* (invoice exists for order) if invoice exists for this order go ahead and retrieve it */
    if exists (select 1 from invoiceheader where ord_hdrnumber = @numberparm) and 
       not exists (select 1 from invoicemaster 
                   where ord_hdrnumber = @numberparm and ivm_invoiceby in ('MOV','CON')) --= 'MOV')
       BEGIN
         select @ordscount = 1   -- for PPWK
         Insert into @ordsoninvoice(ord_hdrnumber) select @numberparm
       END
    else
       /* (invoice exists for move) if a record exists in the invoicemaster redirect the lookup to the order on 
          the invoice by move */
      if exists (select 1 from invoicemaster 
                 where ord_hdrnumber = @numberparm and ivm_invoiceby in ('MOV','CON')) -- = 'MOV')
         BEGIN
            Select @numberparm = ivm_invoiceordhdrnumber
            from invoicemaster IM 
            where ord_hdrnumber = @numberparm 

            Insert into @ordsoninvoice(ord_hdrnumber)  select ord_hdrnumber from invoicemaster where  ivm_invoiceordhdrnumber = @numberparm
            Select @ordscount = count(*) from @ordsoninvoice   -- for PPWK
         END
      else
        BEGIN
         /* (no invoice exists) if the bill to company on this order invoice by order go ahead with order lookup */
         If @cmpinvoiceby = 'ORD'
            BEGIN 
               SELECT @numberparm = @numberparm  -- go ahead with retrieve
               
               SELECT @firstpupstp = (select top 1 stp_number
                 from stops 
                 where ord_hdrnumber = @numberparm
                 and stp_type = 'PUP'
                 order by stp_mfh_sequence)
                 
                SELECT @firstleg = lgh_number from stops where stp_number =  @firstpupstp

                SELECT @lastdrpstp = (select top 1 stp_number
                 from stops
                 where ord_hdrnumber = @numberparm
                 and stp_type = 'DRP'
                 order by stp_mfh_sequence desc)

                INSERT into @ordsoninvoice (ord_hdrnumber) select @numberparm
                SELECT @ordscount = count(*) from @ordsoninvoice   -- for PPWK
            END 
        -- else
         If @cmpinvoiceby = 'MOV'
           BEGIN
        /* if the bill to company invoices by mov and none of the orders for the bill to
           on the move are still in pending invoice status */
           if (Select count(*) from orderheader 
                where mov_number = @movnumber 
                and ord_billto = @billto
                and ord_invoicestatus = 'PND') = 0
              BEGIN

                 insert into @ordsoninvoice(ord_hdrnumber,ord_number)
                 select ord_hdrnumber,ord_number
                 from orderheader
                 where mov_number = @movnumber
                 and ord_billto = @billto
                 --and ord_invoicestatus = 'AVL' PTS 52349 SGB
                 and ord_invoicestatus in  ('AVL','AUT')
/*
                 select @numberparm = min(ord_hdrnumber) from orderheader 
                 where mov_number = @movnumber 
                 and ord_billto = @billto
                 and ord_invoicestatus = 'AVL'  -- do not pick up an XIN order
 */ 
				 if @UseMaxOrderOnMov = 'Y'
				 begin
					 select @maxord = max(ORD_NUMBER) from @ordsoninvoice

					 select @numberparm = ord_hdrnumber
					 from @ordsoninvoice
					 where ord_number = @maxord
				 end
				 else
				 begin 
					 select @minord = min(ORD_NUMBER) from @ordsoninvoice

					 select @numberparm = ord_hdrnumber
					 from @ordsoninvoice
					 where ord_number = @minord
				 end 
				
                 select @firstpupstp = (select top 1 stp_number
                 from @ordsoninvoice ords
                 join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
                 where stp_type = 'PUP'
                 order by stp_mfh_sequence)

                 select @lastdrpstp = (select top 1 stp_number
                 from @ordsoninvoice ords
                 join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
                 and stp_type = 'DRP'
                 order by stp_mfh_sequence desc)
                 
                 select  @firstpup_cmpid = cmp_Id,@firstpup_stp_city = stp_city ,@firstpup_stp_state  = stp_state,
                 @firstpup_stp_arrivaldate = stp_arrivaldate,@firstleg = lgh_number
                 from stops where stp_number =  @firstpupstp

                 select  @lastdrop_cmpid = cmp_Id,@lastdrop_stp_city = stp_city ,@lastdrop_stp_state  = stp_state ,
                 @lastdrop_stp_arrivaldate = stp_arrivaldate
                 from stops where stp_number =  @lastdrpstp
                 
                  
                 select @lgh_driver1 = lgh_driver1,@lgh_driver2 = lgh_driver2,@lgh_tractor = lgh_tractor,
                 @lgh_primary_trailer= lgh_primary_trailer
                 from legheader where lgh_number = @firstleg

                 select @sum_ord_totalweight =  (select sum(ord_totalweight) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalvolume =  (select sum(ord_totalvolume) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalcount =  (select sum(ord_totalpieces) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalcharge =  (select sum(ord_totalcharge) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_charge =  (select sum(ord_charge) from  @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_accessorial_chrg =  (select sum(ord_accessorial_chrg) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)

/*
                 ,@sum_ord_totalvolume = sum(ord_totalvolume),
                 @sum_ord_totalcount= sum(ord_totalcount),@sum_ord_totalcharge sum(ord_totalcharge),
                 @sum_ord_charge = sum(ord_charge),@sum_ord_accessorial_chrg = sum(ord_accessorial_chrg)
                 from orderheader where mov_number = @movnumber and ord_invoicestatus = 'AVL'
                 group by @movnumber
               
                 INSERT into @ordsoninvoice select distinct ord_hdrnumber from orderheader 
                 where mov_number = @movnumber and ord_invoicestatus = 'AVL'
 */ 
                 select @ordscount = count(*) from @ordsoninvoice  -- for PPWK
              END 
            Else
              /* invoice by is move and not all orders are ready; ensure nothing is found */
              BEGIN
                 select @numberparm = -1
              END
           END
     If @cmpinvoiceby = 'CON'
           BEGIN
        /* if the bill to company invoices by mov and none of the orders for the bill to
           on the move are still in pending invoice status */
           if (Select count(*) from orderheader 
                where mov_number = @movnumber 
                and ord_billto = @billto
                and ord_consignee = @consignee
                and ord_invoicestatus = 'PND') = 0  -- all orders must be ready to invoice
              BEGIN

                 insert into @ordsoninvoice(ord_hdrnumber,ord_number)
                 select ord_hdrnumber,ord_number
                 from orderheader
                 where mov_number = @movnumber
                 and ord_billto = @billto
                 and ord_consignee = @consignee
                 -- and ord_invoicestatus = 'AVL' PTS 52349 SGB
                 and ord_invoicestatus in ('AVL','AUT')
                 -- elect to put the min ord number on the invoice
  
  				 if @UseMaxOrderOnMov = 'Y'
  				 begin
					 select @maxord = max(ORD_NUMBER) from @ordsoninvoice

					 select @numberparm = ord_hdrnumber
					 from @ordsoninvoice
					 where ord_number = @maxord
  				 end
  				 else
  				 begin
					 select @minord = min(ORD_NUMBER) from @ordsoninvoice

					 select @numberparm = ord_hdrnumber
					 from @ordsoninvoice
					 where ord_number = @minord
  				 end
           
                 select @firstpupstp = (select top 1 stp_number
                 from @ordsoninvoice ords
                 join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
                 where stp_type = 'PUP'
                 order by stp_mfh_sequence)

                 select @lastdrpstp = (select top 1 stp_number
                 from @ordsoninvoice ords
                 join stops on ords.ord_hdrnumber = stops.ord_hdrnumber
                 and stp_type = 'DRP'
                 order by stp_mfh_sequence desc)
                 
                 select  @firstpup_cmpid = cmp_Id,@firstpup_stp_city = stp_city ,@firstpup_stp_state  = stp_state,
                 @firstpup_stp_arrivaldate = stp_arrivaldate,@firstleg = lgh_number
                 from stops where stp_number =  @firstpupstp

                 select  @lastdrop_cmpid = cmp_Id,@lastdrop_stp_city = stp_city ,@lastdrop_stp_state  = stp_state ,
                 @lastdrop_stp_arrivaldate = stp_arrivaldate
                 from stops where stp_number =  @lastdrpstp
                  
                 select @lgh_driver1 = lgh_driver1,@lgh_driver2 = lgh_driver2,@lgh_tractor = lgh_tractor,
                 @lgh_primary_trailer= lgh_primary_trailer
                 from legheader where lgh_number = @firstleg

                 select @sum_ord_totalweight =  (select sum(ord_totalweight) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalvolume =  (select sum(ord_totalvolume) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalcount =  (select sum(ord_totalpieces) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_totalcharge =  (select sum(ord_totalcharge) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_charge =  (select sum(ord_charge) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)
                 select @sum_ord_accessorial_chrg =  (select sum(ord_accessorial_chrg) from @ordsoninvoice ords
                  join orderheader on ords.ord_hdrnumber = orderheader.ord_hdrnumber)

                 select @ordscount = count(*) from @ordsoninvoice  -- for PPWK req multipier
              END 
            Else
              /* invoice by is by move / consigneeand not all orders are ready; ensure nothing is found */
              BEGIN
                 select @numberparm = -1
              END
           END
      END
   END

IF @retrieve_by = 'INVNUM'
   BEGIN
	SELECT @numberparm = ord_hdrnumber,
			@misc = IsNull(ivh_misc_number, '')		-- LOR	PTS# 33517
	FROM  invoiceheader
	WHERE  ivh_invoicenumber = @stringparm
	IF @numberparm IS NOT NULL
	  BEGIN
		 If @numberparm > 0 
			Select @contact = ord_contact,@v_ordbookdate = ord_bookdate From orderheader Where ord_hdrnumber = @numberparm
	    SELECT @invoicecount = 1
	  END
	SELECT @numberparm = ISNULL(@numberparm,0)

--	LOR	PTS# 33517
	If @misc <> ''
		INSERT INTO @temp_hdr
		SELECT ihm_hdrnumber 
		FROM invoiceheader_misc 
		WHERE ihm_misc_number = @misc
		GROUP BY ihm_hdrnumber
--	LOR
   END
/* 39280 (cons to 39359) customer SR to see the arrival at the last HLT on an order */
If @numberparm > 0
  Select @v_lastHLTarrivaldate = max(stp_arrivaldate)
  from stops where lgh_number in (select lgh_number from stops where ord_hdrnumber = @numberparm and ord_hdrnumber > 0 and stp_type = 'DRP')
  and stp_event = 'HLT'

 -- If we do not yet know if the invoice exist(retreive is by ORDNUM or ORDHDR), check for it
--IF @retrieve_by <> 'INVNUM'  AND    @numberparm > 0  
IF @retrieve_by <> 'INVNUM'  AND    @numberparm > 0 AND @FromOrder = 'N'  
   BEGIN 
	SELECT @invoicecount = count(*)
        FROM   invoiceheader
        WHERE  ord_hdrnumber = @numberparm
   END

-- if the invoice exists, retrieve it
if @invoicecount > 0 
   BEGIN
	If @retrieve_by = 'INVNUM' and @numberparm = 0 and @misc <> '' and 
			(select count(*) from @temp_hdr) > 0
	INSERT into @temp
	SELECT i.ivh_invoicenumber, 
		i.ivh_billto, 
		i.ivh_terms, 
		i.ivh_totalcharge, 
		i.ivh_shipper, 
		i.ivh_consignee,    
		i.ivh_originpoint, 
		i.ivh_destpoint, 
		i.ivh_invoicestatus,        
		i.ivh_origincity, 
		i.ivh_destcity, 
		i.ivh_originstate,  
		i.ivh_deststate, 
		i.ivh_originregion1, 
		i.ivh_destregion1,  
		i.ivh_supplier, 
		i.ivh_shipdate, 
		i.ivh_deliverydate, 
		i.ivh_revtype1, 
		i.ivh_revtype2, 
		i.ivh_revtype3, 
		i.ivh_revtype4, 
		i.ivh_totalweight, 
		i.ivh_totalpieces,  
		i.ivh_totalmiles, 
		i.ivh_currency, 
		i.ivh_currencydate,         
		i.ivh_totalvolume, 
		i.ivh_taxamount1, 
		i.ivh_taxamount2,   
		i.ivh_taxamount3, 
		i.ivh_taxamount4, 
		i.ivh_transtype,    
		i.ivh_creditmemo, 
		i.ivh_applyto,      
		i.ivh_printdate, 
		i.ivh_billdate, 
		i.ivh_lastprintdate,        
		i.ivh_hdrnumber, 
		i.ord_hdrnumber, 
		i.ivh_originregion2,        
		i.ivh_originregion3, 
		i.ivh_originregion4, 
		i.ivh_destregion2,  
		i.ivh_destregion3, 
		i.ivh_destregion4, 
		i.ivh_mbnumber, 
		i.ivh_remark,
		i.ivh_driver,       
		i.ivh_driver2, 
		i.ivh_tractor, 
		i.ivh_trailer,      
		i.mov_number ,
		i.ivh_edi_flag, 
		'RevType1', 
		'RevType2', 
		'RevType3',    
		'RevType4', 
		i.ivh_freight_miles ,
		i.ivh_priority ,    
		i.ivh_low_temp, 
		i.ivh_high_temp , 
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		i.ivh_order_by, 
		i.tar_tarriffnumber,        
		i.tar_number , 
		i.ivh_user_id1, 
		i.ivh_user_id2 ,    
		i.ivh_ref_number, 
		i.ivh_bookyear, 
		i.ivh_bookmonth, 
		i.tar_tariffitem, 
		i.ivh_mbstatus, 
		@calcmaxstat, 
		i.ord_number, 
		i.ivh_quantity, 
		i.ivh_rate, 
		i.ivh_charge, 
		i.cht_itemcode, 
		i.ivh_splitbill_flag, 
		@calcmaxstat,
		i.ivh_company,
		i.ivh_carrier,
		i.ivh_archarge,
		i.ivh_arcurrency,
		i.ivh_loadtime,
		i.ivh_unloadtime,
		i.ivh_drivetime,
		i.ivh_totaltime,
		i.ivh_rateby,
		i.ivh_unit,
		@vchar6,
		0,
		@remarks,
		c.cmp_altid,
		i.ivh_revenue_date,
		i.ivh_batch_id,
		mailto_flag =
		 	CASE ISNULL(c.cmp_mailto_name,'')
			   		WHEN '' THEN 'N'
			   			ELSE 'Y'
		 	END,
		i.ivh_stopoffs,
		ISNULL(ivh_quantity_type,0),
		ISNULL(ivh_charge_type,0), 
                ivh_originzipcode, 
                ivh_destzipcode,
		'TrcType4',
		'',
		'TrlType4',
		'',
		ivh_ratingquantity = ISNULL(i.ivh_ratingquantity,ivh_quantity),
		ivh_ratingunit = ISNULL(i.ivh_ratingunit,'UNK'),
		ivh_definition,
		IsNull(i.ivh_applyto_definition,''),
		i.ivh_hideshipperaddr,
		i.ivh_hideconsignaddr,
		-- PTS 14198 - DJM - Default shipper/consigneed if 'ivh_show..' fields are null
		isNull(ivh_showshipper, ivh_shipper) ivh_showshipper,
		isnull(ivh_showcons,ivh_consignee) ivh_showcons,
		ISNULL(ivh_mileage_adjustment,0),
		IsNull(i.ivh_paperworkstatus,'UNK'),
		ivh_order_cmd_code,
		--vmj1+
		isnull(ivh_allinclusivecharge, 0.0),
		'Y',
		--vmj1-
		ivh_reftype,
		ivh_attention,
		ivh_rate_type = IsNull(ivh_rate_type,0),
		@contact,
		ivh_paperwork_override,
		IsNUll(ivh_cmrbill_link,0) ivh_cmrbill_link,
		IsNull(c.cmp_min_charge,0),
		IsNull(c.cmp_mastercompany,'UNKNOWN') cmp_mastercompany,
		@paperworkmarked,
                inv_revenue_pay_fix,
                inv_revenue_pay,
		i.ivh_block_printing,
		i.ivh_custdoc,
		i.ivh_entryport,
		i.ivh_exitport,
		IsNull(ivh_mileage_adj_pct,0),
		i.ivh_pay_status,
		-- PTS 18878 -- BL (start)
		i.ivh_paid_amount,
		-- PTS 18878 -- BL (end)
		i.ivh_dimfactor 
      		,i.ivh_trlconfiguration
		,ivh_trlconfiguration_t = 'TrlConfiguration'
		,ord_rate_mileagetable = '' -- used only for new invoices
		--PTS# 23583 ILB 02/14/2005
                ,ord_bookedby = '',
		--PTS# 23583 ILB 02/14/2005
		ISNULL(ivh_charge_type_lh,0),
		IsNull(ivh_booked_revtype1, 'UNK'),
		'Branch',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'TrlType1',
		'UNK',
		'TrlType2',
		'UNK',
		'TrlType3',
		'UNK',
		'TrlType4',
		'', --ord_fromorder		
		i.ivh_misc_number,
		'', --os 4/17/07
		'', -- ord_availabledate pts 36001
		ivh_exchangerate,
		i.ivh_loaded_distance,  --38823
		i.ivh_empty_distance,
		0,
                isnull (i.ivh_paid_indicator, 'U'), --PTS41325
		i.ivh_lastchecknumber, --PTS41325
		i.ivh_lastcheckamount, --PTS41325
		i.ivh_totalpaid,         --PTS41325
                i.ivh_lastcheckdate,--PTS41325 
		i.ivh_leaseid,
		i.ivh_leaseperiodenddate
        ,ivh_gp_gl_postdate  --40260
        ,ivh_nomincharges = IsNull(ivh_nomincharges,'N')   --40260
        ,''   --40260
         ,cmp_splitbillonrefnbr = IsNull(c.cmp_splitbillonrefnbr,'N')   --40260
        ,multiaddrcount = (Select count(*) from companyaddress where cmp_id = ivh_billto)   --40260
        ,car_key = IsNull(i.car_key,0)   --40260
        ,ord_no_recalc_miles = IsNull((Select  isnull(ord_no_recalc_miles,'N') from orderheader  o where i.ord_hdrnumber = o.ord_hdrnumber),'N')   --40260
        --PTS 51570 JJF 20100510
		--,i.ivh_belongsto				--PTS 42432 JJF 20080421
		--PTS 51570 JJF 20100510
        ,i.ivh_invoiceby
        ,@ordscount,
         	i.ivh_furthestpointconsignee
        ,999 ord_roundbillqty   --48966
	,ivh_trailer2   -- 48966
        ,ivh_reprint		--vjh 53851
        ,ord_pallet_type	
	,ord_pallet_count
        ,dbh_id          -- SGB 60008
        ,ord_ratemode		-- 03/29/2012 NQIAO PTS 58978
	,ord_servicelevel	-- 03/29/2012 NQIAO PTS 58978
	,ord_servicedays		-- 03/29/2012 NQIAO PTS 58978
	,null				-- 08/01/2012 NQIAO PTS 63136	dbh_custinvnum
	,i.ivh_gpserver		--PTS69481 MBR 07/12/13
	,i.ivh_gpdatabase	--PTS69481 MBR 07/12/13
	,i.ivh_splitgroup	-- PTS 63450 nloke
	,i.ivh_donotprint	--PTS66727 MBR 11/04/13		
	   ,o.ord_miscqty	--PTS 63937 JJF 20120927
	   ,'OrdMscQty1' --PTS63937 JJF 20120927
	   ,i.ivh_subcompany --PTS87839 nloke 3/4/2015
	   ,i.ivh_lh_charge	--PTS 94775 nloke
	   ,i.ivh_lh_charge_with_rollin -- PTS 94775 nloke
	   ,i.ivh_rollin_lh_rate --PTS 94775 nloke
	FROM invoiceheader i
	join company c on i.ivh_billto = c.cmp_id
	join  @temp_hdr m on i.ivh_hdrnumber = m.ivh_hdrnumber
	left outer join orderheader o on i.ord_hdrnumber = o.ord_hdrnumber
	--WHERE i.ivh_hdrnumber = m.ivh_hdrnumber And c.cmp_id = ivh_billto 

   Else
	INSERT into @temp
	SELECT i.ivh_invoicenumber, 
		i.ivh_billto, 
		i.ivh_terms, 
		i.ivh_totalcharge, 
		i.ivh_shipper, 
		i.ivh_consignee,    
		i.ivh_originpoint, 
		i.ivh_destpoint, 
		i.ivh_invoicestatus,        
		i.ivh_origincity, 
		i.ivh_destcity, 
		i.ivh_originstate,  
		i.ivh_deststate, 
		i.ivh_originregion1, 
		i.ivh_destregion1,  
		i.ivh_supplier, 
		i.ivh_shipdate, 
		i.ivh_deliverydate, 
		i.ivh_revtype1, 
		i.ivh_revtype2, 
		i.ivh_revtype3, 
		i.ivh_revtype4, 
		i.ivh_totalweight, 
		i.ivh_totalpieces,  
		i.ivh_totalmiles, 
		i.ivh_currency, 
		i.ivh_currencydate,         
		i.ivh_totalvolume, 
		i.ivh_taxamount1, 
		i.ivh_taxamount2,   
		i.ivh_taxamount3, 
		i.ivh_taxamount4, 
		i.ivh_transtype,    
		i.ivh_creditmemo, 
		i.ivh_applyto,      
		i.ivh_printdate, 
		i.ivh_billdate, 
		i.ivh_lastprintdate,        
		i.ivh_hdrnumber, 
		i.ord_hdrnumber, 
		i.ivh_originregion2,        
		i.ivh_originregion3, 
		i.ivh_originregion4, 
		i.ivh_destregion2,  
		i.ivh_destregion3, 
		i.ivh_destregion4, 
		i.ivh_mbnumber, 
		i.ivh_remark,
		i.ivh_driver,       
		i.ivh_driver2, 
		i.ivh_tractor, 
		i.ivh_trailer,      
		i.mov_number ,
		i.ivh_edi_flag, 
		'RevType1', 
		'RevType2', 
		'RevType3',    
		'RevType4', 
		i.ivh_freight_miles ,
		i.ivh_priority ,    
		i.ivh_low_temp, 
		i.ivh_high_temp , 
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		i.ivh_order_by, 
		i.tar_tarriffnumber,        
		i.tar_number , 
		i.ivh_user_id1, 
		i.ivh_user_id2 ,    
		i.ivh_ref_number, 
		i.ivh_bookyear, 
		i.ivh_bookmonth, 
		i.tar_tariffitem, 
		i.ivh_mbstatus, 
		@calcmaxstat, 
		i.ord_number, 
		i.ivh_quantity, 
		i.ivh_rate, 
		i.ivh_charge, 
		i.cht_itemcode, 
		i.ivh_splitbill_flag, 
		@calcmaxstat,
		i.ivh_company,
		i.ivh_carrier,
		i.ivh_archarge,
		i.ivh_arcurrency,
		i.ivh_loadtime,
		i.ivh_unloadtime,
		i.ivh_drivetime,
		i.ivh_totaltime,
		i.ivh_rateby,
		i.ivh_unit,
		@vchar6,
		0,
		@remarks,
		c.cmp_altid,
		i.ivh_revenue_date,
		i.ivh_batch_id,
		mailto_flag =
		 	CASE ISNULL(c.cmp_mailto_name,'')
			   		WHEN '' THEN 'N'
			   			ELSE 'Y'
		 	END,
		i.ivh_stopoffs,
		ISNULL(ivh_quantity_type,0),
		ISNULL(ivh_charge_type,0), 
                ivh_originzipcode, 
                ivh_destzipcode,
		'TrcType4',
		'',
		'TrlType4',
		'',
		ivh_ratingquantity = ISNULL(i.ivh_ratingquantity,ivh_quantity),
		ivh_ratingunit = ISNULL(i.ivh_ratingunit,'UNK'),
		ivh_definition,
		IsNull(i.ivh_applyto_definition,''),
		i.ivh_hideshipperaddr,
		i.ivh_hideconsignaddr,
		-- PTS 14198 - DJM - Default shipper/consigneed if 'ivh_show..' fields are null
		isNull(ivh_showshipper, ivh_shipper) ivh_showshipper,
		isnull(ivh_showcons,ivh_consignee) ivh_showcons,
		ISNULL(ivh_mileage_adjustment,0),
		IsNull(i.ivh_paperworkstatus,'UNK'),
		ivh_order_cmd_code,
		--vmj1+
		isnull(ivh_allinclusivecharge, 0.0),
		'Y',
		--vmj1-
		ivh_reftype,
		ivh_attention,
		ivh_rate_type = IsNull(ivh_rate_type,0),
		@contact,
		ivh_paperwork_override,
		IsNUll(ivh_cmrbill_link,0) ivh_cmrbill_link,
		IsNull(c.cmp_min_charge,0),
		IsNull(c.cmp_mastercompany,'UNKNOWN') cmp_mastercompany,
		@paperworkmarked,
                inv_revenue_pay_fix,
                inv_revenue_pay,
		i.ivh_block_printing,
		i.ivh_custdoc,
		i.ivh_entryport,
		i.ivh_exitport,
		IsNull(ivh_mileage_adj_pct,0),
		i.ivh_pay_status,
		-- PTS 18878 -- BL (start)
		i.ivh_paid_amount,
		-- PTS 18878 -- BL (end)
		i.ivh_dimfactor 
      		,i.ivh_trlconfiguration
		,ivh_trlconfiguration_t = 'TrlConfiguration'
		,ord_rate_mileagetable = '' -- used only for new invoices
		--PTS# 23583 ILB 02/14/2005
                ,ord_bookedby = '',
		--PTS# 23583 ILB 02/14/2005
		ISNULL(ivh_charge_type_lh,0),
		IsNull(ivh_booked_revtype1, 'UNK'),
		'Branch',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'UNK',
		'TrlType1',
		'UNK',
		'TrlType2',
		'UNK',
		'TrlType3',
		'UNK',
		'TrlType4',
		'', --ord_fromorder
		i.ivh_misc_number,
		'', --os 4/17/07
		'', -- ord_availabledate pts 36001
		ivh_exchangerate,
		i.ivh_loaded_distance, --38823
		i.ivh_empty_distance,
		0,
                isnull (i.ivh_paid_indicator, 'U'), --PTS41325
		i.ivh_lastchecknumber, --PTS41325
		i.ivh_lastcheckamount, --PTS41325
		i.ivh_totalpaid,         --PTS41325
                i.ivh_lastcheckdate,--PTS41325 
		i.ivh_leaseid,
		i.ivh_leaseperiodenddate
        ,ivh_gp_gl_postdate  --40260
        ,ivh_nomincharges = IsNull(ivh_nomincharges,'N')   --40260
        ,''   --40260
         ,cmp_splitbillonrefnbr = IsNull(c.cmp_splitbillonrefnbr,'N')   --40260
        ,multiaddrcount = (Select count(*) from companyaddress where cmp_id = ivh_billto)   --40260
        ,car_key = IsNull(i.car_key,0)   --40260
        ,ord_no_recalc_miles = IsNull((Select  isnull(ord_no_recalc_miles,'N') from orderheader  o where i.ord_hdrnumber = o.ord_hdrnumber),'N')   --40260
        --PTS 51570 JJF 20100510
		--,i.ivh_belongsto				--PTS 42432 JJF 20080421
		--END PTS 51570 JJF 20100510
        ,i.ivh_invoiceby
        ,@ordscount
		   ,i.ivh_furthestpointconsignee 
       ,999 ord_roundbillqty   --48966
       ,ivh_trailer2  -- 48966  
       ,ivh_reprint		--vjh 53851
       ,ord_pallet_type	
		,ord_pallet_count
       ,dbh_id          -- SGB 60008
       ,ord_ratemode		-- 03/29/2012 NQIAO PTS 58978
	,ord_servicelevel	-- 03/29/2012 NQIAO PTS 58978
	,ord_servicedays		-- 03/29/2012 NQIAO PTS 58978       
	,null				-- 08/01/2012 NQIAO PTS 63136    dbh_custinvnum
	,i.ivh_gpserver		--PTS69481 MBR 07/12/13
	,i.ivh_gpdatabase	--PTS69481 MBR 07/12/13
	,i.ivh_splitgroup	-- PTS 63450 nloke
	,i.ivh_donotprint	--PTS66727 MBR 11/04/13
	   ,orderheader.ord_miscqty	--PTS 63937 JJF 20120927
	   , 'OrdMscQty1' --PTS 63937 JJF 20120927
	   ,i.ivh_subcompany  --PTS87839 nloke
	   ,i.ivh_lh_charge	--PTS 94775 nloke
	   ,i.ivh_lh_charge_with_rollin -- PTS 94775 nloke
	   ,i.ivh_rollin_lh_rate --PTS 94775 nloke
	FROM invoiceheader i
    join company c on ivh_billto = c.cmp_id
    left outer join orderheader on i.ord_hdrnumber = orderheader.ord_hdrnumber
	WHERE ((i.ord_hdrnumber = @numberparm  And @numberparm   > 0) OR
	      (i.ivh_invoicenumber = @stringparm And @numberparm = 0 ))
	--	And c.cmp_id = ivh_billto
	
--PMILL 49221 ord_fromorder and dummy_ordstatus is needed for rating.  Moved these updates outside IF block from below
IF (select count(*) from @temp) > 0 
BEGIN	
	--DPH PTS 29581
	UPDATE 	@temp
	SET	ord_fromorder = o.ord_fromorder
    from @temp t inner join orderheader o on t.ord_hdrnumber = o.ord_hdrnumber
	WHERE	t.ord_hdrnumber > 0
	--DPH PTS 29581

	UPDATE @temp
	SET dummy_ordstatus = o.ord_status,
		opt_trc_type4 = o.opt_trc_type4,
		opt_trl_type4 = o.opt_trl_type4,
		trl_type1 = o.trl_type1,
		ord_trl_type2 = o.ord_trl_type2,
		ord_trl_type3 = o.ord_trl_type3,
		ord_trl_type4 = o.ord_trl_type4		
	FROM orderheader o inner join @temp t on o.ord_hdrnumber = t.ord_hdrnumber
	--PMILL 49221 end
END

-- if a record was found and we are not doing queue processing, add more infor		   
	IF (select count(*) from @temp) > 0 and UPPER(@process) <> 'QUEUE'
	BEGIN
        /* 39359 */
		if @numberparm <> 0 
           select @v_npeventcount = count(*)
           from stops
           join event on stops.stp_number = event.stp_number
           left outer join eventcodetable on event.evt_eventcode = eventcodetable.abbr
	   		WHERE ( stops.ord_hdrnumber = @numberparm) AND 
                stops.ord_hdrnumber > 0 and 
				@numberparm > 0 and
        	    (eventcodetable.primary_event = 'N')
 
	 	UPDATE @temp
	 	SET comments_count = a.qty from 
		(
				select o.ord_hdrnumber, count(*) as qty 
				FROM orderheader o inner join @temp t on o.ord_hdrnumber = t.ord_hdrnumber
				WHERE RTRIM(o.ord_remark) > '' group by o.ord_hdrnumber
		) a  inner join @temp t2 on a.ord_hdrnumber = t2.ord_hdrnumber

	 	SELECT	@first_invoice_number = ivh_invoicenumber,
			@mov_number = mov_number,
			@first_origin = ivh_originpoint,
			@first_dest = ivh_destpoint,
			@first_billto = ivh_billto,
			@driver = ivh_driver,
			@driver2 = ivh_driver2,
			@tractor = ivh_tractor,
			@trailer = ivh_trailer,
			@carrier = ivh_carrier
	 	FROM	@temp t
	 	WHERE	t.ivh_invoicenumber = (SELECT MIN(ivh_invoicenumber) from @temp)
	 
	 	EXEC @notes_count = d_notes_check_sp	2, /*PTS 30661 CGK 11/21/2005*/
			@mov_number, 
			@numberparm, 
			@first_invoice_number, 
			@driver, 
			@driver2, 
			@tractor, 
			@trailer, 
			'', 
			@carrier, 
			@first_origin, 
			@first_dest, 
			@first_billto, 
			0,
			'',
			--ILB 15827 04/01/03
			'',
			--ILB 15827 04/01/03
			0

	 	UPDATE @temp
	 	SET notes_count= @notes_count

	 	UPDATE @temp
	 	SET loadreq_count = a.qty
		FROM
			(
			select t.mov_number, count(*) as qty
	 		FROM loadrequirement l inner join @temp t on l.mov_number = t.mov_number
	 		WHERE t.mov_number > 0 group by t.mov_number
			) a inner join @temp t2 on a.mov_number = t2.mov_number

	 	UPDATE @temp 
	 	SET ref_count = a.qty
		FROM
		( 
		select t.ord_hdrnumber, count(*) as qty
	 	FROM referencenumber r inner join @temp t on r.ref_tablekey = t.ord_hdrnumber
		WHERE  r.ref_table = 'orderheader'
		group by t.ord_hdrnumber
		) a inner join @temp t2 on a.ord_hdrnumber = t2.ord_hdrnumber

	 	--PTS81091 MBR 05/12/15
		UPDATE @temp
		   SET lgh_count = a.qty
		  FROM
		(SELECT COUNT(*) AS qty
		   FROM legheader
		  WHERE legheader.mov_number IN (SELECT DISTINCT mov_number
		                                   FROM @temp)) a
	 	
		-- added ord_availabledate field to Update pts 36001
		UPDATE @temp
	 	SET ord_availabledate = o.ord_availabledate
		FROM orderheader o inner join @temp t on o.ord_hdrnumber = t.ord_hdrnumber
	

		--PTS40482 MBR 01/11/08
                IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
                      FROM generalinfo
                     WHERE gi_name = 'StlmntAmountOnInvoiceScreen') = 'Y'
                BEGIN

                   UPDATE @temp
                      SET stlmnt_amt = a.pydsum
					  FROM 
						(
						select t.ord_hdrnumber, SUM(ISNULL(pyd_amount,0)) as pydsum
						FROM paydetail inner join @temp t on paydetail.ord_hdrnumber = t.ord_hdrnumber
						group by t.ord_hdrnumber
						) a inner join @temp t2 on a.ord_hdrnumber = t2.ord_hdrnumber
                                       
                END
		
	END	
   END
ELSE
	 /*****************************************************************
	 *  IF NO INVOICE EXISTS CREATE NEW INVOICE FROM ORDER INFORMATION
	 ******************************************************************/
  BEGIN
  -- proc determins appropriate assets (using GI preference PICKUP DELIVERY MOSTMILES  and invoiceby options) 
  exec getAssetsForInvoice @numberparm,@driver1 OUTPUT,@driver2 output,@tractor output,@trailer1 output,@trailer2 output,@carrier output
    
    If @cmpinvoiceby = 'ORD'
      BEGIN
	    If Upper(@delivery_date)  = 'ARRIVAL' and @numberparm > 0  -- 39359 and @numberparm
		  select @cons_date = stp_arrivaldate
		  from stops
		  where ( stops.ord_hdrnumber = @numberparm) AND
            stops.ord_hdrnumber > 0 and -- 39359 
			stp_sequence = (select max(stp_sequence)
						from stops s2
						where s2.ord_hdrnumber = @numberparm and
							s2.stp_type='DRP' and 
                            s2.ord_hdrnumber > 0)  --39359

         select @ordrefnum = (select top 1 ref_number from referencenumber
         where ref_table = 'orderheader'
         and ref_tablekey =  @numberparm
         order by ref_sequence) 

        select @ordreftype = (select top 1 ref_type from referencenumber
         where ref_table = 'orderheader'
         and ref_tablekey =  @numberparm
         order by ref_sequence)

         select @ordreftype = isnull(@ordreftype,'UNK')

         INSERT into @temp
	     SELECT @invnum invoice_number, 
		  o.ord_billto,
		  o.ord_terms terms, 
		  o.ord_totalcharge,  
		  o.ord_shipper, 
		  o.ord_consignee, 
		  o.ord_originpoint,   
		  o.ord_destpoint, 
		  'AVL', 
		  o.ord_origincity,     
		  o.ord_destcity, 
		  o.ord_originstate, 
		  o.ord_deststate,      
		  o.ord_originregion1, 
		  o.ord_destregion1, 
		  o.ord_supplier,       
		  o.ord_startdate, 
		  isnull(@cons_date, o.ord_completiondate), 
		  o.ord_revtype1,       
		  o.ord_revtype2, 
		  o.ord_revtype3, 
		  o.ord_revtype4, 
		  o.ord_totalweight, 
		  o.ord_totalpieces, 
		  o.ord_totalmiles,     
		  --ISNULL(o.ord_currency, 'CAN$'),
		  o.ord_currency,
		  o.ord_currencydate, 
		  o.ord_totalvolume,    
		  0, 
		  0,       
		  0, 
		  0,
		  @fill6,
		  'N',     
		  @invnum, 
		  @dummydate, 
		  getdate(), 
		  @dummydate,   
		  0, 
		  o.ord_hdrnumber, 
		  o.ord_originregion2,  
		  o.ord_originregion3, 
		  o.ord_originregion4, 
		  o.ord_destregion2,    
		  o.ord_destregion3, 
		  o.ord_destregion4, 
		  0, 
		  @remarks, 
		  @driver1, -- 438966  o.ord_driver1, 
		  @driver2,  -- 48966 o.ord_driver2, 
		  @tractor, -- 48966o.ord_tractor,
		  @trailer1, -- 48966 o.ord_trailer, 
		  o.mov_number, 
		  @edi, 
		  'RevType1', 
		  'RevType2', 
		  'RevType3', 
		  'RevType4', 
		  0, 
		  ISNULL(o.ord_priority,'UNK'), 
		  o.ord_lowtemp, 
		  o.ord_hitemp,
		  0,
		  LEN(RTRIM(o.ord_remark)) comments_count,
		  @notes_count,
		  @loadreq_count,
		  @ref_count,
		  0, --@pwork_req_count,
		  0, --@pwork_rec_count,
		  o.ord_company, 
		  o.tar_tarriffnumber, 
		  o.tar_number, 
		  @fill20, 
		  @fill20, 
		  @ordrefnum  ord_refnum, 
		  0, 
		  0, 
		  o.tar_tariffitem, 
		  @fill6, 
		  @fill6, 
		  o.ord_number, 
		  o.ord_quantity, 
		  o.ord_rate, 
		  o.ord_charge, 
		  o.cht_itemcode, 
		  'N', 
		  o.ord_status,
		  o.ord_subcompany,
		  @carrier, -- 48966 @fill8,
		  0,
		  '',
		  o.ord_loadtime,
		  o.ord_unloadtime,
		  o.ord_drivetime,
		  0,
		  o.ord_rateby ivh_rateby,
		  o.ord_unit ivh_unit,
		  o.ord_rateunit ivh_rateunit,
		  @lgh_count,
		  o.ord_remark,
		  c.cmp_altid,     --@billto_altid,
		  @ivh_revenue_date,
		  @ivh_batch_id,
		  mailto_flag =
			CASE ISNULL(c.cmp_mailto_name,'')
			   WHEN '' THEN 'N'
			   ELSE 'Y'
			 END,           --'N',
		  0,
		  ISNULL(o.ord_quantity_type,0),
		  ISNULL(o.ord_charge_type,0), 
                ISNULL((SELECT cmp_zip 
                          FROM company 
                         WHERE cmp_id = o.ord_shipper), ''), 
                ISNULL((SELECT cmp_zip 
                          FROM company 
                         WHERE cmp_id = o.ord_consignee), '') ,
		  'TrcType4',
		  o.opt_trc_type4,
		  'TrlType4',
		  o.opt_trl_type4,
		  ISNULL(o.ord_ratingquantity,ord_quantity),
		  ISNULL(o.ord_ratingunit,ord_unit),
		  '',
		  '',
		  o.ord_hideshipperaddr,
		  o.ord_hideconsignaddr,
		  -- PTS 14198 - DJM - Default shipper/consignee if 'ivh_show..' fields are null
		  isNull(o.ord_showshipper, o.ord_shipper) ,
		  isNull(o.ord_showcons, o.ord_consignee),
		  0,
		  'UNK',
		  o.cmd_code,
		  --vmj1+
		  isnull(o.ord_allinclusivecharge, 0.0),
		  'Y',
		  --vmj1-
		  @ordreftype,  --'',
		  '',
		  Isnull(o.ord_rate_type,0) ivh_rate_type,
		  @contact,
		  '',
		  0,
		  IsNull(c.cmp_min_charge,0),
		  IsNull(c.cmp_mastercompany,'UNKNOWN') cmp_mastercompany,
		  @paperworkmarked,
		  ord_revenue_pay_fix,	
                ord_revenue_pay,
		  '',
		  ord_customs_document,
		  ord_entryport,
		  ord_exitport,
		  IsNull(ord_mileage_adj_pct,0),
		  '0',
		  -- PTS 18878 -- BL (start)
		  NULL ivh_paid_amount,
		  -- PTS 18878 -- BL (end)
		  o.ord_dimfactor
		  ,o.ord_trlconfiguration
		  ,ivh_trlconfiguration_t = 'TrlConfiguration'
		  ,ord_rate_mileagetable
		  --PTS# 23583 ILB 02/14/2005
                ,isnull(o.ord_bookedby,'') ord_bookedby, 
	        --PTS# 23583 ILB 02/14/2005
		  ISNULL(o.ord_charge_type_lh,0),
		  IsNull(ord_booked_revtype1, 'UNK'),
		  'Branch' ,
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  trl_type1,
	      'TrlType1',
		  ord_trl_type2,
		  'TrlType2',
		  ord_trl_type3,
		  'TrlType3',
		  ord_trl_type4,
		  'TrlType4',
		  '', --ord_fromorder
		  '',	-- ivh_misc_number
		  '', --os 4/17/07
		  o.ord_availabledate, -- pts 36001
		  0,	--ivh_exchangerate
		  0,  -- i.ivh_loaded_distance  --38823
		  0,   -- i.ivh_empty_distance
		  0,
                '', --PTS41325
		  '', --PTS41325
		  0, --PTS41325
		  0,         --PTS41325
                1/1/1900, --PTS41325
		  NULL,
		  NULL
          ,''  --40260
          ,ord_nomincharges = IsNull(ord_nomincharges,'N')  --40260
          ,''  --40260
          ,cmp_splitbillonrefnbr = IsNull(c.cmp_splitbillonrefnbr,'N')  --40260
          ,multiaddrcount = (Select count(*) from companyaddress where cmp_id = ord_billto)  --40260
          ,car_key = IsNull(o.car_key,0)  --40260
          ,ord_no_recalc_miles = isnull(ord_no_recalc_miles,'N')   --40260
          --PTS 51570 JJF 20100510
		  --,o.ord_belongsto				--PTS 42432 JJF 20080421
		  --END PTS 51570 JJF 20100510
          ,ivh_invoiceby = @cmpinvoiceby
          ,@ordscount
           ,NULL ivh_furthestpointconsigne
          ,999 ord_roundbillqty
          ,@trailer2
          ,''
          ,ord_pallet_type	
		,ord_pallet_count
		,NULL          -- SGB 60008 ivh_dbh_id
          ,ord_ratemode			-- 03/29/2012 NQIAO PTS 58978
		  ,ord_servicelevel		-- 03/29/2012 NQIAO PTS 58978
	      ,ord_servicedays		-- 03/29/2012 NQIAO PTS 58978		
	      ,null					-- 08/01/2012 NQIAO PTS 63136	dbh_custinvnum
	  ,NULL				--PTS69481 MBR 07/12/13
	  ,NULL				--PTS69481 MBR 07/12/13
	  ,NULL				-- PTS 63450 nloke
	  ,'N' 				--ivh_donotprint PTS66727 MBR 11/04/13
	      ,o.ord_miscqty	--PTS 63937 JJF 20120927	
	      ,'OrdMscQty1' --PTS 63937 JJF 20120927
	      ,o.ord_subcompany	--PTS 87839 nloke 3/4/2015
	   ,NULL	--PTS 94775 nloke
	   ,NULL -- PTS 94775 nloke
	   ,NULL --PTS 94775 nloke
	      FROM orderheader o, company c
	      WHERE o.ord_hdrnumber = @numberparm 
	      --  	 and ord_invoicestatus = 'AVL'	
        --  AND (((ord_invoicestatus IN ('AVL', 'RTP') AND @FromOrder = 'N') OR (ord_invoicestatus = 'PPD' AND @FromOrder <> 'N')) or @p_prerating = 'Y') PTS 52349 SGB
        AND (((ord_invoicestatus IN ('AVL', 'RTP','AUT') AND @FromOrder = 'N') OR (ord_invoicestatus = 'PPD' AND @FromOrder <> 'N')) or @p_prerating = 'Y') 
		  AND o.ord_hdrnumber > 0
		  And c.cmp_id = o.ord_billto
        --and ord_charge > (case @v_LHChargerequired when 'Y' then 0 else (ord_charge - 1) end)  -- 46534 customer cannot bill wihtout lh charges
        --PTS 61225 SGB Null ord_cahrge causes failure
        and isnull(ord_charge,0) > (case @v_LHChargerequired when 'Y' then 0 else (isnull(ord_charge,0) - 1) end)  -- 46534 customer cannot bill wihtout lh charges  

		--PTS 102044
		SELECT @subcharge = ISNULL(ivd_charge, 0)
		FROM invoicedetail
		WHERE ord_hdrnumber = @numberparm
			AND ivd_type = 'SUB'
		IF @subcharge > 0
		BEGIN
			UPDATE @temp
			SET ivh_charge = @subcharge
			WHERE ord_hdrnumber = @numberparm
		END
		--end 102044
      END
    ELSE /* invoice by move or move/consignee  */
      BEGIN


         select @ordrefnum = (select top 1 ref_number from referencenumber
         where ref_table = 'orderheader'
         and ref_tablekey =  @numberparm
         order by ref_sequence) 

        select @ordreftype = (select top 1 ref_type from referencenumber
         where ref_table = 'orderheader'
         and ref_tablekey =  @numberparm
         order by ref_sequence)

         select @ordreftype = isnull(@ordreftype,'UNK')


          INSERT into @temp
	      SELECT @invnum invoice_number, 
		  o.ord_billto  ,
		  o.ord_terms terms, 
		  @SUM_ord_totalcharge,    
		  @firstpup_cmpid  ord_shipper,  
		  @lastdrop_cmpid ord_consignee, 
		  @firstpup_cmpid ord_originpoint,   
		  @lastdrop_cmpid ord_destpoint, 
		  'AVL',  
		  @firstpup_stp_city  ord_origincity,     
		  @lastdrop_stp_city ord_destcity, 
		  @firstpup_stp_state ord_originstate, 
		  @lastdrop_stp_state  ord_deststate,      
		  o.ord_originregion1, 
		  o.ord_destregion1, 
		  o.ord_supplier ,       
		  @firstpup_stp_arrivaldate ord_startdate, 
		  @lastdrop_stp_arrivaldate ord_completiondate, 
		  o.ord_revtype1,       
		  o.ord_revtype2, 
		  o.ord_revtype3, 
		  o.ord_revtype4, 
		  @sum_ord_totalweight, 
		  @SUM_ord_totalcount , 
		  o.ord_totalmiles,     
		  --ISNULL(o.ord_currency, 'CAN$'),
		  o.ord_currency,
		  o.ord_currencydate, 
		  @sum_ord_totalvolume,    
		  0, 
		  0,       
		  0, 
		  0,
		  @fill6,
		  'N',     
		  @invnum, 
		  @dummydate, 
		  getdate(), 
		  @dummydate,   
		  0, 
		  @numberparm, 
		  o.ord_originregion2 ,  
		  o.ord_originregion3, 
		  o.ord_originregion4, 
		  o.ord_destregion2,    
		  o.ord_destregion3, 
		  o.ord_destregion4, 
		  0, 
		  @remarks, 
		  @driver1, -- 48966 @lgh_driver1, 
		  @driver2,  -- 48966 @lgh_driver2, 
		  @tractor,  -- 48966 @lgh_tractor,
		  @trailer1,  -- 48966 @lgh_primary_trailer, 
		  @movnumber, 
		  @edi, 
		  'RevType1', 
		  'RevType2', 
		  'RevType3', 
		  'RevType4', 
		  0, 
		  ISNULL(o.ord_priority,'UNK') , 
		  o.ord_lowtemp, 
		  o.ord_hitemp,
		  0,
		  LEN(RTRIM(o.ord_remark)) comments_count,
		  @notes_count,
		  @loadreq_count ,
		  @ref_count,
		  @pwork_req_count,
		  @pwork_rec_count ,
		  o.ord_company, 
		  o.tar_tarriffnumber, 
		  o.tar_number , 
		  @fill20, 
		  @fill20, 
		  @ordrefnum, --o.ord_refnum , 
		  0, 
		  0, 
		  o.tar_tariffitem, 
		  @fill6, 
		  @fill6, 
		  o.ord_number, 
		  o.ord_quantity, 
		  o.ord_rate, 
		  o.ord_charge, 
		  o.cht_itemcode, 
		  'N', 
		  o.ord_status,
		  o.ord_subcompany,
		  @carrier,  -- 48966 @fill8,
		  0,
		  '',
		  o.ord_loadtime,
		  o.ord_unloadtime,
		  o.ord_drivetime,
		  0,
		  o.ord_rateby ivh_rateby,
		  o.ord_unit ivh_unit,
		  o.ord_rateunit ivh_rateunit,
		  @lgh_count,
		  o.ord_remark,
		  c.cmp_altid,     --@billto_altid,
		  @ivh_revenue_date,
		  @ivh_batch_id,
		  mailto_flag =
			CASE ISNULL(c.cmp_mailto_name,'')
			   WHEN '' THEN 'N'
			   ELSE 'Y'
			 END,           --'N',
		  0,
		  ISNULL(o.ord_quantity_type,0),
		  ISNULL(o.ord_charge_type,0), 
                ISNULL((SELECT cmp_zip 
                          FROM company 
                         WHERE cmp_id = o.ord_shipper), ''), 
                ISNULL((SELECT cmp_zip 
                          FROM company 
                         WHERE cmp_id = o.ord_consignee), '') ,
		  'TrcType4',
		  o.opt_trc_type4,
		  'TrlType4',
		  o.opt_trl_type4,
		  ISNULL(o.ord_ratingquantity,o.ord_quantity),
		  ISNULL(o.ord_ratingunit,o.ord_unit),
		  '',
		  '',
		  o.ord_hideshipperaddr,
		  o.ord_hideconsignaddr,
		  -- PTS 14198 - DJM - Default shipper/consignee if 'ivh_show..' fields are null
		  isNull(o.ord_showshipper, o.ord_shipper) ,
		  isNull(o.ord_showcons, o.ord_consignee),
		  0,
		  'UNK',
		  o.cmd_code,
		  --vmj1+
		  isnull(o.ord_allinclusivecharge, 0.0),
		  'Y',
		  --vmj1-
		  @ordreftype,  --'',
		  '',
		  Isnull(o.ord_rate_type,0) ivh_rate_type,
		  @contact,
		  '',
		  0,
		  IsNull(c.cmp_min_charge,0),
		  IsNull(c.cmp_mastercompany,'UNKNOWN') cmp_mastercompany,
		  @paperworkmarked,
		  o.ord_revenue_pay_fix,	
          o.ord_revenue_pay,
		  '',
		  o.ord_customs_document,
		  o.ord_entryport,
		  o.ord_exitport,
		  IsNull(o.ord_mileage_adj_pct,0),
		  '0',
		  -- PTS 18878 -- BL (start)
		  NULL ivh_paid_amount,
		  -- PTS 18878 -- BL (end)
		  o.ord_dimfactor
		  ,o.ord_trlconfiguration
		  ,ivh_trlconfiguration_t = 'TrlConfiguration'
		  ,o.ord_rate_mileagetable
		  --PTS# 23583 ILB 02/14/2005
                ,isnull(o.ord_bookedby,'') ord_bookedby, 
	        --PTS# 23583 ILB 02/14/2005
		  ISNULL(o.ord_charge_type_lh,0),
		  IsNull(o.ord_booked_revtype1, 'UNK'),
		  'Branch' ,
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  'UNK',
		  o.trl_type1,
	      'TrlType1',
		  o.ord_trl_type2,
		  'TrlType2',
		  o.ord_trl_type3,
		  'TrlType3',
		  o.ord_trl_type4,
		  'TrlType4',
		  '', --ord_fromorder
		  '',	-- ivh_misc_number
		  '', --os 4/17/07
		  o.ord_availabledate, -- pts 36001
		  0,	--ivh_exchangerate
		  0,  -- i.ivh_loaded_distance  --38823
		  0,   -- i.ivh_empty_distance
		  0,
                '', --PTS41325
		  '', --PTS41325
		  0, --PTS41325
		  0,         --PTS41325
                1/1/1900, --PTS41325
		  NULL,
		  NULL
          ,''  --40260
          ,ord_nomincharges = IsNull(o.ord_nomincharges,'N')  --40260
          ,''  --40260
          ,cmp_splitbillonrefnbr = IsNull(c.cmp_splitbillonrefnbr,'N')  --40260
          ,multiaddrcount = (Select count(*) from companyaddress where cmp_id = o.ord_billto)  --40260
          ,car_key = IsNull(o.car_key,0)  --40260
          ,ord_no_recalc_miles = isnull(ord_no_recalc_miles,'N')   --40260
          --PTS 51570 JJF 20100510
		  --,o.ord_belongsto	
		  --PTS 51570 JJF 20100510
          ,ivh_invoiceby = @cmpinvoiceby
          ,@ordscount
           ,NULL ivh_furthestpointconsigne
          ,999 ord_roundbillqty
          ,@trailer2
			,''
			,ord_pallet_type	
		,ord_pallet_count
		,NULL          -- SGB 60008 ivh_dbh_id
		  ,ord_ratemode		-- 03/29/2012 NQIAO PTS 58978
	      ,ord_servicelevel	-- 03/29/2012 NQIAO PTS 58978
	      ,ord_servicedays		-- 03/29/2012 NQIAO PTS 58978		
	      ,null					-- 08/01/2012 NQIAO PTS 63136		dbh_custinvnum
	  ,NULL				--PTS69481 MBR 07/12/13
	  ,NULL				--PTS69481 MBR 07/12/13
	  ,NULL				-- PTS 63450 nloke
	  ,'N' 				--ivh_donotprint PTS66727 MBR 02/25/13
	       ,o.ord_miscqty	--PTS 63937 JJF 20120927
	       ,'OrdMscQty1' --PTS 63937 JJF 20120927
	       ,o.ord_subcompany --PTS 87839 nloke 3/4/2015
	   ,NULL	--PTS 94775 nloke
	   ,NULL -- PTS 94775 nloke
	   ,NULL --PTS 94775 nloke
	      FROM orderheader o, company c
	      WHERE o.ord_hdrnumber = @numberparm 
        --  AND ((ord_invoicestatus IN ('AVL', 'RTP') AND @FromOrder = 'N') OR (ord_invoicestatus = 'PPD' AND @FromOrder <> 'N')) PTS 52349 SGB
        AND ((ord_invoicestatus IN ('AVL', 'RTP','AUT') AND @FromOrder = 'N') OR (ord_invoicestatus = 'PPD' AND @FromOrder <> 'N')) 
		  AND o.ord_hdrnumber > 0
		  And c.cmp_id = o.ord_billto
      END
      

	UPDATE 	@temp
	SET	ord_fromorder = o.ord_fromorder
				 from	orderheader o inner join @temp t on
				 	o.ord_hdrnumber = t.ord_hdrnumber
	WHERE	t.ord_hdrnumber > 0
	--DPH PTS 29581
--PTS 34878 End

-- if a record was found and we are not doing queue processing, add more infor
		  SELECT	@mov_number = mov_number,
					@driver = ivh_driver,
					@driver2 = ivh_driver2,
					@tractor = ivh_tractor,
					@trailer = ivh_trailer,
					@carrier = ivh_carrier
			FROM @temp		   
	IF @mov_number IS NOT NULL and UPPER(@process) <> 'QUEUE'
	   BEGIN
         /* 39359 */
		if @numberparm <> 0 
           select @v_npeventcount = count(*)
           from stops
           join event on stops.stp_number = event.stp_number
           left outer join eventcodetable on event.evt_eventcode = eventcodetable.abbr
	   		WHERE ( stops.ord_hdrnumber = @numberparm) AND 
                stops.ord_hdrnumber > 0 and 
				@numberparm > 0 and
        	    (eventcodetable.primary_event = 'N')

	     EXEC  @notes_count = d_notes_check_sp	2, /*PTS 30661 CGK 11/21/2005*/
		@mov_number, 
		@numberparm, 
		'', 
		@driver, 
		@driver2, 
		@tractor, 
		@trailer, 
		'', 
		@carrier, 
		'', 
		'', 
		'', 
		0,
		'',
		--ILB 15827 04/01/03
		'',
		--ILB 15827 04/01/03
		0
	
	    SELECT @loadreq_count= count(*) 
				from loadrequirement l inner join @temp t
			        on  l.mov_number = t.mov_number
				where t.mov_number > 0 

				
	   IF @retrieve_by = 'ORDNUM' and @cmpinvoiceby <> 'ORD'
			SELECT @ref_count = (SELECT count(*)
	        FROM @ordsoninvoice ords
            join   referencenumber on ords.ord_hdrnumber = referencenumber.ord_hdrnumber
		    WHERE ref_table = 'orderheader')
	   else	  
	      SELECT @ref_count = (SELECT count(*)
	                        FROM referencenumber
		                WHERE ref_table = 'orderheader'
	                        AND   ref_tablekey = @numberparm)
		
	
	   SELECT @lgh_count = (SELECT COUNT(*)
                             FROM legheader
                             WHERE mov_number = @mov_number)  
	  
	/*	LOR	PTS#4795(SR# 7166)	*/
	   UPDATE @temp
	   SET           --move to main select dpete 2/27/02 billto_altid = c.cmp_altid,
 		 				-- moved to main select mailto_flag = CASE ISNULL(c.cmp_mailto_name,'') WHEN '' THEN 'N'ELSE 'Y' END,
	      lgh_count = @lgh_count,
	      ref_count = @ref_count,
	      loadreq_count = @loadreq_count,
	      notes_count = @notes_count
	   --FROM company c
	   --WHERE  c.cmp_id = #temp.ivh_billto

	UPDATE @temp 
	   SET ivh_showshipper = o.ord_shipper
	   FROM orderheader o inner join @temp t on
	     o.ord_hdrnumber = t.ord_hdrnumber where
		t.ivh_showshipper = 'UNKNOWN'

	UPDATE @temp 
	   SET 	ivh_showcons = o.ord_consignee
 	   FROM orderheader o inner join @temp t on
	     o.ord_hdrnumber = t.ord_hdrnumber where
		t.ivh_showcons = 'UNKNOWN'

	END

	--PTS40482 MBR 01/11/08
        IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
                      FROM generalinfo
                     WHERE gi_name = 'StlmntAmountOnInvoiceScreen') = 'Y'
        BEGIN
           UPDATE @temp
              SET stlmnt_amt = a.sumpyd
			  from 
			(
				select t.ord_hdrnumber, SUM(ISNULL(pyd_amount,0)) as sumpyd
				FROM paydetail inner join @temp t on
				paydetail.ord_hdrnumber = t.ord_hdrnumber
				group by t.ord_hdrnumber
			) a inner join @temp t2 on a.ord_hdrnumber = t2.ord_hdrnumber
        END
END

--vmj1+	So far, the all-inclusive indicator has been defaulted to 'Y'.  Set to 'N'
--	wherever the amount is 0..
update	@temp
  set	all_inclusive_indc = 'N'
  where	ivh_allinclusivecharge = 0.0
--vmj1-

Update @temp
Set cmp_min_charge = IsNull(c.cmp_min_charge,0) From company c
inner join @temp t on c.cmp_id = t.cmp_mastercompany
Where t.cmp_min_charge = 0

select @ord_hdrnumber = min(ord_hdrnumber) from @temp
/*********** 40260  ***************/
if exists (select 1 from @temp where ord_hdrnumber > 0)
BEGIN
  declare @mov int
  , @ords varchar(256)
  , @ordnum varchar(12)
  select @mov =  max(isnull(mov_number,0)) from @temp
  set @ords = ''
  select @ords = @ords + rtrim(ord_number) + ', '
  from orderheader
  join (select distinct ord_hdrnumber from stops where mov_number = @mov and ord_hdrnumber > 0) stopords
  on stopords.ord_hdrnumber = orderheader.ord_hdrnumber
  if len(@ords) > 3 select @ords = left(@ords,len(@ords) - 1) 
  update @temp set orders_on_move = @ords
END
/*                     */


--PTS# 23583 ILB 02/14/2005
UPDATE @temp
   SET ord_bookedby = Case
  		WHEN t.ord_bookedby = '' THEN o.ord_bookedby
		-- PTS 27556 -- BL (start)
		ELSE t.ord_bookedby
		-- PTS 27556 -- BL (end)
		END,
		--PTS 87839 populate ivh_subcompany from ord_subcompany
		ivh_subcompany = Case
			When t.ivh_subcompany = '' Then o.ord_subcompany
			Else t.ivh_subcompany
			End
		--end 87839
FROM orderheader o inner join @temp t
ON o.ord_hdrnumber = t.ord_hdrnumber
--END PTS# 23583 ILB 02/14/2005

/* PTS 26793 (recode 20297) - DJM - IF a Localization RevType is set, then update the localization
	values returned to the Invoice window.		
   PTS 26793 (recode 23836) - DJM - Modified to use origin/destination Zip instead of Zip from the City table.
*/
Select @service_revtype = isNull(gi_string1,'UNKNOWN') from generalinfo where gi_name = 'ServiceRegionRevType'

if @service_revtype <> 'UNKNOWN' AND @localization = 'Y'
	Update @temp
	set origin_servicezone = (select cz_zone from cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip),
		origin_servicearea = (select cz_area from cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip),
		origin_servicecenter = (select Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype4 = sc.svc_revcode)
				else 'UNK'
			End),
		origin_serviceregion = (select Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_origincity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_originzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype4 = sc.svc_revcode)
				else 'UNK'
			End),
		dest_servicezone = (select cz_zone from cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip),
		dest_servicearea = (select cz_area from cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip),
		dest_servicecenter = (select Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_center) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype4 = sc.svc_revcode)
				else 'UNK'
			End),
		dest_serviceregion = (select Case isNull(@service_revtype,'UNKNOWN')
				when 'REVTYPE1' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype1 = sc.svc_revcode)
				when 'REVTYPE2' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype2 = sc.svc_revcode)
				when 'REVTYPE3' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype3 = sc.svc_revcode)
				when 'REVTYPE4' then
					(select max(svc_region) from serviceregion sc, cityzip, city where ivh_destcity = city.cty_code and city.cty_nmstct = cityzip.cty_nmstct and ivh_destzipcode = cityzip.zip AND cityzip.cz_area = sc.svc_area AND ivh_revtype4 = sc.svc_revcode)
				else 'UNK'
			End)


SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN 
	--PTS 54140 JJF 20100929 - need to check orders as well
	DELETE @temp
	FROM @temp tp INNER JOIN orderheader oh on tp.mov_number = oh.mov_number
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_orderheader_fn() rsva 
							WHERE	oh.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)
	--PTS 54140 JJF 20100929

	DELETE @temp
	FROM @temp tp INNER JOIN invoiceheader ivh on tp.ivh_hdrnumber = ivh.ivh_hdrnumber
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_invoiceheader_fn() rsva 
							WHERE	ivh.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)




END
--END PTS 40929 JJF 20071211
--END PTS 51570 JJF 20100510

--03/29/2012 NQIAO PTS 58978 set NULL value for ord_ratemode, ord_servicelevel, ord_servicedays if miscellaneous invoice
UPDATE	@temp
SET		ord_ratemode = null,
		ord_servicelevel = null,
		ord_servicedays	= null
WHERE	ord_hdrnumber = 0

-- 08/01/2012 NQIAO PTS 63136
UPDATE	@temp
   SET	dbh_custinvnum = dbh.dbh_custinvnum
FROM	@temp t inner join dedbillingheader dbh on t.ivh_dbh_id = dbh.dbh_id
WHERE	t.ivh_dbh_id is not null


SELECT ivh_invoicenumber, 
	ivh_billto,
	ivh_terms, 
	ivh_totalcharge,    
	ivh_shipper, 
	ivh_consignee, 
	ivh_originpoint,    
	ivh_destpoint, 
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
	ivh_hdrnumber, 
	ord_hdrnumber, 
	ivh_originregion2,  
	ivh_originregion3, 
	ivh_originregion4, 
	ivh_destregion2,    
	ivh_destregion3, 
	ivh_destregion4, 
	ivh_mbnumber, 
	ivh_remark, 
	ivh_driver,
	ivh_driver2, 
	ivh_tractor,
	ivh_trailer, 
	mov_number, 
	ivh_edi_flag, 
	revtype1, 
	revtype2, 
	revtype3, 
	revtype4, 
	ivh_freight_miles, 
	ivh_priority,
	ivh_low_temp, 
	ivh_high_temp,
	@v_npeventcount events_count, -- 39359  events_count,
	comments_count,
	notes_count,
	loadreq_count,
	ref_count,
	paperwork_required,
	paperwork_received,
	ivh_order_by, 
	tar_tarriffnumber, 
	tar_number, 
	ivh_user_id1, 
	ivh_user_id2, 
	ivh_ref_number, 
	invoiceheader_ivh_bookyear, 
	invoiceheader_ivh_bookmonth, 
	tar_tariffitem, 
	ivh_mbstatus, 
	calc_maxstatus, 
	ord_number, 
	ivh_quantity, 
	ivh_rate, 
	ivh_charge, 
	cht_itemcode, 
	ivh_splitbill_flag, 
	dummy_ordstatus,
	ivh_company,
	ivh_carrier,
	ivh_archarge,
	ivh_arcurrency,
	ivh_loadtime,
	ivh_unloadtime,
	ivh_drivetime,
	ivh_totaltime,
	ivh_rateby,
	ivh_unit,
	ivh_rateunit,
	lgh_count,
	ord_remark,
	billto_altid,
	ivh_revenue_date,
	ivh_batch_id,
	mailto_flag,
	ivh_stopoffs,
	ivh_quantity_type,
	ivh_charge_type, 
	ivh_originzipcode, 
	ivh_destzipcode,
	trc_type4,
	opt_trc_type4,
	trl_type4,
	opt_trl_type4,
	ivh_ratingquantity,
	ivh_ratingunit,
	ivh_definition,
	ivh_applyto_definition,
	ivh_hideshipperaddr,
	ivh_hideconsignaddr,
	-- PTS 14198 - DJM - Default shipper/consigneed if 'ivh_show..' fields are null
	isNull(ivh_showshipper,ivh_shipper) ivh_showshipper,
	isNull(ivh_showcons, ivh_consignee) ivh_showcons,
	ivh_mileage_adjustment,
	ivh_paperworkstatus,
	ivh_order_cmd_code,
	--vmj1+
	ivh_allinclusivecharge,
	all_inclusive_indc,
	--vmj1-
	ivh_reftype,
	ivh_attention,
	ivh_rate_type,
	billto_cmp_contact,
	ivh_paperwork_override,
	ivh_cmrbill_link,
	cmp_min_charge,
	paperworkmarked,
	inv_revenue_pay_fix,
	inv_revenue_pay,
	cmp_mastercompany,
	ivh_block_printing,
	ivh_custdoc,
	ivh_entryport,
	ivh_exitport,
	ivh_mileage_adj_pct,
	ivh_pay_status,
	-- PTS 18878 -- BL (start)
	ivh_paid_amount 
	-- PTS 18878 -- BL (end)
	,	ivh_dimfactor
	,ivh_trlconfiguration
	,ivh_trlconfiguration_t
	,ord_rate_mileagetable  -- returned only for new invoices
	--PTS# 23583 ILB 02/14/2005
	,ord_bookedby, 
	--PTS# 23583 ILB 02/14/2005
	ivh_charge_type_lh,
	ivh_booked_revtype1,
	branch_t,
	origin_servicezone,
	origin_servicearea,
	origin_servicecenter,
	origin_serviceregion,
	dest_servicezone,
	dest_servicearea,
	dest_servicecenter,
	dest_serviceregion,
	trl_type1,
	trl_type1_name,
	ord_trl_type2,
	ord_trl_type2_name,
	ord_trl_type3,
	ord_trl_type3_name,
	ord_trl_type4,
	ord_trl_type4_name,
	ord_fromorder,
	ivh_misc_number  ,
	ord_bookdate = @v_ordbookdate,
	ord_availabledate, --pts 36001
	@v_lastHLTarrivaldate, --39280 (cons to 39359)
	ivh_exchangerate,
	ivh_loaded_distance,  --38823
	ivh_empty_distance,
	stlmnt_amt,
	ivh_paid_indicator, --PTS 41325 
	ivh_lastchecknumber,  --PTS 41325 
	ivh_lastcheckamount, --PTS 41325 
	ivh_totalpaid,         --PTS 41325 
	ivh_lastcheckdate, --PTS 41325 
	ivh_leaseid,
	ivh_leaseperiodenddate
	,ivh_gp_gl_postdate  --40260
	,ivh_nomincharges  --40260
	,orders_on_move  --40260
	,cmp_splitbillonrefnbr  --40260
	,multiaddrcount  --40260
	,car_key  --40260
	,ord_no_recalc_miles  --40260
	,ivh_invoiceby
	,ordercount
	,ivh_furthestpointconsignee
	,ord_roundbillqty   --48966
	,ivh_trailer2  -- 48966
	,ivh_reprint	--vjh 53851
	,ord_pallet_type	
	,ord_pallet_count
	,ivh_dbh_id          -- SGB 60008
	,ord_ratemode		-- 03/29/2012 NQIAO PTS 58978
	,ord_servicelevel	-- 03/29/2012 NQIAO PTS 58978
	,ord_servicedays	-- 03/29/2012 NQIAO PTS 58978		
	,dbh_custinvnum		-- 08/01/2012 NQIAO PTS 63136
	,ivh_gpserver		--PTS69481 MBR 07/12/13
	,ivh_gpdatabase		--PTS69481 MBR 07/12/13
	,ivh_splitgroup		-- PTS 63450 nloke
	,ivh_donotprint		--PTS66727 MBR 02/25/13	
	,ord_miscqty	--PTS 63937 JJF 20120927	
	,ord_miscqty_t --PTS 63937 JJF 20120927
	,ivh_subcompany
	,ivh_lh_charge	--PTS 94775 nloke
	,ivh_lh_charge_with_rollin --PTS 94775 nloke
	,ivh_rollin_lh_rate -- 94775 nloke
FROM @temp

GO
GRANT EXECUTE ON  [dbo].[d_inv_edit_hdr_sp] TO [public]
GO
