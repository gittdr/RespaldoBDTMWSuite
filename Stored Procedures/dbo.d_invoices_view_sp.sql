SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_invoices_view_sp    Script Date: 6/1/99 11:54:15 AM ******/
/*
  Returns information for invoices and masterbills which meet the
  selection criterea.  A candidate list for invoice printing
*/
  



CREATE PROC [dbo].[d_invoices_view_sp] (@status VARCHAR(6), @billto VARCHAR(8),

		@shipper varchar(8), @consignee varchar(8), @orderedby varchar(8),
		@shipdate1 datetime, @shipdate2 datetime, @deldate1 datetime, 
		@deldate2 datetime, @rev1 varchar(6),
		@rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6), 
		@printdate datetime, @doinvoices char(1), 
		@domasterbills char(1) , @mbnumber int )
AS

DECLARE @int0  int, @varchar6 varchar(6), @varchar8 varchar (8), @money money, 
	@varchar254 varchar(254), @varchar30 varchar(30), @char3 char(3), @charn char,
	@chary char, @varchar20 varchar(20), @char1 char(1), @dummystatus varchar(6)
SELECT @int0 = 0, @money = 0.00, @varchar8 = '', @varchar30 = '', @varchar254 = '',
     @varchar6 = '', @char3 = '', @charn = 'N', @chary = 'Y',@varchar20 = '',
	@dummystatus = '<'

-- for reprinting invoices the PRN and PRO status are the same
-- for reprinting masterbills the status is not used
IF @status = 'PRN'
	SELECT @dummystatus = 'PRO'
IF @status = 'PRO'
	SELECT @dummystatus = 'PRN'
 
CREATE TABLE #invview (	
	mov_number int,
	ivh_invoicenumber varchar(12),
	ivh_invoicestatus varchar(6),
	ivh_billto varchar(8),
	billto_name varchar(30) NULL,
	ivh_shipper varchar(8),
	shipper_name varchar(30) NULL,
	ivh_consignee varchar(8),
	consignee_name varchar(30) NULL,
	ivh_shipdate datetime NULL,
 	ivh_deliverydate datetime NULL,
 	ivh_revtype1 varchar(6),
 	ivh_revtype2 varchar(6),
 	ivh_revtype3 varchar(6),
 	ivh_revtype4 varchar(6),
 	ivh_totalweight int NULL,
 	ivh_totalpieces int NULL,
 	ivh_totalmiles int NULL,
 	ivh_totalvolume int NULL,
 	ivh_printdate datetime NULL,

 	ivh_billdate datetime NULL,
 	ivh_lastprintdate datetime NULL,
 	ord_hdrnumber int,
 	ivh_remark varchar(254) NULL,
 	ivh_edi_flag char(30) NULL,
 	ivh_totalcharge money,
	RevType1 char(8),
 	RevType2 char(8),
 	Revtype3 char(8),
 	RevType4 char(8),
 	ivh_hdrnumber int,
 	ivh_order_by varchar(8),
 	ivh_user_id1 char(20) NULL,
 	ord_number char(12),
	ivh_terms char(3),
	ivh_trailer varchar(8),
	ivh_tractor varchar(8),
	commodities int,
	validcommodities int,
	accessorials int,
	validaccessorials int,
	trltype3 varchar(6) NULL,
	cmp_subcompany varchar(6) NULL,
	totallinehaul money,
	negativecharges int,
	edi_210_flag int,
	ismasterbill char(1),
	trltype3name char(8), 
	cmp_mastercompany varchar(8) NULL,
	refnumber varchar(20) NULL,
	cmp_invoiceto char(3) NULL,
	cmp_invprintto char(1) NULL,
	cmp_invformat int NULL,
	cmp_transfertype varchar(6) NULL,
	ivh_mbstatus varchar(6) NULL
	)

IF @doinvoices = 'Y'
BEGIN

	INSERT INTO #invview
	SELECT invoiceheader.mov_number,
 	invoiceheader.ivh_invoicenumber,
 	invoiceheader.ivh_invoicestatus,
 	invoiceheader.ivh_billto,
 	bcmp.cmp_name billto_name,
 	invoiceheader.ivh_shipper,
 	scmp.cmp_name shipper_name,
 	invoiceheader.ivh_consignee,
 	ccmp.cmp_name consignee_name,
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
	bcmp.cmp_subcompany ,

	@money 'totallinehaul',
	@int0 'negativecharges',
	bcmp.cmp_edi210 'edi_210_flag',
	@charn 'ismasterbill',
	'Trltype3' trltype3name,
	bcmp.cmp_mastercompany,
	@varchar20 'refnumber',
	bcmp.cmp_invoiceto,
	bcmp.cmp_invprintto,
	bcmp.cmp_invformat,
	bcmp.cmp_transfertype,
	invoiceheader.ivh_mbstatus
	FROM invoiceheader, company bcmp, company scmp, company ccmp 
	WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus) ) 
	AND 	( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) ) 
	AND 	( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) ) 
	AND 	( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) ) 
	AND 	( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) ) 

	AND 	( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 ) 
	AND 	( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 ) 
	AND 	( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) ) 
	AND 	( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) ) 
	AND 	( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) ) 
	AND 	( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) ) 
	AND     ( bcmp.cmp_id = invoiceheader.ivh_billto)
	AND 	(bcmp.cmp_invoicetype in ('BTH','INV') )
	AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
	AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)



	-- Note trltype3 column is used for Florida Rock in d_invoices_view2


	-- Provide a total linehaul charge for each invoice
	UPDATE	#invview
	SET	totallinehaul = (SELECT	SUM(d.ivd_charge)
				FROM 	invoicedetail d, chargetype c
				WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary = 'Y'
				)

				
	-- Count the  commodities on the invoice
	UPDATE 	#invview 
	SET	commodities =   (SELECT COUNT(d.cmd_code)

				FROM	invoicedetail d
				WHERE	#invview.ivh_hdrnumber = D.ivh_hdrnumber
				AND	d.ivd_type = 'DRP' )

			
	-- Count the commodities which match to the edicommodity table
	UPDATE 	#invview
	SET	validcommodities =  (SELECT COUNT(d.cmd_code)

				FROM	invoicedetail d,  edicommodity e
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.ivd_type = 'DRP'
				AND	e.cmp_id = #invview.ivh_billto
				AND	e.cmd_code = d.cmd_code)


	-- Count the accessorial charge types on the invoice 
	UPDATE 	#invview
	SET	accessorials = (SELECT COUNT(d.cht_itemcode)
				FROM	invoicedetail d, chargetype c
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_basis = 'ACC' )
			
	-- Count the accessorial charge types on the invoice which  
	-- match the edicommodity table
	UPDATE #invview
	SET	validaccessorials = (SELECT COUNT(d.cht_itemcode)
				FROM	invoicedetail d, chargetype c, ediaccessorial e
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_basis = 'ACC'
				AND	e.cmp_id = #invview.ivh_billto

				AND	e.cht_itemcode = d.cht_itemcode )
	

	-- Count the number of charge lines which have either a negative qty or rate

	Update	#invview
	SET	negativecharges = (SELECT count(*)
			FROM   invoicedetail d
			WHERE  d.ivh_hdrnumber = #invview.ivh_hdrnumber
			AND    (d.ivd_quantity < 0 OR d.ivd_rate < 0.0) 
			AND    d.ivd_charge <> 0.0  ) 

	-- the reference number is not used on the 'standard' sp
END


-- for RTP masterbills (the invoice selection only allows masterbills
-- requested for RTP status or status = "PRN' with a masterbill#

IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0
BEGIN

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

	@varchar8 ivh_tractor,
	@int0 commodities,

	@int0 validcommodities,
	@int0 accessorials,
	@int0 validaccessorials,
	@varchar6 trltype3,
	@varchar6 cmp_subcompany,
	@money totallinehaul,
	@int0 negativecharges,
	@int0 edi_210_flag,
	@chary ismasterbill,
	'TrlType3' trltype3name,

	@varchar8 cmp_mastercompany,
	@varchar20 refnumber,
	@char3 cmp_invoiceto,
	@char1 cmp_invprintto,
	@int0  cmp_invformat,
	@varchar6 cmp_transfertype,
	@Status ivh_Mbstatus
	INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
	AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 

	AND (  @Status = invoiceheader.ivh_invoicestatus ) 
	AND 	(company.cmp_invoicetype in ('BTH','MAS') )
	AND 	( @BillTo in ( 'UNKNOWN' , invoiceheader.ivh_billto ) ) 
	AND 	( @Shipper in ( 'UNKNOWN' , invoiceheader.ivh_shipper ) ) 
	AND 	( @Consignee in ( 'UNKNOWN' , invoiceheader.ivh_consignee ) ) 
	AND 	( @OrderedBy in ( 'UNKNOWN' , invoiceheader.ivh_order_by ) ) 
	AND 	( invoiceheader.ivh_shipdate between @ShipDate1 and @ShipDate2 ) 
	AND 	( invoiceheader.ivh_deliverydate between @DelDate1 and @DelDate2 ) 
	AND 	( @Rev1 in ( 'UNK' , invoiceheader.ivh_revtype1 ) ) 
	AND 	( @Rev2 in ( 'UNK' , invoiceheader.ivh_revtype2 ) ) 
	AND 	( @Rev3 in ( 'UNK' , invoiceheader.ivh_revtype3 ) )  
	AND 	( @Rev4 in ( 'UNK' , invoiceheader.ivh_revtype4 ) ) 
	group by invoiceheader.ivh_billto  

 END

-- If selection datawindow has masterbills and status = 'PRN' the
-- only parameter used is the master bill number

IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) > 0
BEGIN

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

	@varchar8 ivh_tractor,
	@int0 commodities,

	@int0 validcommodities,
	@int0 accessorials,
	@int0 validaccessorials,
	@varchar6 trltype3,
	@varchar6 cmp_subcompany,
	@money totallinehaul,
	@int0 negativecharges,
	@int0 edi_210_flag,
	@chary ismasterbill,
	'TrlType3' trltype3name,

	@varchar8 cmp_mastercompany,
	@varchar20 refnumber,
	@char3 cmp_invoiceto,
	@char1 cmp_invprintto,
	@int0  cmp_invformat,
	@varchar6 cmp_transfertype,
	min(invoiceheader.ivh_mbstatus)  ivh_Mbstatus
	INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
	AND ( ivh_mbnumber = @mbnumber)
	
 END

SELECT * from #invview



GO
GRANT EXECUTE ON  [dbo].[d_invoices_view_sp] TO [public]
GO
