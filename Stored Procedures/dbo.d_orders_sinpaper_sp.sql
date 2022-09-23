SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

  
CREATE PROCEDURE [dbo].[d_orders_sinpaper_sp] ( @ps_date                varchar(10),  
         @ps_status              varchar(6),  
         @ps_dispstatus          varchar(6),  
         @ps_billto              varchar(255),  
         @ps_shipper             varchar(255),  
         @ps_consignee           varchar(255),  
         @ps_orderedby           varchar(255),  
         @pdtm_shipdate1         datetime,  
         @pdtm_shipdate2         datetime,  
         @pdtm_deldate1          datetime,  
         @pdtm_deldate2          datetime,  
         @ps_rev1                varchar(255),  
         @ps_rev2                varchar(255),  
         @ps_rev3                varchar(255),  
         @ps_rev4                varchar(255),  
         @ps_bookedrev1          varchar(255),  
         @pdtm_schearliest_date1 datetime,  
         @pdtm_schearliest_date2 datetime,  
         @ps_ord_status          varchar(255),  
         @ps_PwrkMarkedYesIni    varchar(30),  
         @ps_paperworkfilter     varchar(3),  
        --PTS 37241 2007-05-09 JJF  
         @ps_bookedby     varchar(255),  
         @ps_ordersource    varchar(255),  
        --END PTS 37241 2007-05-09 JJF  
         @ps_reftable            varchar(50),  
         @ps_reftype             varchar(6),  
         @ps_refnumber           varchar(30),
       	 @ps_othertype1			 varchar(255),		-- PTS 62654
		 @ps_othertype2			 varchar(255),		-- PTS 62654
		 @ps_othertype3			 varchar(255),		-- PTS 62654
         @ps_othertype4          varchar(255),      -- PTS 64009    
         @ps_cmpinvtypes      varchar(100),         -- PTS 62725 nloke
		 @ord_invoice_effectivedate1	datetime,	-- PTS 62719
		 @ord_invoice_effectivedate2	datetime	-- PTS 62719
)  
AS  
set nocount on
set transaction isolation level read uncommitted
/**  
*   !!!!!!!!!!!!!!!!!!!!!!! if the stops table does not have one stop with a stp_seuence of 1, this proc has join issues !!!!!!!!!!!!!!!!!!!!  
 *   
 * NAME:  
 * dbo.d_invoice_view_sp  
 *  
 * TYPE:  
 * StoredProcedure  
 *  
 * DESCRIPTION:  
 * This procedure retrieves the orders ready to invoice and checks the paperwork for each order  
 *  
 *  
 * RESULT SETS:   
 * lagtime                        Number of Days since Completion/Start of Order to now  
 * ord_shipper                    Shipper Company ID  
 * cmp_name                       Company Name of the Shipper  
 * ord_consignee                  Consignee Company ID  
 * cmp_name                       Company Name of the Consignee  
 * ord_billto                     Billto Company ID  
 * ord_company                    Orderby Company ID  
 * ord_startdate                  Start Date of the Order  
 * ord_completiondate             Completion Date of the Order  
 * ord_number                     Order Nmber  
 * mfh_hdrnumber                  Mfh_hdrnumber of the Delivery Stop  
 * ivh_invoicestatus              Invoice Status  
 * ord_hdrnumber                  Order Header Number  
 * ord_originpoint                Origin Point of the Order  
 * ord_destpoint                  Destination Point of the Order  
 * ord_originstate                Origin State of the Order  
 * ord_deststate                  Destination State of the Order  
 * ord_revtype1                   Order Revtype 1  
 * ord_revtype2                   Order Revtype 2  
 * ord_revtype3                   Order Revtype 3  
 * ord_revtype4                   Order Revtype 4  
 * mov_number                     Move Number  
 * ord_revtype1                   User Label for Revtype1  
 * ord_revtype2                   User Label for Revtype2  
 * ord_revtype3                   User Label for Revtype3  
 * ord_revtype4                   User Label for Revtype4  
 * ord_totalcharges               Total Charges of the Order  
 * origin                         Origin City State County  
 * destination                    Destiniation City State County  
 * paperwork                      Paperwork Status  
 * ord_status                     Order Status  
 * drv_id                         Min drv_id from the legheader(s) of the order  
 * ord_refnumber                  First orderheader referencenumber  
 *  
 * PARAMETERS:  
 * 001 - @ps_date                 varchar(10)     Flag to determine if LagTime is based on start or completion of the order  
 * 002 - @ps_status               varchar(6)      Invoice Status Restriction Criteria  
 * 003 - @ps_dispstatus           varchar(6)      GI MinOrdInvoiceStatus  
 * 004 - @ps_billto               varchar(8)      Billto Restriction Criteria  
 * 005 - @ps_shipper              varchar(8)      Shipper Restriction Criteria  
 * 006 - @ps_orderedby            varchar(8)      Ordered By Restriction Criteria  
 * 007 - @ps_consignee            varchar(8)      Consignee Restriction Criteria  
 * 008 - @pdtm_printdate          datetime        Date to compare the Billto's Last Printed MB Date  
 * 009 - @pdtm_shipdate1          datetime        Beginning of the Ship Date Range Restriction Criteria  
 * 010 - @pdtm_shipdate2          datetime        End of the Ship Date Range Restriction Criteria  
 * 011 - @pdtm_deldate1           datetime        Beginning of the Delivery Date Range Restriction Criteria  
 * 012 - @pdtm_deldate2           datetime        End of the Delivery Date Range Restriction Criteria  
 * 013 - @ps_rev1                 varchar(6)      Revtype1 Restriction Criteria  
 * 014 - @ps_rev2                 varchar(6)      Revtype2 Restriction Criteria  
 * 015 - @ps_rev3                 varchar(6)      Revtype3 Restriction Criteria  
 * 016 - @ps_rev4                 varchar(6)      Revtype4 Restriction Criteria  
 * 017 - @ps_bookedrev1           varchar(6)      BookedRevtype1 Restriction Criteria  
 * 018 - @pdtm_schearliest_date1  datetime        Beginning of the Scheduled Earliest Date Range Restriction Criteria  
 * 019 - @pdtm_schearliest_date2  datetime        End of the Scheduled Earliest Range Restriction Criteria  
 * 020 - @ps_ord_status           varchar(6)      Order Status Restriction  
 * 021 - @ps_PwrkMarkedYesIni     varchar(30)     PaperworkMarkedYes TTS50.ini setting  
 * 022 - @ps_paperworkfilter      varchar(3)      Paperwork Restriction Criteria  
 * 023 - @ps_bookedby     varchar(20)   booked by  
 * 024 - @ps_ordersource    varchar(6)   order source  
  
 *  
   
 *   
 * REVISION HISTORY:  
 * 09/08/2006 ? PTS34229 - Jason Bauwin ? Original Release  
 *  
 * 02/07/2007 - PTS 36141 - DJM - Added columns left out when converted to a proc.  
 * 05/09/2007 - 37241 JJF  
 * 06/04/2007 - PTS 36869 EMK Added required to invoice field on paperwork counts  
 * 01/30/08 DPETE PTS 40122 Add reference number restriction   
 * 11/14/2008 - PTS 33649 vjh add batch rate eligibility  
 * 01/01/08 DPETE allow for invoicing by move   
 * 2/5/9 DPETE 45913 reconcile 4 datawindows  
 * 2/16/09 DPETE PTS44417 invoice by move/consignee  
 * 04/21/09 vjh PTS47126 isnull  
 * 04/30/2010 SGB PTS 52051 restore support for PaperworkMarkedYes  
 * 05/27/2010 SGB PTS 49742 add ability to change Consignee based on GI setting  OrderInvoiceConsignee  
 * 06/08/2010 SGB PTS 52742 change top(1) to top 1 for SQL 2000 compliance  
 * 08/20/2010 SGB PTS 53009 Change Driver to ord_driver1  
 * 09/29/2010 SGB PTS 53511 Add logic to populate Notes Indicator   
 * 07/07/2011 MTC PTS 57693 Added nolocks on selects to reduce deadlocks when very a high volume DB  
 * 7/7/11 DPETE PTS 56313 need to be able to make mulitple selections in various fields  
 * 6/25/12 NQIAO PTS 62654 - add 4 new inputs (@ps_othertype1 ~ @ps_othertype4)
 * 9/25/2012 NLOKE PTS 62725 - Add logic to filter inv type
 * 07/16/2013 MTC PTS 62217 changed temp table to table variable to speed up updates and eliminate stats

 **/  
declare @vs_PaperWorkMode varchar(60), @vs_PaperWorkCheckLevel varchar(60), @vs_all_ppw_received varchar(3)  
declare @vi_label int, @vi_counter1 int, @vi_counter2 int, @vi_lgh_number int, @vi_billto_ppw_count int, @vi_ppw_received int  
declare @vi_minord INT, @vi_minleg INT, @vi_ppw_rec INT  
declare @vs_paperwork_status VARCHAR(3)  
declare @vs_GIusebatchrate char(1)   
  
--PTS 41236 JJF 20071128  
declare @rowsecurity char(1)  
--PTS 51570 JJF 20100510  
--declare @tmwuser varchar(255)  
--END PTS 51570 JJF 20100510  
--END PTS 41236 JJF 20071128  
declare @nextrec int ,@billto varchar(8),@invoiceby varchar(3),@chargescsv varchar(255),@ordhdrnumber int,@docsreq int,@docsrec int  
declare @OrderInvoiceConsignee char(1)  
-- PTS 53511 SGB 09/29/2010  
declare @INV_NOTESFILTER char(1)  
declare @Notes_Regarding varchar(6)  
declare @NOTE1 char(1)  
declare @Order int  
declare  @results table (lagtime    int    NULL,  
      ord_shipper   varchar(300)  NULL,  
      shipper_name  varchar(100) NULL,  
      ord_consignee  varchar(300)  NULL,  
      consignee_name  varchar(100) NULL,  
      ord_billto   varchar(380)  NULL,  
      ord_company   varchar(380)  NULL,  
      billto_name   varchar(100) NULL,  
      ord_startdate  datetime  NULL,  
      ord_completiondate datetime  NULL,  
      ord_number   char(100)  NULL,  
      mfh_hdrnumber  int    NULL,  
      ord_invoicestatus varchar(360)  NULL,  
      ord_hdrnumber  int    NULL,  
      ord_originpoint  varchar(380)  NULL,  
      ord_destpoint  varchar(380)  NULL,  
      ord_originstate  varchar(360)  NULL,  
      ord_deststate  varchar(360)  NULL,  
      ord_revtype1  varchar(360)  NULL,  
      ord_revtype2  varchar(360)  NULL,  
      ord_revtype3  varchar(360)  NULL,  
      ord_revtype4  varchar(360)  NULL,  
      mov_number   int    NULL,  
      ord_revtype1_t  varchar(80)  NULL,  
      ord_revtype2_t  varchar(80)  NULL,  
      ord_revtype3_t  varchar(80)  NULL,  
      ord_revtype4_t  varchar(80)  NULL,  
      ord_totalcharge  money   NULL,  
      origin    varchar(250)  NULL,  
      destination   varchar(250)  NULL,  
      stp_number   int    null,  
      stp_reftype   varchar(60)  null,  
      stp_refnum   varchar(300)  null,  
      ord_reftype   varchar(300)  null,  
      ord_refnum   varchar(300)  null,  
      stp_event   varchar(300)  null,  
      cmp_name   varchar(300)  null,  
      cty_name   varchar(300)  null,  
      stp_state   char(600)   null,  
      stp_arrivaldate  datetime  null,  
      stp_departuredate datetime  null,  
      linehaul   varchar(300)  null,  
      cht_description  varchar(300)  null,  
      charge    decimal(9,2) null,  
      ord_totalmiles  int    null,  
      ord_quantity  decimal(9,2) null,  
      stp_sequence  int    null,  
      paperwork   varchar(300)  null,  
      ord_status   varchar(300)  NULL,  
      drv_id    varchar(300)  NULL,  
      ord_refnumber  varchar(300)  NULL,  
      --PTS 37241 2007-05-09 JJF  
      ord_bookedby  char(200)  NULL,  
      ord_order_source varchar(300)  NULL  
      --END PTS 37241 2007-05-09 JJF  
                       ,cmp_invoiceby  varchar(300)  null  
                       ,ordsonmov   int    null  
                       ,rti_ident   int identity(1,1) primary key  
                      ,notes_flag char(1) -- PTS 53511 SGB   
                       )  
/* build a table of orders ready to invoice and moves ready to invoice */  
  
declare @movs table(ord_billto varchar(8) null, mov_number int null, ord_number varchar(12) NULL, ord_hdrnumber int null, ordsonmov int null, firstpupstop int null,  lastdrpstop int null,totalcharge money null)  
declare @notreadymoves table(mov_number int null,ord_billto varchar(8) null)  
declare @movcons table(ord_billto varchar(8)null, mov_number int null,ord_consignee varchar(8) null, ord_number varchar(12) NULL, ord_hdrnumber int null, ordsonmov int null, firstpupstop int null,  lastdrpstop int null,totalcharge money null)  
declare @notreadymovecons table(mov_number int null,ord_billto varchar(8)null ,ord_consignee varchar(8) null)  
declare @reftype varchar(6),@vi_mov int  
declare @ordsonleg table (ord_hdrnumber int)  
declare @vi_billto varchar(8), @vi_countinvoicebymov int, @vi_countinvoicebymovcon int  
declare @MinDispStatusCode varchar(6)
declare @ordswithstop table (ord_hdrnumber int, stp_number int) 
Declare @companies table (cmp_id varchar(8))   --62725


insert into @ordswithstop
select ord_hdrnumber,0
from orderheader WITH (NOLOCK)  where ord_invoicestatus = @ps_status

/* build a table of candidate orders with link to a sinlge stop for comparison - the first PUP stop */
--PTS70728 MBR 07/24/13  Rewrote the next update to work correctly.  It was pulling the same 
--stp_number into every order.

UPDATE @ordswithstop 
   SET stp_number = (SELECT TOP 1 stops.stp_number
                       FROM stops
                      WHERE stops.ord_hdrnumber = ord.ord_hdrnumber
                      ORDER BY stops.stp_arrivaldate, stops.stp_sequence, stops.stp_number)
  FROM @ordswithstop ord

-- when @ps_dispstatus is passed they want t make sure this is the minimum status on the orders selected  
select @MinDispStatusCode = l2.code from labelfile l2 with (NOLOCK)  
where l2.labeldefinition = 'DispStatus'   
and l2.abbr = @ps_dispstatus  
select @MinDispStatusCode = ISNULL(@MinDispStatusCode,0)  
  
if @ps_billto is null or rtrim(@ps_billto) = '' select @ps_billto = '%'   
if @ps_shipper is null or rtrim(@ps_shipper) = '' select @ps_shipper = '%'   
if @ps_consignee is null or rtrim(@ps_consignee) = '' select @ps_consignee = '%'   
if @ps_orderedby is null or rtrim(@ps_orderedby) = '' select @ps_orderedby = '%'  
if @ps_rev1 is null or rtrim(@ps_rev1) = '' select @ps_rev1 = '%'    
if @ps_rev2 is null or rtrim(@ps_rev2) = '' select @ps_rev2 = '%'   
if @ps_rev3 is null or rtrim(@ps_rev3) = '' select @ps_rev3 = '%'   
if @ps_rev4 is null or rtrim(@ps_rev4) = '' select @ps_rev4 = '%'   
if @ps_bookedrev1 is null or rtrim(@ps_bookedrev1) = '' select @ps_bookedrev1 = '%'  
if @ps_bookedby is null or rtrim(@ps_bookedby) = '' select @ps_bookedby = '%'  
if @ps_ordersource is null or rtrim(@ps_ordersource) = '' select @ps_ordersource = '%'  
if @ps_othertype1 is null or RTRIM(@ps_othertype1) = '' or substring(@ps_othertype1, 1, 3) = 'UNK' select @ps_othertype1 = '%'		-- PTS 62654
if @ps_othertype2 is null or RTRIM(@ps_othertype2) = '' or substring(@ps_othertype2, 1, 3) = 'UNK' select @ps_othertype2 = '%'		-- PTS 62654
if @ps_othertype3 is null or RTRIM(@ps_othertype3) = '' or substring(@ps_othertype3, 1, 3) = 'UNK' select @ps_othertype3 = '%'		-- PTS 62654
if @ps_othertype4 is null or RTRIM(@ps_othertype4) = '' or substring(@ps_othertype4, 1, 3) = 'UNK' select @ps_othertype4 = '%'		-- PTS 62654	
if @ps_billto <> '%'  SELECT @ps_billto = (',' + @ps_billto + ',')  
if @ps_shipper <> '%'  SELECT @ps_shipper = ',' + @ps_shipper + ','  
if @ps_consignee <> '%'  SELECT @ps_consignee = ',' + @ps_consignee + ','  
if @ps_orderedby <> '%'  SELECT @ps_orderedby = ',' + @ps_orderedby + ','  
if @ps_rev1 <> '%' SELECT  @ps_rev1 = ',' + @ps_rev1 + ','  
if @ps_rev2 <> '%'  SELECT @ps_rev2 = ',' + @ps_rev2 + ','  
if @ps_rev3 <> '%'  SELECT @ps_rev3 = ',' + @ps_rev3 + ','  
if @ps_rev4 <> '%'  SELECT @ps_rev4 = ',' + @ps_rev4 + ','  
if @ps_bookedrev1 <> '%'  SELECT @ps_bookedrev1 = ',' + @ps_bookedrev1 + ','  
-- DEFAULT value for this field is UNK it is set on the old restrictions screen  
if @ps_ord_status = 'UNK' or  @ps_ord_status = '' or  @ps_ord_status is null   
  SELECT @ps_ord_status = '%'  
else    
   SELECT @ps_ord_status = ',' + @ps_ord_status + ','  
if @ps_bookedby <> '%' SELECT @ps_bookedby = ',' + RTRIM(@ps_bookedby) + ','  
if @ps_ordersource <> '%' SELECT @ps_ordersource = ',' + @ps_ordersource + ','  
if @ps_othertype1 <> '%'  SELECT @ps_othertype1 = ',' + @ps_othertype1 + ','		-- PTS 62654
if @ps_othertype2 <> '%'  SELECT @ps_othertype2 = ',' + @ps_othertype2 + ','		-- PTS 62654
if @ps_othertype3 <> '%'  SELECT @ps_othertype3 = ',' + @ps_othertype3 + ','		-- PTS 62654
if @ps_othertype4 <> '%'  SELECT @ps_othertype4 = ',' + @ps_othertype4 + ','		-- PTS 62654    

  
 --PTS 52051 SGB If TTS50 setting passes 'ONE' use it otherwise check the GI table  
 If @ps_PwrkMarkedYesIni  <> 'ONE'  
 BEGIN  
  Select @ps_PwrkMarkedYesIni =  isnull(gi_string1,'ALL') from generalinfo with (NOLOCK) where gi_name = 'ps_PwrkMarkedYesIni'  
    
 END  
--   05/27/2010 SGB PTS 49742  
select @OrderInvoiceConsignee = isnull(gi_string1,'N') from generalinfo with (NOLOCK) where gi_name = 'OrderInvoiceConsignee'   
  
-- PTS 53511 SGB 09/29/2010  
Select @INV_NOTESFILTER = isnull(gi_string1,'N'),@Notes_Regarding =  isnull(gi_string2,'B') from generalinfo with (NOLOCK) where gi_name = 'INV_NotesFilter'   
  
  
  
select @reftype = gi_string1 from generalinfo with (nolock) where gi_name = 'InvProcessOrdRefType'  
select @reftype = isnull(@reftype,'')  
  
select @vs_GIusebatchrate =isnull(gi_string1,'N')   
   from generalinfo with (nolock)  
   where gi_name = 'use_ord_batchrateeligibility'  
select @vs_GIusebatchrate  = isnull(@vs_GIusebatchrate,'N')  
if @vs_GIusebatchrate  <> 'Y' select @vs_GIusebatchrate = 'N'  
  
/*   ******** SET UP WORK TABLE @movs FOR INVOICE BY MOVE **************  */  
if exists (select 1 from company where cmp_billto = 'Y' and cmp_invoiceby = 'MOV')  
  BEGIN  -- build of @movs tale of moves to be invoice by bill to   
    Insert into @movs(ord_billto, mov_number,ord_number,ord_hdrnumber,ordsonmov, totalcharge)  
    select  ord_billto  -- billto  
    , orderheader.mov_number  
    , min(ord_number)  -- put smallest order number on the invoice by move  
    , MIN(orderheader.ord_hdrnumber)  
    , count(*)  
    ,  sum(ord_totalcharge)  
    from @ordswithstop  ords
    join orderheader with (nolock) on ords.ord_hdrnumber = orderheader.ord_hdrnumber  
    left outer join company with (nolock) on ord_billto = cmp_id  
    --left outer join stops with (nolock) ON orderheader.ord_hdrnumber = stops.ord_hdrnumber and stops.stp_sequence = 1 
    left outer join stops with (NOLOCK) on ords.stp_number = stops.stp_number 
    left outer join  labelfile LBLForDStatus with (NOLOCK) on (orderheader.ord_status = LBLForDStatus.abbr and LBLForDStatus.labeldefinition = 'DispStatus')  
    /*  
    join @billtos bc  on (orderheader.ord_billto = bc.cmp_id or bc.cmp_id = '%')  
    join @shippers sc  on (orderheader.ord_shipper = sc.cmp_id or sc.cmp_id = '%')  
    join @consignees cc  on (orderheader.ord_consignee = cc.cmp_id or cc.cmp_id = '%')  
    join @orderbys obc  on (orderheader.ord_company = obc.cmp_id or obc.cmp_id = '%')  
    join @rev1 r1 on (orderheader.ord_revtype1 = r1.abbr or r1.abbr = '%')  
    join @rev1 r2 on (orderheader.ord_revtype1 = r2.abbr or r2.abbr = '%')  
    join @rev1 r3 on (orderheader.ord_revtype1 = r3.abbr or r3.abbr = '%')  
    join @rev1 r4 on (orderheader.ord_revtype1 = r4.abbr or r4.abbr = '%')  
    join @bookedrevs br on (orderheader.ord_booked_revtype1 = br.abbr or br.abbr = '%')  
    join @bookedbys bb on (orderheader.ord_bookedby = bb.ttsuser or bb.ttsuser = '%')  
    join @dispstatuses ds on orderheader.ord_status = ds.abbr  
    join @ordersources os on (orderheader.ord_order_source = os.abbr or os.abbr = '%')   
    */  
    where   isnull(company.cmp_invoiceby,'ORD') = 'MOV' AND  
    ( orderheader.ord_invoicestatus = @ps_status ) and   
    ( orderheader.ord_status <> 'CAN' )  AND   
    ( orderheader.ord_startdate between @pdtm_shipdate1 and @pdtm_shipdate2 ) AND   
    ( orderheader.ord_completiondate between @pdtm_deldate1 and @pdtm_deldate2 ) AND  
    (  
     (  
      ord_batchrateeligibility = 'Y' and isnull(ord_batchratestatus,'') not in ('S','P','F') and  
      @vs_GIusebatchrate='Y')  
     OR @vs_GIusebatchrate = 'N'  
    ) AND  
    stops.stp_schdtearliest between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2 --AND  
    --orderheader.ord_status = (Case when @ps_ord_status = 'UNK'   
    --                            then orderheader.ord_status  
    --     else @ps_ord_status  
    --      End )  
 and isnull(LBLForDStatus.code,9999) >= @MinDispStatusCode  
 and  (@ps_billto = '%' or        CHARINDEX( ','+ ord_billto + ',' ,@ps_billto ) > 0)  
 and  (@ps_shipper = '%' or       CHARINDEX( ',' + ord_shipper + ',',@ps_shipper ) > 0)  
    and  (@ps_orderedby = '%' or     CHARINDEX(',' + ord_company + ',',@ps_orderedby ) > 0)  
    and  (@OrderInvoiceConsignee = 'Y' or @ps_consignee = '%' or CHARINDEX(',' + orderheader.ord_consignee + ',', @ps_consignee ) > 0) --PTS49742 SGB if @OrderInvoiceConsignee = 'Y' filter later  
    and  (@ps_rev1 = '%' or          CHARINDEX(',' + ord_revtype1 + ',',@ps_rev1) > 0)  
    and  (@ps_rev2 = '%' or          CHARINDEX(',' + ord_revtype1 + ',',@ps_rev2) > 0)  
    and  (@ps_rev3 = '%' or          CHARINDEX(','+ ord_revtype3 + ',',@ps_rev3) > 0)  
    and  (@ps_rev4 = '%' or          CHARINDEX(','+ ord_revtype4 + ',',@ps_rev4) > 0)  
    and  (@ps_ord_status ='%' or     CHARINDEX(',' + ord_status + ',', @ps_ord_status ) > 0)  
    and  (@ps_bookedby = '%'  or     CHARINDEX(','+ RTRIM(ord_bookedby) + ',', @ps_bookedby ) > 0 )   -- RTRIM NECESSARY 
    and  (@ps_ordersource = '%'  or  CHARINDEX(',' + ord_order_source + ',' , @ps_ordersource  ) > 0 )
    and  (@ps_bookedrev1 = '%'  or  CHARINDEX(',' + ord_booked_revtype1 + ',' , @ps_bookedrev1  ) > 0 )   
 
      
    /* ( orderheader.ord_billto like @ps_billto ) AND   
    ( orderheader.ord_shipper like @ps_shipper ) AND   
    ( (@OrderInvoiceConsignee = 'Y') or orderheader.ord_consignee like @ps_consignee ) AND --PTS49742 SGB if @OrderInvoiceConsignee = 'Y' filter later  
    ( orderheader.ord_company like @ps_orderedby ) AND   
    ( orderheader.ord_startdate between @pdtm_shipdate1 and @pdtm_shipdate2 ) AND   
    ( orderheader.ord_completiondate between @pdtm_deldate1 and @pdtm_deldate2 ) AND   
    ( orderheader.ord_revtype1 like @ps_rev1 ) AND   
    ( orderheader.ord_revtype2 like @ps_rev2 ) AND   
    ( orderheader.ord_revtype3 like @ps_rev3 ) AND   
    ( orderheader.ord_revtype4 like @ps_rev4 ) AND   
    ( IsNull(orderheader.ord_booked_revtype1,'') like @ps_bookedRev1 )  AND  
    --PTS 37241 2007-05-09 JJF  
    (ISNULL(orderheader.ord_bookedby, '') like @ps_bookedby) AND  
    (ISNULL(orderheader.ord_order_source, '') like @ps_ordersource) AND  
    --END PTS 37241 2007-05-09 JJF   
    (  
     (  
      ord_batchrateeligibility = 'Y' and isnull(ord_batchratestatus,'') not in ('S','P','F') and  
      @vs_GIusebatchrate='Y')  
     OR @vs_GIusebatchrate = 'N'  
    ) AND  
   ord_status = (Case   
  when @ps_dispstatus = '' OR @ps_dispstatus is null then ord_status   
  Else   
   (select isNull(l1.abbr,'ZZZ')  
   from labelfile l1 with (nolock)  
   where l1.labeldefinition = 'DispStatus'  
   and l1.code >= (select l2.code from labelfile l2 where l2.labeldefinition = 'DispStatus' and l2.abbr = @ps_dispstatus)  
   and l1.abbr = ord_status)  
   End) AND   
    stops.stp_schdtearliest between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2 AND  
    orderheader.ord_status = (Case when @ps_ord_status = 'UNK'   
                                then orderheader.ord_status  
         else @ps_ord_status  
          End ) */  
    GROUP BY orderheader.mov_number, ord_billto  
  
    /* make sure ord_hdrnumber matches that for the min ord_number */  
    update @movs  
    set ord_hdrnumber = orderheader.ord_hdrnumber  
    from @movs mov join orderheader  WITH (NOLOCK) on mov.ord_number = orderheader.ord_number  
  
    /* if any of the orders for this bill to on this move are not ready to invoice, then eliminate */  
  
    insert into @notreadymoves  
    select distinct orderheader.mov_number,orderheader.ord_billto  
    from @movs movs join orderheader with (nolock) on movs.mov_number = orderheader.mov_number and movs.ord_billto = orderheader.ord_billto  
    where orderheader.ord_invoicestatus not in ('AVL','PPD','XIN')  
    -- tag move number bill to combos where any of hteorders is not complete  
    update @movs   
    set mov_number = 0  
    from @movs mov  
    join @notreadymoves nrm on mov.mov_number = nrm.mov_number and mov.ord_billto = nrm.ord_billto  
    -- then remove them  
    delete from @movs where mov_number = 0  
  
    /* find the first pup and last drop on the move as proxy for the shipper and consignee */  
    update @movs  
    set firstpupstop = (select top 1 stp_number   
       from orderheader ord with (nolock)  
       join stops  with (nolock) on ord.ord_hdrnumber = stops.ord_hdrnumber   
       where ord.mov_number = movs.mov_number   
       and ord.ord_billto = movs.ord_billto  
       and stp_type = 'PUP'   
       order by stp_mfh_sequence)  
    ,lastdrpstop = (select top 1 stp_number   
       from orderheader ord with (nolock)  
       join stops with (nolock) on ord.ord_hdrnumber = stops.ord_hdrnumber   
       where ord.mov_number = movs.mov_number   
       and ord.ord_billto = movs.ord_billto  
       and stp_type = 'DRP'   
       order by stp_mfh_sequence DESC)  
    from @movs movs  
  
    select  @vi_countinvoicebymov = count(*) from @movs  
  
 END  -- build of @movs tale of moves to be invoice by bill to   
/*  ******** SET UP WORK TABLE @movs FOR INVOICE BY MOVE / CONSIGNEE **************  */  
if exists (select 1 from company  with (nolock) where cmp_billto = 'Y' and cmp_invoiceby = 'CON')  
  BEGIN   -- build of @movcons tale of moves to be invoice by bill to and consignee   
    Insert into @movcons(ord_billto, mov_number,ord_consignee, ord_number,ord_hdrnumber,ordsonmov, totalcharge)  
    select  ord_billto  -- billto  
    , orderheader.mov_number  
    , ord_consignee  
    , min(ord_number)  -- put smallest order number on the invoice by move  
    , MIN(orderheader.ord_hdrnumber)  
    , count(*)  
    ,  sum(ord_totalcharge)  
    from @ordswithstop ords
    join orderheader with (nolock) on ords.ord_hdrnumber = orderheader.ord_hdrnumber  
    left outer join company with (nolock) on ord_billto = cmp_id  
    --left outer join stops  with (nolock) ON orderheader.ord_hdrnumber = stops.ord_hdrnumber and stops.stp_sequence = 1
    join stops with (NOLOCK) on ords.stp_number = stops.stp_number  
    left outer join  labelfile LBLForDStatus with (NOLOCK) on (orderheader.ord_status = LBLForDStatus.abbr and LBLForDStatus.labeldefinition = 'DispStatus')  
    where   isnull(company.cmp_invoiceby,'ORD') = 'CON' AND  
    ( orderheader.ord_invoicestatus = @ps_status ) and   
    ( orderheader.ord_status <> 'CAN' ) AND   
     ( orderheader.ord_startdate between @pdtm_shipdate1 and @pdtm_shipdate2 ) AND   
    ( orderheader.ord_completiondate between @pdtm_deldate1 and @pdtm_deldate2 ) AND   
    ( stops.stp_schdtearliest between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2)  and  
     (  
     (ord_batchrateeligibility = 'Y' and isnull(ord_batchratestatus,'') not in ('S','P','F') and  
      @vs_GIusebatchrate='Y')  
     OR @vs_GIusebatchrate = 'N'  
    )  
       
   
 and isnull(LBLForDStatus.code,9999) >= @MinDispStatusCode   
 and  (@ps_billto = '%' or        CHARINDEX( ','+ ord_billto + ',' ,@ps_billto ) > 0)  
 and  (@ps_shipper = '%' or       CHARINDEX( ',' + ord_shipper + ',',@ps_shipper ) > 0)  
    and  (@ps_orderedby = '%' or     CHARINDEX(',' + ord_company + ',',@ps_orderedby ) > 0)  
    and  (@OrderInvoiceConsignee = 'Y' or @ps_consignee = '%' or CHARINDEX(',' + orderheader.ord_consignee + ',', @ps_consignee ) > 0) --PTS49742 SGB if @OrderInvoiceConsignee = 'Y' filter later  
    and  (@ps_rev1 = '%' or          CHARINDEX(',' + ord_revtype1 + ',',@ps_rev1) > 0)  
    and  (@ps_rev2 = '%' or          CHARINDEX(',' + ord_revtype1 + ',',@ps_rev2) > 0)  
    and  (@ps_rev3 = '%' or          CHARINDEX(','+ ord_revtype3 + ',',@ps_rev3) > 0)  
    and  (@ps_rev4 = '%' or          CHARINDEX(','+ ord_revtype4 + ',',@ps_rev4) > 0)  
    and  (@ps_ord_status ='%' or     CHARINDEX(',' + ord_status + ',', @ps_ord_status ) > 0)  
    and  (@ps_bookedby = '%'  or     CHARINDEX(','+ RTRIM(ord_bookedby) + ',', @ps_bookedby ) > 0 )    -- RTRIM NECESSARY  
    and  (@ps_ordersource = '%'  or  CHARINDEX(',' + ord_order_source + ',' , @ps_ordersource  ) > 0 ) 
    and  (@ps_bookedrev1 = '%'  or  CHARINDEX(',' + ord_booked_revtype1 + ',' , @ps_bookedrev1  ) > 0 )    
      
    /*  
    and     orderheader.ord_status = (Case when @ps_ord_status = 'UNK'   
                                then orderheader.ord_status  
         else @ps_ord_status  
          End )  
    ( orderheader.ord_billto like @ps_billto ) AND   
    ( orderheader.ord_shipper like @ps_shipper ) AND   
    ( (@OrderInvoiceConsignee = 'Y') or orderheader.ord_consignee like @ps_consignee ) AND --PTS49742 SGB if @OrderInvoiceConsignee = 'Y' filter later  
    ( orderheader.ord_company like @ps_orderedby ) AND   
    ( orderheader.ord_startdate between @pdtm_shipdate1 and @pdtm_shipdate2 ) AND   
    ( orderheader.ord_completiondate between @pdtm_deldate1 and @pdtm_deldate2 ) AND   
   ( orderheader.ord_revtype1 like @ps_rev1 ) AND   
    ( orderheader.ord_revtype2 like @ps_rev2 ) AND   
    ( orderheader.ord_revtype3 like @ps_rev3 ) AND   
    ( orderheader.ord_revtype4 like @ps_rev4 ) AND   
    ( IsNull(orderheader.ord_booked_revtype1,'') like @ps_bookedRev1 )  AND   
    --PTS 37241 2007-05-09 JJF  
    (ISNULL(orderheader.ord_bookedby, '') like @ps_bookedby) AND  
    (ISNULL(orderheader.ord_order_source, '') like @ps_ordersource) AND   
    --END PTS 37241 2007-05-09 JJF  
    (  
     (  
      ord_batchrateeligibility = 'Y' and isnull(ord_batchratestatus,'') not in ('S','P','F') and  
      @vs_GIusebatchrate='Y')  
     OR @vs_GIusebatchrate = 'N'  
    ) AND  
   ord_status = (Case   
  when @ps_dispstatus = '' OR @ps_dispstatus is null then ord_status   
  Else   
   (select isNull(l1.abbr,'ZZZ')  
   from labelfile l1 with (nolock)   
   where l1.labeldefinition = 'DispStatus'  
   and l1.code >= (select l2.code from labelfile l2  with (nolock) where l2.labeldefinition = 'DispStatus' and l2.abbr = @ps_dispstatus)  
   and l1.abbr = ord_status)  
   End) AND   
    stops.stp_schdtearliest between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2 AND  
    orderheader.ord_status = (Case when @ps_ord_status = 'UNK'   
                                then orderheader.ord_status  
         else @ps_ord_status  
          End ) */  
    GROUP BY orderheader.mov_number,ord_billto,ord_consignee  
  
    /* make sure ord_hdrnumber matches that for the min ord_number */  
    update @movcons  
    set ord_hdrnumber = orderheader.ord_hdrnumber  
    from @movcons mov join orderheader  with (nolock) on mov.ord_number = orderheader.ord_number  
  
    /* if any of the orders for this bill to on this move are not ready to invoice, then eliminate */  
  
    insert into @notreadymovecons  
    select distinct orderheader.mov_number,orderheader.ord_billto,orderheader.ord_consignee  
    from @movcons movs   
    join orderheader  with (nolock) on movs.mov_number = orderheader.mov_number   
      and movs.ord_billto = orderheader.ord_billto   
      and movs.ord_consignee = orderheader.ord_consignee  
    where orderheader.ord_invoicestatus not in ('AVL','PPD','XIN')  
    -- tag move number bill to combos where any of hteorders is not complete  
    update @movcons   
    set mov_number = 0  
    from @movcons mov  
    join @notreadymovecons nrm on mov.mov_number = nrm.mov_number   
        and mov.ord_billto = nrm.ord_billto  
        and mov.ord_consignee = nrm.ord_consignee  
  
    -- then remove them  
    delete from @movs where mov_number = 0  
  
    /* find the first pup and last drop on the move proxy for the shipper and consignee */  
    update @movcons  
    set firstpupstop = (select top 1 stp_number   
         from orderheader ord with (nolock)   
         join stops  with (nolock) on ord.ord_hdrnumber = stops.ord_hdrnumber   
         where ord.mov_number = movs.mov_number   
         and ord.ord_billto = movs.ord_billto  
         and stp_type = 'PUP'   
         order by stp_mfh_sequence)  
    ,lastdrpstop = (select top 1 stp_number   
         from orderheader ord with (nolock)   
         join stops  with (nolock) on ord.ord_hdrnumber = stops.ord_hdrnumber   
         where ord.mov_number = movs.mov_number   
         and ord.ord_billto = movs.ord_billto  
         and stp_type = 'DRP'   
         order by stp_mfh_sequence DESC)  
    from @movcons movs  
  
    select  @vi_countinvoicebymovcon = count(*) from @movcons  
  
  END   -- build of @movcons tale of moves to be invoice by bill to and consignee   
    
 /* SPLIT OUT CHECK FOR STOP DATE BECASUE PROBLEMS WITH STP_SEQUENCE NUMBERS CAUSE US TO LOSE RECORDS RETRIEVED */


  
-- ************  RETRIEVE ORDERS INVOICED BY ORDER   ***************  
--PTS 37241 2007-05-09 JJF  
--INSERT INTO @results (lagtime, ord_shipper, shipper_name, ord_consignee, consignee_name, ord_billto, ord_company, billto_name,   
--ord_startdate, ord_completiondate, ord_number, mfh_hdrnumber, ord_invoicestatus, ord_hdrnumber,   
--ord_originpoint, ord_destpoint, ord_originstate, ord_deststate, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4,  
-- mov_number, ord_revtype1_t, ord_revtype2_t, ord_revtype3_t, ord_revtype4_t, ord_totalcharge, origin, destination,   
--paperwork, ord_status, drv_id, ord_refnumber)  
INSERT INTO @results (lagtime, ord_shipper, shipper_name, ord_consignee, consignee_name, ord_billto, ord_company  
, billto_name, ord_startdate, ord_completiondate, ord_number, mfh_hdrnumber, ord_invoicestatus, ord_hdrnumber  
, ord_originpoint, ord_destpoint, ord_originstate, ord_deststate, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4  
, mov_number, ord_revtype1_t, ord_revtype2_t, ord_revtype3_t, ord_revtype4_t, ord_totalcharge, origin, destination  
,stp_number,stp_reftype,stp_refnum,ord_reftype,ord_refnum,stp_event,cmp_name,cty_name,stp_state,stp_arrivaldate  
,stp_departuredate,linehaul,cht_description,charge,ord_totalmiles,ord_quantity,stp_sequence  
, paperwork, ord_status, drv_id, ord_refnumber, orderheader.ord_bookedby, orderheader.ord_order_source,cmp_invoiceby ,ordsonmov )  
--END PTS 37241 2007-05-09 JJF  
SELECT Case @ps_date   
         when 'end'   
         then datediff(day, orderheader.ord_completiondate,getdate() )  
   else datediff(day, orderheader.ord_startdate,getdate() )  
     end,  
       orderheader.ord_shipper,   
       company_a.cmp_name,   
       orderheader.ord_consignee,   
       company_b.cmp_name,   
       orderheader.ord_billto,   
       orderheader.ord_company,   
       company_c.cmp_name,   
       orderheader.ord_startdate,   
       orderheader.ord_completiondate,   
       orderheader.ord_number,   
       orderheader.mfh_hdrnumber,   
       orderheader.ord_invoicestatus,   
       orderheader.ord_hdrnumber,   
       orderheader.ord_originpoint,   
       orderheader.ord_destpoint,   
       orderheader.ord_originstate,   
       orderheader.ord_deststate,   
       orderheader.ord_revtype1,   
       orderheader.ord_revtype2,   
       orderheader.ord_revtype3,   
       orderheader.ord_revtype4,   
       orderheader.mov_number ,   
       'RevType1' revtype1,   
       'RevType2' revtype2,   
       'RevType3' revtype3,   
       'RevType4' revtype4,   
       orderheader.ord_totalcharge,  
       company_a.cty_nmstct origin,   
       company_b.cty_nmstct destination,  
          stops.stp_number,  
          stp_reftype,  
          stp_refnum,  
          ord_reftype,  
          ord_refnum,  
          stp_event,    
          stops.cmp_name,  
          city.cty_name,  
          stp_state,  
          stp_arrivaldate,  
          stp_departuredate,  
          '                              ' linehaul,  
    '                              ' cht_description,  
    0.00 charge,  
    0 ord_totalmiles,  
    0.00 ord_quantity,  
    stp_sequence,  
       'Yes' paperwork,  -- 'No' paperwork  
       orderheader.ord_status,  
       --(select min(lgh_driver1) from legheader where legheader.ord_hdrnumber = orderheader.ord_hdrnumber) drv_id, -- PTS 53009 SGB  
       ord_driver1 drv_id,  
       (select min(ref_number)  
          from referencenumber r1 with (nolock)   
         where r1.ref_table = 'orderheader'  
           and r1.ref_type = (select gi_string1 from generalinfo  WITH (NOLOCK) where gi_name = 'InvProcessOrdRefType')  
           and r1.ref_sequence = (select min(ref_sequence)   
                                    from referencenumber r2 with (nolock)   
                                   where r2.ref_table = r1.ref_table  
                                     and r2.ref_type= r1.ref_type  
                                     and r2.ref_tablekey = r1.ref_tablekey)  
           and r1.ref_tablekey = orderheader.ord_hdrnumber) ord_refnumber,  
  --PTS 37241 2007-05-09 JJF  
  orderheader.ord_bookedby,   
  orderheader.ord_order_source  
  --END PTS 37241 2007-05-09 JJF  
      ,isnull(company_c.cmp_invoiceby ,'ORD') cmp_invoiceby  
      , 1 ordsonmove  
/*  ADD ANYTHING ABOVE AND ALSO CHANGE   
      d_orders_ready_for_invoice_report,   
      d_orders_ready_for_invoice_report_cryogenics,  
      d_orders_ready_for_invoic  
*/  
  FROM @ordswithstop ords
       join orderheader  with (nolock) on ords.ord_hdrnumber = orderheader.ord_hdrnumber   
       LEFT OUTER JOIN company company_a  with (nolock) ON orderheader.ord_shipper = company_a.cmp_id   
       LEFT OUTER JOIN company company_b  with (nolock) ON orderheader.ord_consignee = company_b.cmp_id    
       JOIN company company_c  with (nolock) ON orderheader.ord_billto = company_c.cmp_id   
       --left outer join stops with (NOLOCK) ON orderheader.ord_hdrnumber = stops.ord_hdrnumber and stops.stp_sequence = 1 
       join stops with (NOLOCK) on ords.stp_number = stops.stp_number 
       join city  with (nolock) on stops.stp_city = cty_code  
    left outer join  labelfile LBLForDStatus with (NOLOCK) on (orderheader.ord_status = LBLForDStatus.abbr and LBLForDStatus.labeldefinition = 'DispStatus')  
 WHERE  
( orderheader.ord_invoicestatus = @ps_status ) and   
( orderheader.ord_status <> 'CAN' ) AND  
( isnull(orderheader.ord_startdate,'19500101 00:00') between @pdtm_shipdate1 and @pdtm_shipdate2 ) AND   
( ISNULL(orderheader.ord_completiondate,'2049 23:59:59') between @pdtm_deldate1 and @pdtm_deldate2 ) AND  
(ISNULL(stops.stp_schdtearliest,'19500101 00:00') between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2) AND   
(  
     (  
      ord_batchrateeligibility = 'Y' and isnull(ord_batchratestatus,'') not in ('S','P','F') and  
      @vs_GIusebatchrate='Y')  
     OR @vs_GIusebatchrate = 'N'  
    )   
  --orderheader.ord_status = (Case when @ps_ord_status = 'UNK'   
  --                                  then orderheader.ord_status  
  --         else @ps_ord_status  
  --        End )  
and isnull(company_c.cmp_invoiceby,'ORD') = 'ORD'   
  
and isnull(LBLForDStatus.code,9999) >= @MinDispStatusCode  
and  (@ps_billto = '%' or        CHARINDEX( ','+ ord_billto + ',' ,@ps_billto ) > 0)  
and  (@ps_shipper = '%' or       CHARINDEX( ',' + ord_shipper + ',',@ps_shipper ) > 0)  
and  (@ps_orderedby = '%' or     CHARINDEX(',' + ord_company + ',',@ps_orderedby ) > 0)  
and  (@OrderInvoiceConsignee = 'Y' or @ps_consignee = '%' or CHARINDEX(',' + orderheader.ord_consignee + ',', @ps_consignee ) > 0) --PTS49742 SGB if @OrderInvoiceConsignee = 'Y' filter later  
and  (@ps_rev1 = '%' or          CHARINDEX(',' + ISNULL(ord_revtype1,'UNK') + ',',@ps_rev1) > 0)  
and  (@ps_rev2 = '%' or          CHARINDEX(',' + ISNULL(ord_revtype2,'UNK') + ',',@ps_rev2) > 0)  
and  (@ps_rev3 = '%' or          CHARINDEX(','+ ISNULL(ord_revtype3,'UNK') + ',',@ps_rev3) > 0)  
and  (@ps_rev4 = '%' or          CHARINDEX(','+ ISNULL(ord_revtype4,'UNK') + ',',@ps_rev4) > 0)  
and  (@ps_ord_status ='%' or     CHARINDEX(',' + ord_status + ',', @ps_ord_status ) > 0)  
and  (@ps_bookedby = '%'  or     CHARINDEX(','+ RTRIM(ord_bookedby) + ',', @ps_bookedby ) > 0 )     -- RTRIM NECESSARY 
and  (@ps_ordersource = '%'  or  CHARINDEX(',' + ord_order_source + ',' , @ps_ordersource  ) > 0 ) 
and  (@ps_bookedrev1 = '%'  or  CHARINDEX(',' + ord_booked_revtype1 + ',' , @ps_bookedrev1  ) > 0 )   
and  (@ps_othertype1 = '%' or CHARINDEX( ',' + company_c.cmp_othertype1 + ',',@ps_othertype1) > 0)		-- 62654
and  (@ps_othertype2 = '%' or CHARINDEX( ',' + company_c.cmp_othertype2 + ',',@ps_othertype2) > 0)		-- 62654
and  (@ps_othertype3 = '%' or CHARINDEX( ',' + company_c.cmp_othertype3 + ',',@ps_othertype3) > 0)		-- 62654
and  (@ps_othertype4 = '%' or CHARINDEX( ',' + company_c.cmp_othertype4 + ',',@ps_othertype4) > 0)		-- 62654
and	 (isnull(orderheader.ord_invoice_effectivedate,'19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2 )	-- 62719  

/******** add mov number invoices *********/  
  
if @vi_countinvoicebymov > 0  
  INSERT INTO @results (lagtime, ord_shipper, shipper_name, ord_consignee, consignee_name, ord_billto, ord_company, billto_name  
, ord_startdate, ord_completiondate, ord_number, mfh_hdrnumber, ord_invoicestatus, ord_hdrnumber, ord_originpoint, ord_destpoint,   
  ord_originstate, ord_deststate, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, mov_number, ord_revtype1_t, ord_revtype2_t  
, ord_revtype3_t, ord_revtype4_t, ord_totalcharge, origin, destination  
,stp_number,stp_reftype,stp_refnum,ord_reftype,ord_refnum,stp_event,cmp_name,cty_name,stp_state,stp_arrivaldate  
,stp_departuredate,linehaul,cht_description,charge,ord_totalmiles,ord_quantity,stp_sequence  
, paperwork, ord_status, drv_id, ord_refnumber  
  , orderheader.ord_bookedby, orderheader.ord_order_source,cmp_invoiceby ,ordsonmov )   
  SELECT Case @ps_date     
    when 'end' then datediff(day, lastdrop.stp_arrivaldate,getdate() )    
    else datediff(day, firstpup.stp_arrivaldate,getdate() )    
    end lagtime    
    ,firstpup.cmp_id     --orderheader.ord_shipper,     
    ,scmp.cmp_name                         -- shipper_name        
    ,lastdrop.cmp_id                  -- ord_consignee       
    , ccmp.cmp_name                        -- condignee_name     
    , mov.ord_billto  --, orderheader.ord_billto     
    , ord_company     
    , bcmp.cmp_name     
    , firstpup.stp_arrivaldate --orderheader.ord_startdate,     
    , lastdrop.stp_arrivaldate --orderheader.ord_completiondate,     
    , orderheader.ord_number     
    , 0                           --   orderheader.mfh_hdrnumber,   
    , @ps_status   -- ?? orderheader.ord_invoicestatus     
    , orderheader.ord_hdrnumber     
    , firstpup.cmp_id   
    , lastdrop.cmp_id --      orderheader.ord_destpoint,     
    , firstpup.stp_state    --   orderheader.ord_originstate,     
    , lastdrop.stp_state      --  orderheader.ord_deststate,     
    , orderheader.ord_revtype1   
    , orderheader.ord_revtype2     
    , orderheader.ord_revtype3    
    , orderheader.ord_revtype4     
    , mov.mov_number --  orderheader.mov_number     
    ,   'RevType1' revtype1     
     ,  'RevType2' revtype2     
    ,   'RevType3' revtype3     
    ,   'RevType4' revtype4     
    , mov.totalcharge  
    , scmp.cty_nmstct origin     
    , ccmp.cty_nmstct destination   
          ,firstpup.stp_number  
          ,firstpup.stp_reftype  
          ,firstpup.stp_refnum  
          ,ord_reftype  
          ,ord_refnum  
          ,firstpup.stp_event    
          ,firstpup.cmp_name  
          ,'  ' cty_name  
          ,firstpup.stp_state  
          ,firstpup.stp_arrivaldate  
          ,firstpup.stp_departuredate  
          ,'                              ' linehaul  
    ,'                              ' cht_description  
    ,0.00 charge  
    ,0 ord_totalmiles  
    ,0.00 ord_quantity  
    ,firstpup.stp_sequence    
    , 'Yes' paperwork  -- 'No' paperwork    
    , orderheader.ord_status    
    --, (select top 1 lgh_driver1 from legheader where legheader.mov_number = mov.mov_number order by lgh_startdate) drv_id  --PTS 53009 SGB  
    , orderheader.ord_driver1 drv_id    
    , (select top 1 ref_number    
          from referencenumber r1   with (nolock)   
         where r1.ref_table = 'orderheader'    
           and r1.ref_type = @reftype     
           and r1.ref_tablekey = mov.ord_hdrnumber) ord_refnumber    
  --PTS 37241 2007-05-09 JJF    
    , orderheader.ord_bookedby     
    ,  orderheader.ord_order_source    
  --END PTS 37241 2007-05-09 JJF  
    , bcmp.cmp_invoiceby  
    , mov.ordsonmov  
-- selection was done when @movs was built above   
  from @movs mov  
       join stops firstpup  with (nolock) on mov.firstpupstop = firstpup.stp_number  
       join stops lastdrop  with (nolock) on mov.lastdrpstop = lastdrop.stp_number  
       left outer join orderheader  with (nolock) on  mov.ord_hdrnumber = orderheader.ord_hdrnumber  
   
       LEFT OUTER JOIN company scmp  with (nolock) ON firstpup.cmp_id = scmp.cmp_id     
       LEFT OUTER JOIN company ccmp  with (nolock) ON lastdrop.cmp_id  = ccmp.cmp_id      
       LEFT OUTER JOIN company bcmp  with (nolock) ON orderheader.ord_billto = bcmp.cmp_id 
 where (@ps_othertype1 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype1 + ',',@ps_othertype1) > 0)      -- 62654 64009
 and  (@ps_othertype2 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype2 + ',',@ps_othertype2) > 0)      -- 62654 64009
 and  (@ps_othertype3 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype3 + ',',@ps_othertype3) > 0)      -- 62654 64009
 and  (@ps_othertype4 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype4 + ',',@ps_othertype4) > 0)      -- 62654 64009
 and  (isnull(orderheader.ord_invoice_effectivedate,'19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2)	-- 62719  
  
/******** add invoices baased on move and consignee     *********/  
  
if @vi_countinvoicebymovcon > 0  
  INSERT INTO @results (lagtime, ord_shipper, shipper_name, ord_consignee, consignee_name, ord_billto, ord_company, billto_name  
  , ord_startdate, ord_completiondate, ord_number, mfh_hdrnumber, ord_invoicestatus, ord_hdrnumber, ord_originpoint, ord_destpoint,   
  ord_originstate, ord_deststate, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, mov_number, ord_revtype1_t, ord_revtype2_t  
  , ord_revtype3_t, ord_revtype4_t, ord_totalcharge, origin, destination  
  ,stp_number,stp_reftype,stp_refnum,ord_reftype,ord_refnum,stp_event,cmp_name,cty_name,stp_state,stp_arrivaldate  
  ,stp_departuredate,linehaul,cht_description,charge,ord_totalmiles,ord_quantity,stp_sequence  
  , paperwork, ord_status, drv_id, ord_refnumber  
  , orderheader.ord_bookedby, orderheader.ord_order_source,cmp_invoiceby ,ordsonmov )   
  SELECT Case @ps_date     
    when 'end' then datediff(day, lastdrop.stp_arrivaldate,getdate() )    
    else datediff(day, firstpup.stp_arrivaldate,getdate() )    
    end lagtime    
    ,firstpup.cmp_id     --orderheader.ord_shipper equivalent     
    ,scmp.cmp_name       -- shipper_name        
    ,lastdrop.cmp_id     -- ord_consignee (should be the same on all orders      
    , ccmp.cmp_name      -- condignee_name     
    , mov.ord_billto      --, orderheader.ord_billto     
    , ord_company     
    , bcmp.cmp_name     
    , firstpup.stp_arrivaldate --orderheader.ord_startdate,     
    , lastdrop.stp_arrivaldate --orderheader.ord_completiondate,     
    , orderheader.ord_number     
    , 0                           --   orderheader.mfh_hdrnumber,   
    , orderheader.ord_invoicestatus     
    , orderheader.ord_hdrnumber     
    , firstpup.cmp_id   
    , lastdrop.cmp_id       -- orderheader.ord_destpoint,     
    , firstpup.stp_state    -- orderheader.ord_originstate,     
    , lastdrop.stp_state      --  orderheader.ord_deststate,     
    , orderheader.ord_revtype1   
    , orderheader.ord_revtype2     
    , orderheader.ord_revtype3    
    , orderheader.ord_revtype4     
    , mov.mov_number        --  orderheader.mov_number     
    ,   'RevType1' revtype1     
     ,  'RevType2' revtype2     
    ,   'RevType3' revtype3     
    ,   'RevType4' revtype4     
    , mov.totalcharge  
    , scmp.cty_nmstct origin     
    , ccmp.cty_nmstct destination   
          ,firstpup.stp_number  
          ,firstpup.stp_reftype  
          ,firstpup.stp_refnum  
          ,ord_reftype  
          ,ord_refnum  
          ,firstpup.stp_event    
          ,firstpup.cmp_name  
          ,'  ' cty_name  
          ,firstpup.stp_state  
          ,firstpup.stp_arrivaldate  
          ,firstpup.stp_departuredate  
          ,'                              ' linehaul  
    ,'                              ' cht_description  
    ,0.00 charge  
    ,0 ord_totalmiles  
    ,0.00 ord_quantity  
    ,firstpup.stp_sequence    
    , 'Yes' paperwork  -- 'No' paperwork    
    , orderheader.ord_status    
    --, (select top 1 lgh_driver1 from legheader where legheader.mov_number = mov.mov_number order by lgh_startdate) drv_id --PTS 53009  
    , orderheader.ord_driver1 drv_id  
    , (select top 1 ref_number    
          from referencenumber r1  with (nolock)    
         where r1.ref_table = 'orderheader'    
           and r1.ref_type = @reftype     
           and r1.ref_tablekey = mov.ord_hdrnumber) ord_refnumber    
  --PTS 37241 2007-05-09 JJF    
    , orderheader.ord_bookedby     
    ,  orderheader.ord_order_source    
  --END PTS 37241 2007-05-09 JJF  
    , bcmp.cmp_invoiceby  
    , mov.ordsonmov  
-- selection was done when @movcons was built above  
  from @movcons mov  
       join stops firstpup  with (nolock) on mov.firstpupstop = firstpup.stp_number  
       join stops lastdrop  with (nolock) on mov.lastdrpstop = lastdrop.stp_number  
       left outer join orderheader  with (nolock) on  mov.ord_hdrnumber = orderheader.ord_hdrnumber  
       LEFT OUTER JOIN company scmp  with (nolock) ON firstpup.cmp_id = scmp.cmp_id     
       LEFT OUTER JOIN company ccmp  with (nolock) ON lastdrop.cmp_id  = ccmp.cmp_id      
       LEFT OUTER JOIN company bcmp  with (nolock) ON orderheader.ord_billto = bcmp.cmp_id   
    where (@ps_othertype1 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype1 + ',',@ps_othertype1) > 0)      -- 64009
 and  (@ps_othertype2 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype2 + ',',@ps_othertype2) > 0)      -- 64009
 and  (@ps_othertype3 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype3 + ',',@ps_othertype3) > 0)      -- 64009
 and  (@ps_othertype4 = '%' or CHARINDEX( ',' + bcmp.cmp_othertype4 + ',',@ps_othertype4) > 0)      -- 64009  
 and  (isnull(orderheader.ord_invoice_effectivedate,'19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2)	-- 62719  
  
/* if selection by ref number is desired remove any records that don't match on the ref */  
/*     **** FOR INVOICES BY MOVE or Move/consingee only looking at one order ****  */  
  
Select @ps_refnumber = rtrim(isnull(@ps_refnumber,''))  
if @ps_refnumber > ''  
 BEGIN  
  update @results set ord_refnumber = ''  
  
   update @results  set ord_refnumber = max_ref_number 
   from @results r2 inner join
		(select rf.ord_hdrnumber, max(rf.ref_number) as max_ref_number 
		from referencenumber rf  with (nolock) inner join @results r on rf.ord_hdrnumber = r.ord_hdrnumber
		where  @ps_reftable in (rf.ref_table,'any') and ref_type = @ps_reftype and rf.ref_number like @ps_refnumber 
		group by rf.ord_hdrnumber) maxgen on maxgen.ord_hdrnumber = r2.ord_hdrnumber
      
  delete from @results where isnull(ord_refnumber,'') = '' --and cmp_invoiceby = 'ORD'  
  
 END  
  
--PTS 51570 JJF 20100510  
--declare @tmwuser varchar(255)  
--END PTS 51570 JJF 20100510  
  
  
  
--PTS 51570 JJF 20100510  
----PTS 41236 JJF 20080131  
--SELECT @rowsecurity = gi_string1  
--FROM generalinfo   
--WHERE gi_name = 'RowSecurity'  
  
----PTS 41877  
----SELECT @tmwuser = suser_sname()  
--exec @tmwuser = dbo.gettmwuser_fn  
  
--IF @rowsecurity = 'Y' AND EXISTS(SELECT *   
--    FROM UserTypeAssignment  
--    WHERE usr_userid = @tmwuser) BEGIN   
   
-- DELETE @results  
-- from @results tp inner join orderheader ord on tp.ord_hdrnumber = ord.ord_hdrnumber  
-- where NOT ((isnull(ord.ord_belongsto, 'UNK') = 'UNK'   
--   or EXISTS(SELECT *   
--      FROM UserTypeAssignment  
--      WHERE usr_userid = @tmwuser   
--        and (uta_type1 = ord.ord_belongsto  
--          or uta_type1 = 'UNK'))))  
--END  
----PTS 41236 JJF 20080131  
SELECT @rowsecurity = gi_string1   
FROM generalinfo  WITH (NOLOCK)  
WHERE gi_name = 'RowSecurity'  
  
IF @rowsecurity = 'Y' BEGIN   
 DELETE @results  
 from @results tp inner join orderheader ord  with (nolock) on tp.ord_hdrnumber = ord.ord_hdrnumber  
 WHERE NOT EXISTS ( SELECT *    
       FROM RowRestrictValidAssignments_orderheader_fn() rsva   
       WHERE ord.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0  
      )  
END  
--END PTS 51570 JJF 20100510  
  
/*    PTS43837 ALL PAPERWORK CHACKING is done by one proc (getreqpaperworkforinvoice) that proc  

*/  
if exists(select 1 from generalinfo  with (nolock) where gi_name = 'PaperworkCheckLevel' and gi_string1 = 'NONE')  
   /* do nothing , leave return set with paperwork marked Yes by default */  
   select @nextrec = @nextrec  
else   
  BEGIN   
	--PTS 62216 JJF/MC 20120323
    --select  @nextrec = min(rti_ident) from @results  
    
    Declare cur CURSOR LOCAL FAST_FORWARD FOR
    select rti_ident,ord_billto, cmp_invoiceby, ord_hdrnumber from @results order by rti_ident
    
    open cur
    fetch next from cur into @nextrec, @billto, @invoiceby, @ordhdrnumber
    while @@fetch_status = 0
    BEGIN
    
    --While @nextrec is not null  
    --  BEGIN  
    --    select @billto = ord_billto,@invoiceby = cmp_invoiceby,@ordhdrnumber = ord_hdrnumber   
    --    from @results   
    --    where rti_ident = @nextrec  
	--END PTS 62216 JJF/MC 20120323
        select @docsreq = 0,@docsrec = 0  
  
        select @chargescsv  = ''  
        select @chargescsv  = @chargescsv  + cht_itemcode + ','  
        from invoicedetail  with (nolock) where ord_hdrnumber = @ordhdrnumber  
        and ivh_hdrnumber = 0  
  
        exec PpwkDocsCount @ordhdrnumber ,@invoiceby, @billto,@chargescsv,'I', @docsreq OUTPUT,@docsrec OUTPUT  
        /* set yes by default, reset value only if paperwork is not received */  
    
    -- BEGIN PTS 52051 SGB 04/30/2010 Restore support for PwrkMarkedYes  
        If @ps_PwrkMarkedYesIni = 'ONE'   
        BEGIN  
         If @docsrec > 0  
          BEGIN  
           update @results set paperwork = 'Yes'  
           where rti_ident = @nextrec  
          END  
         ELSE  
          BEGIN  
           if @docsreq > @docsrec   
           update @results set paperwork = 'No'  
           where rti_ident = @nextrec  
          END  
        END  
        ELSE -- @ps_PwrkMarkedYesIni = 'ONE'   
        BEGIN  
         if @docsreq > @docsrec   
         update @results set paperwork = 'No'  
         where rti_ident = @nextrec  
       
        END   
   /*  
    if @docsreq > @docsrec   
    update @results set paperwork = 'No'  
    where rti_ident = @nextrec  
    */  
        -- END PTS 52051 SGB 04/30/2010 Restore support for PwrkMarkedYes  
  
	--PTS 62216 JJF/MC 20120323
        --select @nextrec = min(rti_ident) from @results where rti_ident > @nextrec 
       
   fetch next from cur into @nextrec, @billto, @invoiceby, @ordhdrnumber        
   END
   close cur
   deallocate cur 
   --END PTS 62216 JJF/MC 20120323
    
  END  
-- 43837  end of paperwork flag setting  
  
-- BEGIN 05/27/2010 SGB PTS 49742  
If @OrderInvoiceConsignee = 'Y'  
 BEGIN  
  -- Calculate new consignee  
  Update @results   
  set ord_consignee = isnull((Select s.cmp_id   
                from stops s  WITH (NOLOCK) 
                where stp_number = (  
                     select top 1 stp_number from stops s2 with (nolock)   
                     where s2.ord_hdrnumber = r.ord_hdrnumber  
                     and isnull(s2.stp_sequence,0) <> 0  
                     and isnull(s2.ord_hdrnumber,0) <> 0  
                     and s2.stp_event not in ('DUL','IEMT','EMT')  
                     AND s2.stp_type = 'DRP'  
                     order by stp_arrivaldate desc)  
                and s.ord_hdrnumber = r.ord_hdrnumber  
                and s.stp_type = 'DRP' ),r.ord_consignee)  
   from @results r  
   -- Now that the new consignee has been determined if   @ps_consignee is populated  
   -- delete the un needed rows  
   If @ps_consignee <> '%'  
   BEGIN  
    Delete @results   
    where ord_consignee not like @ps_consignee  
    END  
     
   Update @results   
   set consignee_name = c.cmp_name  
    from @results r  
    join company c  WITH (NOLOCK) on c.cmp_id = r.ord_consignee  
        
 END  
 -- END  05/27/2010 SGB PTS 49742  
   
 -- PTS 53511 SGB 09/29/2009  
 If @INV_NOTESFILTER = 'Y'  
 BEGIN   
  select  @nextrec = min(rti_ident) from @results  
    While @nextrec is not null  
      BEGIN   
    Select @Order = ord_hdrnumber from @results where rti_ident = @nextrec  
    EXEC ord_note_urgent_sp @Notes_Regarding,@order, '', @NOTE1 output   
    Update @results   
    Set Notes_flag = @NOTE1  
    Where  rti_ident = @nextrec  
    select @nextrec = min(rti_ident) from @results where rti_ident > @nextrec   
      END  
     
    
 END  
 
  
--BEGIN 62725 nloke
/* if % passed we do not filter bill to companies */
IF @ps_cmpinvtypes  = '%' -- no selection 
BEGIN
   Insert into @companies
   Select cmp_id from company  WITH (NOLOCK) where cmp_billto = 'Y'
END
ELSE
   BEGIN
      /* if both dedicated and master are selected or neither then the dedicated flag has no bearing */ 
      /* if both DED and MAS,BTH are passed the MAS,BTH will work for the invoice type restriction */
      If charindex('DED,MAS',@ps_cmpinvtypes,1) > 0  -- both dedicated and master bill selected
      OR (charindex('DED', @ps_cmpinvtypes,1) = 0  and charindex('MAS', @ps_cmpinvtypes,1) = 0  )
         BEGIN
            Insert into @companies
            Select cmp_id from company  WITH (NOLOCK) where cmp_billto = 'Y'
               And charindex(cmp_invoicetype, @ps_cmpinvtypes,1) > 0 
         END
      ELSE 
         BEGIN
            /* Dedicated is in the list but not master bill */
            /* since  MAS,BTH are not in the  list of statuses we can just match to the company profile
              Without worrying about picking up master bill companies */
            IF charindex('DED',@ps_cmpinvtypes,1) > 0
               INSERT into @companies
               SELECT cmp_id from company  WITH (NOLOCK) where cmp_billto = 'Y'
                  And (cmp_invoicetype in ('MAS','BTH') and isnull(cmp_dedicated_bill,'N') = 'Y')
                  Or charindex(cmp_invoicetype, @ps_cmpinvtypes,1) > 0
            ELSE
               /* I hope at this point MAS,BTH is in the list but not DED */
               Insert into @companies
               SELECT cmp_id FROM company  WITH (NOLOCK) where cmp_billto = 'Y'
                  And isnull(cmp_dedicated_bill,'N') = 'N'
                  AND charindex(cmp_invoicetype,@ps_cmpinvtypes,1) > 0
         END
               
   END
--end 62725 
 --select '##companies',tc.cmp_id,c.cmp_invoicetype,cmp_dedicated_bill
 -- from @companies tc join company c on tc.cmp_id = c.cmp_id
 -- select '##$ results',*  FROM @results
  
--return results  

delete  from paperworkcount

insert into paperworkcount

SELECT   
  'SIN PAPER',  
  count(paperwork),  
  sum(  ord_totalcharge),
  avg(datediff(dd,ord_completiondate,getdate()))
  FROM @results 
 where paperwork = 'No'  



insert into paperworkcount


SELECT   
  'CON PAPER',  
  count(paperwork),
  sum(  ord_totalcharge),
  avg(datediff(dd,ord_completiondate,getdate()))
  FROM @results 
 where paperwork = 'Yes'  
                        



delete from paperworkcountdetail



insert into paperworkcountdetail
SELECT 
  ord_billto as Cliente, 
  ord_hdrnumber as Orden,
  ord_completiondate as FechaFin,   
  datediff(dd,ord_completiondate,getdate()) as Lag,
  ord_totalcharge as Revenue,  
  paperwork as Evidencias
  FROM @results
 
GO
GRANT EXECUTE ON  [dbo].[d_orders_sinpaper_sp] TO [bitdr] WITH GRANT OPTION
GO
