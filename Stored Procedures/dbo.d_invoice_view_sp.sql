SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_invoice_view_sp] (@ps_status              varchar(6),
                                    @ps_billto              varchar(255),
                                    @ps_shipper             varchar(255),
                                    @ps_consignee           varchar(255),
                                    @ps_orderedby           varchar(255),
                                    @pdtm_printdate         datetime,
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
                                    @pdtm_xfr_date1         datetime,
                                    @pdtm_xfr_date2         datetime,
                                    @ps_PwrkMarkedYesIni    varchar(30),
                                    @ps_ppwOverride         char(1),
                                    @ps_paperworkfilter     varchar(3),
                                    @pl_ppwOverwriteAge     int,
									@ps_car_id		    varchar(255),
									@ps_othertype1			varchar(255),		-- PTS 62654
									@ps_othertype2			varchar(255),		-- PTS 62654
									@ps_othertype3			varchar(255),		-- PTS 62654
                                    @ps_othertype4         varchar(255),      -- PTS 62654)
                                    @ps_cmpinvtypes         varchar(100),     -- PTS 62725
									@ord_invoice_effectivedate1	datetime,		-- PTS 62719
									@ord_invoice_effectivedate2	datetime,		-- PTS 62719
									@ref_table					varchar(50),	-- PTS 73475
									@ref_type					varchar(6),		-- PTS 73475
									@ref_number					varchar(30))	-- PTS 73475

AS

/**
 * 
 * NAME:
 * dbo.d_invoice_view_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure retrieves the Invoices ready to Print and checks the paperwork for each order
 *
 *
 * RESULT SETS: 
 * ord_number                     Order Nmber
 * mov_number                     Move Number
 * ivh_invoicenumber              Invoice Number
 * ivh_invoicestatus              Invoice Status
 * ivh_billto                     Billto Company ID
 * cmp_name                       Company Name of the Billto
 * ivh_shipper                    Shipper Company ID
 * cmp_name                       Company Name of the Shipper
 * ivh_consignee                  Consignee Company ID
 * cmp_name                       Company Name of the Consignee
 * ivh_shipdate                   Ship Date of the Invoice
 * ivh_deliverydate               Delivery Date of the Invoice
 * ivh_revtype1                   Invoice Revtype 1
 * ivh_revtype2                   Invoice Revtype 2
 * ivh_revtype3                   Invoice Revtype 3
 * ivh_revtype4                   Invoice Revtype 4
 * ivh_totalweight                Total Weight of the Invoice
 * ivh_totalpieces                Total Pieces of the Invoice
 * ivh_totalmiles                 Total Miles of the Invoice
 * ivh_totalvolume                Total Volume of the Invoice
 * ivh_printdate                  Date Invoice was Printed
 * ivh_billdate                   Date Invoice was Billed
 * ivh_lastprintdate              Last MB print date of the Billto
 * ord_hdrnumber                  Order Header Number
 * ivh_remark                     Invoice Remark
 * ivh_edi_flag                   EDI flag for the invoice
 * ivh_totalcharge                Total Charges of the Invoice
 * hrevtype1                      User Label for Revtype1
 * hrevtype2                      User Label for Revtype2
 * hrevtype3                      User Label for Revtype3
 * hrevtype4                      User Label for Revtype4
 * ivh_hdrnumber                  Unvoice Header Number
 * ivh_order_by                   Order By of the Invoice
 * ivh_user_id1                   User that last touched the Invoice
 * ismasterbill                   Master Bill Flag
 * ivh_mbstatus                   Master Bill status of the Invoice
 * edi_210_flag                   EDI 210 flag for the Billto
 * edi_214_flag                   EDI 214 flag for the Billto
 * ivh_xferdate                   Date Invoice was Transfered
 * paperwork                      Paperwork Status
 * ivh_booked_revtype1            Booked Revtype1 of the invoice
 * create_exception               Flag to create a service exception for the driver
 * ivh_carrier			  Carrier Id
 * car_name			  Carrier Name
 *
 * PARAMETERS:
 * 001 - @ps_status               varchar(6)      Invoice Status Restriction Criteria
 * 002 - @ps_billto               varchar(8)      Billto Restriction Criteria
 * 003 - @ps_shipper              varchar(8)      Shipper Restriction Criteria
 * 004 - @ps_consignee            varchar(8)      Consignee Restriction Criteria
 * 005 - @ps_orderedby            varchar(8)      Ordered By Restriction Criteria
 * 006 - @pdtm_printdate          datetime        Date to compare the Billto's Last Printed MB Date
 * 007 - @pdtm_shipdate1          datetime        Beginning of the Ship Date Range Restriction Criteria
 * 008 - @pdtm_shipdate2          datetime        End of the Ship Date Range Restriction Criteria
 * 009 - @pdtm_deldate1           datetime        Beginning of the Delivery Date Range Restriction Criteria
 * 010 - @pdtm_deldate2           datetime        End of the Delivery Date Range Restriction Criteria
 * 011 - @ps_rev1                 varchar(6)      Revtype1 Restriction Criteria
 * 012 - @ps_rev2                 varchar(6)      Revtype2 Restriction Criteria
 * 013 - @ps_rev3                 varchar(6)      Revtype3 Restriction Criteria
 * 014 - @ps_rev4                 varchar(6)      Revtype4 Restriction Criteria
 * 015 - @ps_bookedrev1           varchar(6)      BookedRevtype1 Restriction Criteria
 * 016 - @pdtm_schearliest_date1  datetime        Beginning of the Scheduled Earliest Date Range Restriction Criteria
 * 017 - @pdtm_schearliest_date2  datetime        End of the Scheduled Earliest Range Restriction Criteria
 * 018 - @pdtm_xfr_date1          datetime        Beginning of the Transfer Date Range Restriction Criteria
 * 019 - @pdtm_xfr_date2          datetime        End of the Transfer Date Range Restriction Criteria
 * 020 - @ps_PwrkMarkedYesIni     varchar(30)     PaperworkMarkedYes TTS50.ini setting
 * 021 - @ps_ppwOverride          char(1)         InvoicePaperworkOverride ini setting
 * 022 - @ps_paperworkfilter      varchar(3)      Paperwork Restriction Criteria
 * 023 - @car_id                  varchar(8)      Carrier Id restriction criteria
 *
 
 * 
  * REVISION HISTORY:
 * 09/08/2006 ? PTS34229 - Jason Bauwin ? Original Release
 * 11/01/2006 - PTS34229 - Jason Bauwin ? added create_exception column to @results
 * 1/30/07  - PTS 36007 DPETE if PaperWorkMode = B and bill to has no required Doc types, returns NO
 * 4/06/07 - PTS 36869 EMK - Added required check when counting/retrieving required paperwork
 * 10/29/07 - PTS33161 BPISK add support for chaergetype related paperwork
 * 1-05-07  - PTS 40444 BPISKAC fixed chargetype related paperwork for papermode of 'LEG'
 * 08/12/2008 - PTS42754 PMILL - to avoid doubling charges for transferred invoices do not include masterbill row. The doubling occurred because both the invoice and master bill status are XFR.
 * 1/28/09 PTS45698 if the first billable stop on the order does not have a stp_sequence of 1 the stp_schdtearliest restriction does not work
 * 12/31/09 PTS50383 DPETE add same code for PPWK checkin as in invoic orders.
 * 01/08/10 PTS49659 MBR Added car_id to restrictions. 
 * 01/29/10 DPETE PTS50734 ppwk flag not being set - key is wrong
 * 04/30/2010 SGB PTS 52051 restore support for PaperworkMarkedYes 
 * 09/30/2010 SGB PTS 53511 Add logic to populate Notes Indicator
 * 7/7/11 DPETE PTS 56313 need to be able to make mulitple selections in various fields  
 * 06/26/2012 NQIAO	PTS 62654 - add 4 more retrival arguments: othertype1 ~ 4 
 * 09/25/2012 NLOKE (DPETE recoded 12/19/12)  PTS 62725 add filter for invoice types
 * 07/16/2013 MCURN PTS 62217 Remove loop selecting max val from temp table, turn into FF Readonly cursor
 *				Change temp table to table var
 * 12/12/2013 NQIAO PTS 73475 - add 3 more retrival arguments: ref_table, ref_type, ref_number
 * 08/15/2015 NQIAO PTS 91054 - exclude orders that haven't been settled if the GI setting 'SettleBeforeInvoice' is turned on.
 **/

set nocount on
set transaction isolation level read uncommitted

declare @vs_PaperWorkMode varchar(60), @vs_PaperWorkCheckLevel varchar(60), @vs_all_ppw_received varchar(3)
declare @vi_label int, @vi_counter1 int, @vi_counter2 int, @vi_lgh_number int, @vi_billto_ppw_count int, @vi_ppw_received int
declare	@vi_minord INT, @vi_minleg INT, @vi_ppw_rec INT
declare @vs_paperwork_status VARCHAR(3)
declare @varchar100 varchar(100), @int int
declare @rti_ident int, @ivh_hdrnumber varchar(12)

--PTS 40155 JJF 20071128
declare @rowsecurity char(1)
--PTS 51570 JJF 20100608
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100608
--END PTS 40155 JJF 20071128
declare @nextrec int,@billto varchar(8),@invoiceby varchar(6),@ordhdrnumber int,@docsreq int,@docsrec int ,@chargescsv varchar(500)--50383

-- PTS 53511 SGB 09/29/2010
declare @INV_NOTESFILTER char(1)
declare @Notes_Regarding varchar(6)
declare @NOTE1 char(1)
declare @Order int
declare @Invoice int

-- PTS 62725 nloke
declare @companies table (cmp_id varchar(8))
--end 62725

declare	@SettleBeforeInvoice char(1)			-- 91054

	--PTS 52051 SGB If TTS50 setting passes 'ONE' use it otherwise check the GI table
	If @ps_PwrkMarkedYesIni	 <> 'ONE'
	BEGIN
		Select @ps_PwrkMarkedYesIni =  isnull(gi_string1,'ALL') from generalinfo where gi_name = 'ps_PwrkMarkedYesIni'
		
	END
-- PTS 53511 SGB 09/29/2010
Select @INV_NOTESFILTER = isnull(gi_string1,'N'),@Notes_Regarding =  isnull(gi_string2,'B') from generalinfo where gi_name = 'INV_NotesFilter' 

--Create table @results 
declare @results table
	   (ord_number				varchar(12)		NULL,
		mov_number				int				   NULL,
		ivh_invoicenumber		varchar(12)		NULL,
		ivh_invoicestatus		varchar(6)		NULL,
		ivh_billto				varchar(8)		NULL,
		billto_name				varchar(100)	NULL,
		ivh_shipper				varchar(8)		NULL,
		shipper_name			varchar(100)	NULL,
		ivh_consignee			varchar(8)		NULL,
		consignee_name			varchar(100)	NULL,
		ivh_shipdate			datetime		NULL,
		ivh_deliverydate		datetime		NULL,
		ivh_revtype1			varchar(6)		NULL,
		ivh_revtype2			varchar(6)		NULL,
		ivh_revtype3			varchar(6)		NULL,
		ivh_revtype4			varchar(6)		NULL,
		ivh_totalweight			float			NULL,
		ivh_totalpieces			float			NULL,
		ivh_totalmiles			float			NULL,
		ivh_totalvolume			float			NULL,
		ivh_printdate			datetime		NULL,
		ivh_billdate			datetime		NULL,
		ivh_lastprintdate		datetime		NULL,
		ord_hdrnumber			int				NULL,
		ivh_remark				varchar(254)	NULL,
		ivh_edi_flag			varchar(30)		NULL,
		ivh_totalcharge			money			NULL,
		revtype1_t				varchar(20)		NULL,
		revtype2_t				varchar(20)		NULL,
		revtype3_t				varchar(20)		NULL,
		revtype4_t				varchar(20)		NULL,
		ivh_hdrnumber			int				NULL,
		ivh_order_by			varchar(8)		NULL,
		ivh_user_id1			varchar(20)		NULL,
		ismasterbill			char(1)			NULL,
		ivh_mbstatus			varchar(6)		NULL,
		billto_edi_210_flag		int				NULL,
		billto_edi_214_flag		int				NULL,
		ivh_xferdate			datetime		NULL,
		paperwork				varchar(3)		NULL,
		ivh_booked_revtype1		varchar(12)		NULL,
		ivh_paperwork_override	char(1)			NULL,
		create_exception		char(1)			NULL,
		cmp_invoiceby			varchar(6)		NULL,			-- 50383
		ivh_carrier				varchar(8)		NULL,
		car_name				varchar(64)		NULL,
		rti_ident				integer identity primary key,	-- PTS 53511 SGB
		notes_flag				char(1),						-- PTS 53511 SGB 
		ivh_refnumber			varchar(30)		NULL)			-- PTS 73475 NQIAO

if @ps_billto is null or rtrim(@ps_billto) = '' select @ps_billto = '%' 
if @ps_shipper is null or rtrim(@ps_shipper) = '' select @ps_shipper = '%' 
if @ps_consignee is null or rtrim(@ps_consignee) = '' select @ps_consignee = '%' 
if @ps_orderedby is null or rtrim(@ps_orderedby) = '' select @ps_orderedby = '%'
if @ps_rev1 is null or rtrim(@ps_rev1) = '' select @ps_rev1 = '%'  
if @ps_rev2 is null or rtrim(@ps_rev2) = '' select @ps_rev2 = '%' 
if @ps_rev3 is null or rtrim(@ps_rev3) = '' select @ps_rev3 = '%' 
if @ps_rev4 is null or rtrim(@ps_rev4) = '' select @ps_rev4 = '%' 
if @ps_bookedrev1 is null or rtrim(@ps_bookedrev1) = '' select @ps_bookedrev1 = '%'
if @ps_car_id is null or rtrim(@ps_car_id) = '' select @ps_car_id = '%' 
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
if @ps_car_id <> '%'  SELECT @ps_car_id = ',' + @ps_car_id + ','
if @ps_bookedrev1 <> '%'  SELECT @ps_bookedrev1 = ',' + @ps_bookedrev1 + ','
if @ps_othertype1 <> '%'  SELECT @ps_othertype1 = ',' + @ps_othertype1 + ','		-- PTS 62654
if @ps_othertype2 <> '%'  SELECT @ps_othertype2 = ',' + @ps_othertype2 + ','		-- PTS 62654
if @ps_othertype3 <> '%'  SELECT @ps_othertype3 = ',' + @ps_othertype3 + ','		-- PTS 62654
if @ps_othertype4 <> '%'  SELECT @ps_othertype4 = ',' + @ps_othertype4 + ','		-- PTS 62654

INSERT INTO @results (ord_number, mov_number, ivh_invoicenumber, ivh_invoicestatus,
 ivh_billto, billto_name, ivh_shipper, shipper_name, ivh_consignee, consignee_name,
  ivh_shipdate, ivh_deliverydate, ivh_revtype1, ivh_revtype2, ivh_revtype3, 
  ivh_revtype4, ivh_totalweight, ivh_totalpieces, ivh_totalmiles, ivh_totalvolume, 
  ivh_printdate, ivh_billdate, ivh_lastprintdate, ord_hdrnumber, ivh_remark, 
  ivh_edi_flag, ivh_totalcharge, revtype1_t, revtype2_t, revtype3_t, revtype4_t,
   ivh_hdrnumber, ivh_order_by, ivh_user_id1, ismasterbill, ivh_mbstatus, 
   billto_edi_210_flag, billto_edi_214_flag, ivh_xferdate, paperwork, 
   ivh_booked_revtype1, ivh_paperwork_override,cmp_invoiceby, ivh_carrier, car_name)
SELECT invoiceheader.ord_number,
invoiceheader.mov_number, 
invoiceheader.ivh_invoicenumber, 
invoiceheader.ivh_invoicestatus, 
invoiceheader.ivh_billto, 
@varchar100, --bc.cmp_name, to be filled in on final retrieve
invoiceheader.ivh_shipper, 
@varchar100, --sc.cmp_name, to be filled in on final retrieve 
invoiceheader.ivh_consignee, 
@varchar100, --cc.cmp_name,  to be filled in on final retrieve
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
invoiceheader.ord_hdrnumber, 
ivh_remark, 
invoiceheader.ivh_edi_flag, 
invoiceheader.ivh_totalcharge, 
'RevType1' hrevtype1, 
'RevType2' hrevtype2, 
'RevType3' hrevtype3, 
'RevType4' hrevtype4, 
invoiceheader.ivh_hdrnumber, 	 
invoiceheader.ivh_order_by, 	
invoiceheader.ivh_user_id1, 
'N' ismasterbill, 
invoiceheader.ivh_mbstatus, 
@int, --bc.cmp_edi210 edi_210_flag,  to be filled in on final retrieve
@int, --bc.cmp_edi214 edi_214_flag, to be filled in on final retrieve
invoiceheader.ivh_xferdate,
'Yes' paperwork,  -- 50383 'No' paperwork,
invoiceheader.ivh_booked_revtype1,
invoiceheader.ivh_paperwork_override,
'ORD',  --bc.cmp_invoiceby,  to be filled in on final retrieve
invoiceheader.ivh_carrier,  --PTS49659
@varchar100 --car.car_name            --PTS49659
FROM invoiceheader
 WHERE 	 
( invoiceheader.ivh_invoicestatus like @ps_Status ) AND 
( isnull(invoiceheader.ivh_shipdate,'19500101 00:00') between @pdtm_ShipDate1 and @pdtm_ShipDate2 ) AND 
( isnull(invoiceheader.ivh_deliverydate,'20491231 23:59:59') between @pdtm_DelDate1 and @pdtm_DelDate2 ) AND 
((@ps_Status = 'XFR' and ((isnull(invoiceheader.ivh_xferdate,'19500101 00:00') between @pdtm_xfr_date1 and @pdtm_xfr_date2) or invoiceheader.ivh_xferdate IS null)) or
	 		@ps_Status not in ('XFR')) AND
--( IsNull(invoiceheader.ivh_booked_revtype1, '') like @ps_bookedrev1) AND
(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber) -- and stp_sequence = 1 )
		between @pdtm_schearliest_Date1 and @pdtm_schearliest_Date2 ) or
invoiceheader.ord_hdrnumber = 0)
and  (@ps_billto = '%' or    CHARINDEX( ',' + ivh_billto + ',',@ps_billto ) > 0)
and  (@ps_shipper = '%' or   CHARINDEX( ',' + ivh_shipper + ',',@ps_shipper ) > 0)
and  (@ps_orderedby = '%' or CHARINDEX( ',' + ivh_order_by + ',',@ps_orderedby ) > 0)
and (@ps_consignee = '%' or  CHARINDEX( ',' + ivh_consignee + ',',@ps_consignee ) > 0)
and (@ps_rev1 = '%' or       CHARINDEX( ',' + ivh_revtype1 + ',',@ps_rev1) > 0)
and (@ps_rev2 = '%' or       CHARINDEX( ',' + ivh_revtype2 + ',',@ps_rev2) > 0)
and (@ps_rev3 = '%' or       CHARINDEX( ',' + ivh_revtype3 + ',' ,@ps_rev3) > 0)
and (@ps_rev4 = '%' or       CHARINDEX( ',' + ivh_revtype4 + ',',@ps_rev4) > 0)
and (@ps_car_id = '%' or     CHARINDEX( ',' + ivh_carrier + ',',@ps_car_id) > 0)
AND (@ps_bookedrev1 = '%' OR CHARINDEX(','+ ivh_booked_revtype1 + ',',@ps_bookedrev1) > 0)
and	(ivh_billto in (	-- 62654		
	select	cmp_id
	from	company 
	where	(@ps_othertype1 = '%' or CHARINDEX( ',' + cmp_othertype1 + ',',@ps_othertype1) > 0)
	and		(@ps_othertype2 = '%' or CHARINDEX( ',' + cmp_othertype2 + ',',@ps_othertype2) > 0)
	and		(@ps_othertype3 = '%' or CHARINDEX( ',' + cmp_othertype3 + ',',@ps_othertype3) > 0)
	and		(@ps_othertype4 = '%' or CHARINDEX( ',' + cmp_othertype4 + ',',@ps_othertype4) > 0)))
and (ord_hdrnumber in (select ord_hdrnumber from orderheader where isnull(ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2) or 
     ISNULL(ord_hdrnumber, 0) = 0) 

UNION 

SELECT ''ord_number,
0 mov_number, 
'Master' ivh_invoicenumber, 
min(invoiceheader.ivh_mbstatus) 
ivh_invoicestatus,	
min(invoiceheader.ivh_billto) ivh_billto, 
'', 
'UNKNOWN' ivh_shipper, 
'', 
'UNKNOWN' ivh_consignee, 
'', 
min(invoiceheader.ivh_shipdate) ivh_shipdate,	
max(invoiceheader.ivh_deliverydate) ivh_deliverydate,	 
'UNK' ivh_revtype1, 
'UNK' ivh_revtype2, 
'UNK' ivh_revtype3, 
'UNK' ivh_revtype4, 
sum(invoiceheader.ivh_totalweight) ivh_totalweight, 
sum(invoiceheader.ivh_totalpieces) ivh_totalpieces, 	
sum(invoiceheader.ivh_totalmiles) ivh_totalmiles, 
sum(invoiceheader.ivh_totalvolume) ivh_totalvolume, 
max(invoiceheader.ivh_printdate) ivh_printdate,
 min(invoiceheader.ivh_billdate) ivh_billdate, 
max(invoiceheader.ivh_lastprintdate) ivh_lastprintdate, 
0 ord_hdrnumber, 
''ivh_remark , 
min(invoiceheader.ivh_edi_flag) ivh_edi_flag, 
sum(invoiceheader.ivh_totalcharge) ivh_totalcharge, 
'RevType1', 
'RevType2', 
'RevType3', 
'RevType4', 
0 ivh_hdrnumber, 
'UNKNOWN' ivh_order_by, 
'N/A' ivh_user_id1, 
'Y' ismasterbill, 
'' ivh_mbstatus, 
0 edi_210_flag, 
0 edi_214_flag,
min(invoiceheader.ivh_xferdate),
'Yes' paperwork,  -- 50383
'UNK' ivh_booked_revtype1,
min(invoiceheader.ivh_paperwork_override),
min(ISNULL(cmp_invoiceby,'ORD')),
'UNKNOWN' ivh_carrier,
''
FROM invoiceheader , company 
WHERE ( company.cmp_id = invoiceheader.ivh_billto ) AND 
(@ps_status <> 'HLD') AND 
--PTS42754 PMILL Do not include master bills for XFR.  
(@ps_status <> 'XFR') AND
( (@ps_Status <> 'RTP') or (dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @pdtm_PrintDate) ) AND 
( @ps_Status = invoiceheader.ivh_mbstatus ) AND
( isnull(invoiceheader.ivh_shipdate,'19500101 00:00') between @pdtm_ShipDate1 and @pdtm_ShipDate2 ) AND 
( isnull(invoiceheader.ivh_deliverydate,'20491231 23:59:59') between @pdtm_DelDate1 and @pdtm_DelDate2 ) 
and  (@ps_billto = '%' or    CHARINDEX( ',' + ivh_billto + ',',@ps_billto ) > 0)
and  (@ps_shipper = '%' or   CHARINDEX( ',' + ivh_shipper + ',',@ps_shipper ) > 0)
and  (@ps_orderedby = '%' or CHARINDEX( ',' + ivh_order_by + ',',@ps_orderedby ) > 0)
and (@ps_consignee = '%' or  CHARINDEX( ',' + ivh_consignee + ',',@ps_consignee ) > 0)
and (@ps_rev1 = '%' or       CHARINDEX( ',' + ivh_revtype1 + ',',@ps_rev1) > 0)
and (@ps_rev2 = '%' or       CHARINDEX( ',' + ivh_revtype2 + ',',@ps_rev2) > 0)
and (@ps_rev3 = '%' or       CHARINDEX( ',' + ivh_revtype3 + ',' ,@ps_rev3) > 0)
and (@ps_rev4 = '%' or       CHARINDEX( ',' + ivh_revtype4 + ',',@ps_rev4) > 0)
and (@ps_car_id = '%' or     CHARINDEX( ',' + ivh_carrier + ',',@ps_car_id) > 0)
and (@ps_othertype1 = '%' or CHARINDEX( ',' + cmp_othertype1 + ',',@ps_othertype1) > 0)		-- 62654
and (@ps_othertype2 = '%' or CHARINDEX( ',' + cmp_othertype2 + ',',@ps_othertype2) > 0)		-- 62654
and (@ps_othertype3 = '%' or CHARINDEX( ',' + cmp_othertype3 + ',',@ps_othertype3) > 0)		-- 62654
and (@ps_othertype4 = '%' or CHARINDEX( ',' + cmp_othertype4 + ',',@ps_othertype4) > 0)		-- 62654
and (ord_hdrnumber in (select ord_hdrnumber from orderheader where isnull(ord_invoice_effectivedate, '19500101 00:00') between @ord_invoice_effectivedate1 and @ord_invoice_effectivedate2) or
     ISNULL(ord_hdrnumber, 0) = 0) -- 62719
GROUP BY invoiceheader.ivh_billto 


SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN 
	DELETE @results
	from @results tp inner join invoiceheader ivh on tp.ivh_hdrnumber = ivh.ivh_hdrnumber
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_invoiceheader_fn() rsva 
							WHERE	ivh.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)



END
--END PTS 51570 JJF 20100510


--now that we have the results we need to check paperwork for each order
--get needed GI settings
select @vs_PaperWorkMode = isnull(UPPER(gi_string1),'A')
  from generalinfo
 where gi_name = 'PaperWorkMode'

select @vs_PaperWorkCheckLevel = isnull(UPPER(gi_string1), 'ORDER')
  from generalinfo
 where gi_name = 'PaperWorkCheckLevel'

if isnull(@vs_PaperWorkMode,'') = ''
begin
   set @vs_PaperWorkMode = 'A'
end

if isnull(@vs_PaperWorkCheckLevel,'') = ''
begin
   set @vs_PaperWorkCheckLevel = 'ORDER'
end

--get the count of labelfile entries
select @vi_label = count(*) 
from labelfile 
where labeldefinition = 'PaperWork' and 
		(retired is null or retired = 'N')
/* ## 50383 put paperwork check in a proc
lots of code removed here
## */
--return results
if exists(select 1 from generalinfo where gi_name = 'PaperworkCheckLevel' and gi_string1 = 'NONE')
   /* do nothing , leave return set with paperwork marked Yes by default */
   select @nextrec = @nextrec
else 
  BEGIN 
	Declare PaperWork_Cursor Cursor FAST_FORWARD For
	select r.rti_ident, r.ivh_hdrnumber, r.ivh_billto, r.cmp_invoiceby, r.ord_hdrnumber
	from @results r 
	order by rti_ident

	open PaperWork_Cursor
	fetch next from Paperwork_Cursor into 
	@rti_ident, @ivh_hdrnumber, @billto, @invoiceby, @ordhdrnumber

	while @@fetch_status = 0
		begin
			select @docsreq = 0,@docsrec = 0
			select @chargescsv  = ''
			select @chargescsv  = @chargescsv  + cht_itemcode + ','
			from invoicedetail where ivh_hdrnumber = @ivh_hdrnumber

			exec PpwkDocsCount @ordhdrnumber ,@invoiceby, @billto,@chargescsv,'I', @docsreq OUTPUT,@docsrec OUTPUT

			If @ps_PwrkMarkedYesIni = 'ONE' 
				BEGIN
					If @docsrec > 0
						BEGIN
							update @results set paperwork = 'Yes'
							where rti_ident = @rti_ident
						END
					ELSE
						BEGIN
							if @docsreq > @docsrec 
							update @results set paperwork = 'No'
							where rti_ident = @rti_ident
						END
				END
			ELSE 
					BEGIN
						if @docsreq > @docsrec 
						update @results set paperwork = 'No'
						where rti_ident = @rti_ident
						
					END	
		  
			if @docsreq > @docsrec 
			update @results set paperwork = 'No'
			where rti_ident = @rti_ident

			If @INV_NOTESFILTER = 'Y'
				BEGIN
					EXEC ord_note_urgent_sp @Notes_Regarding,@ordhdrnumber, @ivh_hdrnumber, @NOTE1 output	
					Update @results	Set Notes_flag = @NOTE1
				END

		fetch next from Paperwork_Cursor into 
		@rti_ident, @ivh_hdrnumber, @billto, @invoiceby, @ordhdrnumber
	
		end

	close Paperwork_Cursor
	deallocate Paperwork_Cursor
  END

   
--BEGIN 62725 nloke
/* if % passed we do not filter bill to companies */
IF @ps_cmpinvtypes  = '%' -- no selection 
	BEGIN
	   Insert into @companies
	   Select cmp_id from company where cmp_billto = 'Y'
	END
ELSE
   BEGIN
      /* if both dedicated and master are selected or neither then the dedicated flag has no bearing */ 
      /* if both DED and MAS,BTH are passed the MAS,BTH will work for the invoice type restriction */
      If charindex('DED,MAS',@ps_cmpinvtypes,1) > 0  -- both dedicated and master bill selected
      OR (charindex('DED', @ps_cmpinvtypes,1) = 0  and charindex('MAS', @ps_cmpinvtypes,1) = 0  )
         BEGIN
            Insert into @companies
            Select cmp_id from company where cmp_billto = 'Y'
               And charindex(cmp_invoicetype, @ps_cmpinvtypes,1) > 0 
         END
      ELSE 
         BEGIN
            /* Dedicated is in the list but not master bill */
            /* since  MAS,BTH are not in the  list of statuses we can just match to the company profile
              Without worrying about picking up master bill companies */
            IF charindex('DED',@ps_cmpinvtypes,1) > 0
               INSERT into @companies
               SELECT cmp_id from company where cmp_billto = 'Y'
                  And (cmp_invoicetype in ('MAS','BTH') and cmp_dedicated_bill = 'Y')
                  Or charindex(cmp_invoicetype, @ps_cmpinvtypes,1) > 0
            ELSE
               /* I hope at this point MAS,BTH is in the list but not DED */
               Insert into @companies
               SELECT cmp_id FROM company where cmp_billto = 'Y'
                  And isnull(cmp_dedicated_bill,'N') = 'N'
                  AND charindex(cmp_invoicetype,@ps_cmpinvtypes,1) > 0
         END
               
   END

-- NQIAO 08/15/15 PTS 91054 <start>
select	@SettleBeforeInvoice = gi_string1
from	generalinfo
where	gi_name = 'SettleBeforeInvoice'

if @SettleBeforeInvoice = 'Y'		-- exclude orders that haven't been settled from this list to process
begin
	delete	from @results
	where	ord_hdrnumber in (	select distinct l.ord_hdrnumber
								from assetassignment a, legheader l
								where a.lgh_number = l.lgh_number
								and a.pyd_status = 'NPD' )
end
-- NQIAO 08/15/15 PTS 91054 <start>


-- NQIAO PTS 73475 - if selection by ref number is desired remove any records that don't match on the ref number <start>
SELECT @ref_number = ltrim(rtrim(isnull(@ref_number,'')))    
IF @ref_number > ''    
BEGIN
	UPDATE	@results SET ivh_refnumber = ''   

	UPDATE	@results
	SET		ivh_refnumber = max_ref_number
	FROM	@results r2 inner join
			(SELECT ref.ord_hdrnumber, MAX(ref.ref_number) as max_ref_number
			 FROM	referencenumber ref with (nolock) inner join @results r1 on ref.ord_hdrnumber = r1.ord_hdrnumber
			 WHERE	@ref_table in (ref.ref_table, 'any')
			 AND	ref_type = @ref_type
			 AND	ref.ref_number like @ref_number
			 GROUP BY ref.ord_hdrnumber) maxgen ON maxgen.ord_hdrnumber = r2.ord_hdrnumber
	
	DELETE FROM @results WHERE ISNULL(ivh_refnumber, '') = ''
END
-- NQIAO PTS 73475 <end>

SELECT ord_number,
       mov_number,
       ivh_invoicenumber,
       ivh_invoicestatus,
       ivh_billto,
       bc.cmp_name as 'cmp_name',
       ivh_shipper,
       sc.cmp_name as 'cmp_name',
       ivh_consignee,
       cc.cmp_name as 'cmp_name',
       ivh_shipdate,
       ivh_deliverydate,
       ivh_revtype1,
       ivh_revtype2,
       ivh_revtype3,
       ivh_revtype4,
       ivh_totalweight,
       ivh_totalpieces,
       ivh_totalmiles,
       ivh_totalvolume,
       ivh_printdate,
       ivh_billdate,
       ivh_lastprintdate,
       ord_hdrnumber,
       ivh_remark,
       ivh_edi_flag,
       ivh_totalcharge,
       revtype1_t as 'hrevtype1',
       revtype2_t as 'hrevtype2',
       revtype3_t as 'hrevtype3',
       revtype4_t as 'hrevtype4',
       ivh_hdrnumber,
       ivh_order_by,
       ivh_user_id1,
       ismasterbill,
       ivh_mbstatus,  
       bc.cmp_edi210 as 'edi_210_flag',
       bc.cmp_edi214 as 'edi_214_flag',
       ivh_xferdate,
       paperwork,
       ivh_booked_revtype1,
       ivh_paperwork_override,
       isnull(create_exception,'N') as 'create_exception',
       ivh_carrier,
       carrier.car_name
       ,notes_flag	-- PTS 53511 SGB
  FROM @results res
  left outer join company bc on res.ivh_billto = bc.cmp_id
  left outer join company sc on res.ivh_shipper = sc.cmp_id
  left outer join company cc on res.ivh_consignee = cc.cmp_id
  left outer join carrier on ivh_carrier = car_id 
  join @companies c on  res.ivh_billto = c.cmp_id   --62725 join to force invoice type restriciton
 where (paperwork = @ps_paperworkfilter or @ps_paperworkfilter = 'N/A')
 order by res.ivh_billto, res.mov_number                        


GO
GRANT EXECUTE ON  [dbo].[d_invoice_view_sp] TO [public]
GO
