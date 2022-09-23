SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_invoices_printqueue_sp] (@status VARCHAR(6), @billto VARCHAR(8),

		@shipper varchar(8), @consignee varchar(8), @orderedby varchar(8),
		@shipdate1 datetime, @shipdate2 datetime, @deldate1 datetime, 
		@deldate2 datetime, @rev1 varchar(6),
		@rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6), 
		@printdate datetime, @doinvoices char(1), 
		@domasterbills char(1) , @mbnumber int, 
		@billdate1 datetime, @billdate2 datetime, 
		@breakon_shipper_consignee varchar(18),
		@mbcompany_include char(1), @user_id char(20), @byuser char(1),@paperworkstatus varchar(6),
		@xfrdate1 datetime, @xfrdate2 datetime,@imagestatus tinyint, @usr_id char(20), 
		@company varchar(6), @ord_number varchar (12), @sch_date1 datetime, @sch_date2 datetime,
		@driverid varchar(8), @dodedbills char(1), @dbh_id int	) -- PTS 55252 SGB
AS

/**
 * 
 * NAME:
 * dbo.d_invoices_printqueue_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Proc for dw d_invoices_printqueue
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
 * Modified 8/8/00 pts7896 add trasfertype for masterbills
05/23/01 dpete pts8790 add cmp_invoicetype to return set to allow bypass output on printing
DPETE PTS13822 Bring back tar_tariffitem and number from invoiceheader for master bill formats 19&20
DPETE PTS15533 Add ivh_ref_number to selection and to return set
DPETE PTS 15913 add image status to args and return
DPETE PTS 16354 remove the ref number selection
LOR	PTS# 23109	add company
* LOR	PTS# 30053	added sch earliest dates
*     recode  PTS30355 add break on alt bill to address (car_key) NOTER: car_key is a way
*                   to assoicate mutiple billing addresses with a single bill to company 
* PTS 55252 SGB Added @dodedbills and @dbh_id 
**/

DECLARE @int0  int, @varchar6 varchar(6), @varchar8 varchar (8), @money money, 
	@varchar254 varchar(254), @varchar30 varchar(30), @char3 char(3), @charn char,
	@chary char, @varchar20 varchar(20), @char1 char(1), @dummystatus varchar(6),
	@copies smallint
--PTS 40929 JJF 20071211
declare @rowsecurity char(1)
--PTS 51570 JJF 20100510
--declare @tmwuser varchar(255)
--END PTS 51570 JJF 20100510
--PTS 40929 JJF 20071211

SELECT @int0 = 0, @money = 0.00, @varchar8 = '', @varchar30 = '', @varchar254 = '',
     @varchar6 = '', @char3 = '', @charn = 'N', @chary = 'Y',@varchar20 = '',
	@dummystatus = '<',@copies = 0

-- @breakon_shipper_consignee variable, possible values:
-- ShipperConsignee 	- One masterbill per shipper consignee combination
-- MasterBill 		- One masterbill per bill to company
-- Invoice 		- One masterbill per individual invoice

-- for reprinting invoices the PRN and PRO status are the same
-- for reprinting masterbills the status is not used
IF @status = 'PRN'
	SELECT @dummystatus = 'PRO'
IF @status = 'PRO'
	SELECT @dummystatus = 'PRN'
 
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
	cmp_subcompany varchar(6) NULL,
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
	cmp_invoicetype varchar(6) NULL,
	tar_tariffitem varchar(12) NULL,
	tar_tariffnumber varchar(12) NULL,
	--ivh_ref_number varchar(20) NULL,
	imagestatus tinyint NULL,
	ivh_definition varchar(6) NULL,
	ivh_applyto varchar(12) NULL,
	cmp_image_routing1	varchar(254) NULL,
	cmp_image_routing2	varchar(254) NULL,
	cmp_image_routing3	varchar(254) NULL,
	ivh_company varchar(6) null,
	ivh_showshipper varchar(8) null,
	ivh_showcons varchar(8) null, 
	car_key int null,    --40753
	inv_accessorials	money	null, 	/* 08/24/2009 MDH PTS 42291: Added */
	inv_fuel			money	null, 	/* 08/24/2009 MDH PTS 42291: Added */
	inv_linehaul		money	null,	/* 08/24/2009 MDH PTS 42291: Added */
	ivh_driver varchar(8) null,
	dbh_id int null
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
 			Substring(bcmp.cmp_name,1,30) billto_name,
 			invoiceheader.ivh_shipper,
 			Substring(scmp.cmp_name,1,30) shipper_name,
 			invoiceheader.ivh_consignee,
 			Substring(ccmp.cmp_name,1,30) consignee_name,
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
			@varchar30 'refnumber',
			bcmp.cmp_invoiceto,
			bcmp.cmp_invprintto,
			bcmp.cmp_invformat,
			bcmp.cmp_transfertype,
			invoiceheader.ivh_mbstatus,
			@money trp_linehaulmax,
			@money trp_totchargemax,
			bcmp.cmp_invcopies,
			bcmp.cmp_invoicetype,
			IsNull(invoiceheader.tar_tariffitem,''),
			IsNull(invoiceheader.tar_tarriffnumber,''),
			--IsNull(invoiceheader.ivh_ref_number,''),
			IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		IsNull(ivh_company, 'UNK'),
		isnull(ivh_showshipper, 'UNKNOWN'),
		isnull(ivh_showcons, 'UNKNOWN'), 
		 isnull(invoiceheader.car_key,0),  --40753	
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
		isnull(invoiceheader.ivh_driver,'UNKNOWN'),
		dbh_id	
		FROM invoiceheader, company bcmp, company scmp, company ccmp 
		WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus) ) 
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
			AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
			AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 		((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 		@status not in ('XFR'))
			--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
			And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))
  			--DPH PTS 23007
  			-- PTS 28804 -- BL (start)
--  			AND (@usr_id in ( CASE ivh_user_id2
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
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      

		IF @byuser = 'Y'
		INSERT INTO #invview
		SELECT invoiceheader.mov_number,
 			invoiceheader.ivh_invoicenumber,
 			invoiceheader.ivh_invoicestatus,
 			invoiceheader.ivh_billto,
 			Substring(bcmp.cmp_name,1,30) billto_name,
 			invoiceheader.ivh_shipper,
 			Substring(scmp.cmp_name,1,30) shipper_name,
 			invoiceheader.ivh_consignee,
 			Substring(ccmp.cmp_name,1,30) consignee_name,
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
			@varchar30 'refnumber',
			bcmp.cmp_invoiceto,
			bcmp.cmp_invprintto,
			bcmp.cmp_invformat,
			bcmp.cmp_transfertype,
			invoiceheader.ivh_mbstatus,
			@money trp_linehaulmax,
			@money trp_totchargemax,
			bcmp.cmp_invcopies,
			bcmp.cmp_invoicetype,
			IsNull(invoiceheader.tar_tariffitem,''),
			IsNull(invoiceheader.tar_tarriffnumber,''),
			--IsNull(invoiceheader.ivh_ref_number,''),
			IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		IsNull(ivh_company, 'UNK'),
		isnull(ivh_showshipper, 'UNKNOWN'),
		isnull(ivh_showcons, 'UNKNOWN'),
	 isnull(invoiceheader.car_key,0),  --40753	
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
		isnull(invoiceheader.ivh_driver,'UNKNOWN'),
		dbh_id	
		FROM invoiceheader, company bcmp, company scmp, company ccmp 
		WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus) ) 
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
			AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
			and ivh_user_id1 = @user_id
			AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 		((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 		@status not in ('XFR'))
		--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
			And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))
  			--DPH PTS 23007
  			-- PTS 28804 -- BL (start)
--  			AND (@usr_id in ( CASE ivh_user_id2
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
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	end

	IF @mbcompany_include = 'Y'
	begin
		IF @byuser = 'N'
		INSERT INTO #invview
		SELECT invoiceheader.mov_number,
 			invoiceheader.ivh_invoicenumber,
 			invoiceheader.ivh_invoicestatus,
 			invoiceheader.ivh_billto,
 			Substring(bcmp.cmp_name,1,30) billto_name,
 			invoiceheader.ivh_shipper,
 			Substring(scmp.cmp_name,1,30) shipper_name,
 			invoiceheader.ivh_consignee,
 			substring(ccmp.cmp_name,1,30) consignee_name,
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
			@varchar30 'refnumber',
			bcmp.cmp_invoiceto,
			bcmp.cmp_invprintto,
			bcmp.cmp_invformat,
			bcmp.cmp_transfertype,
			invoiceheader.ivh_mbstatus,
			@money trp_linehaulmax,
			@money trp_totchargemax,
			bcmp.cmp_invcopies,
			bcmp.cmp_invoicetype,
			IsNull(invoiceheader.tar_tariffitem,''),
			IsNull(invoiceheader.tar_tarriffnumber,''),
		--	IsNull(invoiceheader.ivh_ref_number,'')  ,
			IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		IsNull(ivh_company, 'UNK'),
		isnull(ivh_showshipper, 'UNKNOWN'),
		isnull(ivh_showcons, 'UNKNOWN'),
	 isnull(invoiceheader.car_key,0),  --40753	
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
		isnull(invoiceheader.ivh_driver,'UNKNOWN'),
		dbh_id	
		FROM invoiceheader, company bcmp, company scmp, company ccmp 
		WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus) ) 
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
			AND ( scmp.cmp_id = invoiceheader.ivh_shipper)
			AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)
			AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
			AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 		((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 		@status not in ('XFR'))
		--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
			And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))
  			--DPH PTS 23007
  			-- PTS 28804 -- BL (start)
--  			AND (@usr_id in ( CASE ivh_user_id2
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
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      

		IF @byuser = 'Y'
		INSERT INTO #invview
		SELECT invoiceheader.mov_number,
 			invoiceheader.ivh_invoicenumber,
 			invoiceheader.ivh_invoicestatus,
 			invoiceheader.ivh_billto,
 			substring(bcmp.cmp_name,1,30) billto_name,
 			invoiceheader.ivh_shipper,
 			substring(scmp.cmp_name,1,30) shipper_name,
 			invoiceheader.ivh_consignee,
 			substring(ccmp.cmp_name,1,30) consignee_name,
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
			@varchar30 'refnumber',
			bcmp.cmp_invoiceto,
			bcmp.cmp_invprintto,
			bcmp.cmp_invformat,
			bcmp.cmp_transfertype,
			invoiceheader.ivh_mbstatus,
			@money trp_linehaulmax,
			@money trp_totchargemax,
			bcmp.cmp_invcopies,
			bcmp.cmp_invoicetype,
			IsNull(invoiceheader.tar_tariffitem,''),
			IsNull(invoiceheader.tar_tarriffnumber,''),
			--IsNull(invoiceheader.ivh_ref_number,''),
			IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		IsNull(ivh_company, 'UNK'),
		isnull(ivh_showshipper, 'UNKNOWN'),
		isnull(ivh_showcons, 'UNKNOWN'),
	 isnull(invoiceheader.car_key,0),  --40753	 
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
		isnull(invoiceheader.ivh_driver,'UNKNOWN'),
		dbh_id
		FROM invoiceheader, company bcmp, company scmp, company ccmp 
		WHERE (   invoiceheader.ivh_invoicestatus in (@Status ,@dummystatus) ) 
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
			AND ( scmp.cmp_id = invoiceheader.ivh_shipper)
			AND ( ccmp.cmp_id = invoiceheader.ivh_consignee)
			AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
			and ivh_user_id1 = @user_id
			AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 		((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 		@status not in ('XFR'))
		--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
			And @imagestatus in (0,IsNull(invoiceheader.ivh_imagestatus,0))
  			--DPH PTS 23007
  			-- PTS 28804 -- BL (start)
--  			AND (@usr_id in ( CASE ivh_user_id2
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
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	end

	--	LOR	PTS# 15300	do updates for Floridarock only
	if (select Upper(gi_string1) from generalinfo where gi_name = 'SystemOwner') = 'FLORIDAROCK'
	begin
	-- Note trltype3 column is used for Florida Rock in d_invoices_view2
	-- Provide a total linehaul charge for each invoice
	UPDATE	#invview
	SET	totallinehaul = (SELECT	SUM(d.ivd_charge)
				FROM 	invoicedetail d, chargetype c
				WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary = 'Y'
				)

	-- Count the  distinct commodities on the invoice
	UPDATE 	#invview 
	SET	commodities =   (SELECT COUNT(DISTINCT(d.cmd_code))

				FROM	invoicedetail d, CHARGETYPE C
				WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
				AND 	d.cht_itemcode NOT IN ( 'MIN','ORDFLT')
				AND	d.ivd_type <> 'SUB'
				AND	d.cht_itemcode = c.cht_itemcode
				AND     c.cht_primary = 'Y'
				)
			
	-- Count the commodities which match to the edicommodity table
		UPDATE 	#invview
		SET	validcommodities =  (SELECT COUNT(DISTINCT(d.cmd_code))
				FROM	invoicedetail d,  edicommodity e,chargetype c
				WHERE	#invview.ivh_hdrnumber = d.ivh_hdrnumber
				AND 	d.cht_itemcode NOT IN ( 'MIN','ORDFLT')

				AND	d.ivd_type <> 'SUB'
				AND	d.cht_itemcode = c.cht_itemcode
				AND     c.cht_primary = 'Y'
				AND	e.cmp_id = #invview.ivh_billto
				AND	e.cmd_code = d.cmd_code)

		-- Count the accessorial charge types on the invoice 
		UPDATE 	#invview
		SET	accessorials = (SELECT COUNT(DISTINCT(d.cht_itemcode))
				FROM	invoicedetail d, chargetype c
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary <> 'Y' )
			
	-- Count the accessorial charge types on the invoice which  
	-- match the edicommodity table
	UPDATE #invview

	SET	validaccessorials = (SELECT COUNT(DISTINCT(d.cht_itemcode))
				FROM	invoicedetail d, chargetype c, ediaccessorial e
				WHERE	d.ivh_hdrnumber = #invview.ivh_hdrnumber
				AND	d.cht_itemcode = c.cht_itemcode
				AND	c.cht_primary <> 'Y'
				AND	e.cmp_id = #invview.ivh_billto
				AND	e.cht_itemcode = d.cht_itemcode )
	
	-- Count the number of charge lines which have either a negative qty or rate
	Update	#invview
	SET	negativecharges = (SELECT count(*)
			FROM   invoicedetail d
			WHERE  d.ivh_hdrnumber = #invview.ivh_hdrnumber
			AND    (d.ivd_quantity < 0 OR d.ivd_rate < 0.0) 
			AND    d.ivd_charge <> 0.0  ) 

	-- determine info for doing a max charge screen on edi transmission
	UPDATE 	#invview
	SET	#invview.trp_linehaulmax = t.trp_linehaulmax,
		#invview.trp_totchargemax = t.trp_totchargemax
	FROM	#invview, edi_trading_partner t
	WHERE	t.cmp_id = #invview.ivh_billto
	end
	-- the reference number is not used on the 'standard' sp
END

-- for RTP masterbills (the invoice selection only allows masterbills
-- requested for RTP status or status = "PRN' with a masterbill#
-- breakon_shipper_consignee = 'MasterBill'
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0 and @breakon_shipper_consignee = 'MasterBill'
BEGIN
     IF @status = 'RTP' 
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
		@varchar8 ivh_tractor,
		@int0 commodities,
		@int0 validcommodities,
		@int0 accessorials,
		@int0 validaccessorials,
		@varchar6 trltype3,
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
	--	Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')) , 
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	--INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
		AND (company.cmp_invoicetype in ('BTH','MAS') )
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
		--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto  

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
		@varchar8 ivh_tractor,
		@int0 commodities,
		@int0 validcommodities,
		@int0 accessorials,
		@int0 validaccessorials,
		@varchar6 trltype3,
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
	max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')) ,
	 max(isnull(invoiceheader.car_key,0)), 	
	--INTO #invview
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
		AND (company.cmp_invoicetype in ('BTH','MAS') )
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		and ivh_user_id1 = @user_id
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
		--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto 
END

-- for RTP masterbills (the invoice selection only allows masterbills
-- requested for RTP status or status = "PRN' with a masterbill#
-- breakon_shipper_consignee = 'ShipperConsignee'
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0 and @breakon_shipper_consignee = 'ShipperConsignee'
BEGIN
     IF @status = 'RTP'
	IF @byuser = 'N'
	INSERT INTO #invview	
	SELECT 0 mov_number,
 		'Master' ivh_invoicenumber,
 		min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,
 		invoiceheader.ivh_billto,
 		@varchar30 billto_name,
 		invoiceheader.ivh_shipper,
 		@varchar30 shipper_name,
 		invoiceheader.ivh_consignee,
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
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')) ,
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	--INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
		AND (company.cmp_invoicetype in ('BTH','MAS') )
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
		--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto, invoiceheader.ivh_shipper, invoiceheader.ivh_consignee

	IF @byuser = 'Y'
	INSERT INTO #invview	
	SELECT 0 mov_number,
 		'Master' ivh_invoicenumber,
 		min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,
 		invoiceheader.ivh_billto,
 		@varchar30 billto_name,
 		invoiceheader.ivh_shipper,
 		@varchar30 shipper_name,
 		invoiceheader.ivh_consignee,
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
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')),
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	--INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
		AND (company.cmp_invoicetype in ('BTH','MAS') )
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		and ivh_user_id1 = @user_id
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
	--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto, invoiceheader.ivh_shipper, invoiceheader.ivh_consignee
 END

-- for RTP masterbills (the invoice selection only allows masterbills
-- requested for RTP status or status = "PRN' with a masterbill#
-- breakon_shipper_consignee = 'Invoice'
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0 and @breakon_shipper_consignee = 'Invoice'
BEGIN
     IF @status = 'RTP'
	IF @byuser = 'N'
	INSERT INTO #invview	
	SELECT 0 mov_number,
 		invoiceheader.ivh_invoicenumber,
 		min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,
 		invoiceheader.ivh_billto,
 		@varchar30 billto_name,
 		invoiceheader.ivh_shipper,
 		@varchar30 shipper_name,
 		invoiceheader.ivh_consignee,
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
		@varchar8 cmp_subcompany,
		@money totallinehaul,
		@int0 negativecharges,		@int0 edi_210_flag,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')) ,
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')),
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	--INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
	--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto, invoiceheader.ivh_invoicenumber, 
		invoiceheader.ivh_shipper, invoiceheader.ivh_consignee

	IF @byuser = 'Y'
	INSERT INTO #invview	
	SELECT 0 mov_number,
 		invoiceheader.ivh_invoicenumber,
 		min(invoiceheader.ivh_mbstatus) ivh_invoicestatus,
 		invoiceheader.ivh_billto,
 		@varchar30 billto_name,
 		invoiceheader.ivh_shipper,
 		@varchar30 shipper_name,
 		invoiceheader.ivh_consignee,
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
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')),
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
	--INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
		AND (  @Status = invoiceheader.ivh_mbstatus ) 
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
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		and ivh_user_id1 = @user_id
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))and
	 	((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
							or invoiceheader.ivh_xferdate IS null)) or
	 	@status not in ('XFR'))
	--	And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		--And @imagestatus in (0,IsNull(invoiceheader.ivh_mbimagestatus,0))
		AND @company in ('UNK', invoiceheader.ivh_company) and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
	group by invoiceheader.ivh_billto, invoiceheader.ivh_invoicenumber, 
		invoiceheader.ivh_shipper, invoiceheader.ivh_consignee

 END

-- If selection datawindow has masterbills and status = 'PRN' the
-- only parameter used is the master bill number
IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) > 0
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
		@varchar8 ivh_tractor,
		@int0 commodities,
		@int0 validcommodities,
		@int0 accessorials,
		@int0 validaccessorials,
		@varchar6 trltype3,
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
	max(IsNull(ivh_company, 'UNK')),
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')),
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
	 max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
	max(dbh_id)	
--	INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( ivh_mbnumber = @mbnumber)
		AND @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)
		And invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end)  and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)      
 
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
		@varchar8 ivh_tractor,
		@int0 commodities,
		@int0 validcommodities,
		@int0 accessorials,
		@int0 validaccessorials,
		@varchar6 trltype3,
		@varchar8 cmp_subcompany,
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
		max(company.cmp_invoicetype) cmp_invoicetype,
		max(IsNull(invoiceheader.tar_tariffitem,'')),
		max(IsNull(invoiceheader.tar_tarriffnumber,'')),
		--Max(IsNull(invoiceheader.ivh_ref_number,'')),
		Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
		max(ivh_definition) ivh_definition,
		max(ivh_applyto) ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		max(IsNull(ivh_company, 'UNK')), 
		-- PTS 28467 -- BL (start)
		max(isnull(ivh_showshipper, 'UNKNOWN')),
		max(isnull(ivh_showcons, 'UNKNOWN')) ,
		-- PTS 28467 -- BL (end)
	 max(isnull(invoiceheader.car_key,0)), 	
		sum (dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber)), 	/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber)), 		/* 08/24/2009 MDH PTS 42291: Added */
		sum (dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber)),		/* 08/24/2009 MDH PTS 42291: Added */
		max(isnull(invoiceheader.ivh_driver,'UNKNOWN')),
		max(dbh_id)	
--	INTO #invview
	FROM invoiceheader , company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
		AND ( ivh_mbnumber = @mbnumber)
		and ivh_user_id1 = @user_id
		AND @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)
		And invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end)  and
	(((select min(stp_schdtearliest )
	from stops 
	where stops.ord_hdrnumber = invoiceheader.ord_hdrnumber and stp_sequence = 1 )
		between @sch_date1 and @sch_date2 ) or
	invoiceheader.ord_hdrnumber = 0)       
 END


-- Printing by dedicated bill number   
IF @dodedbills = 'Y' and ISNULL(@dbh_id,0) > 0   
BEGIN    
  INSERT INTO #invview     
 		SELECT invoiceheader.mov_number,
 			invoiceheader.ivh_invoicenumber,
 			invoiceheader.ivh_invoicestatus,
 			invoiceheader.ivh_billto,
 			Substring(bcmp.cmp_name,1,30) billto_name,
 			invoiceheader.ivh_shipper,
 			Substring(scmp.cmp_name,1,30) shipper_name,
 			invoiceheader.ivh_consignee,
 			Substring(ccmp.cmp_name,1,30) consignee_name,
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
			@varchar30 'refnumber',
			bcmp.cmp_invoiceto,
			bcmp.cmp_invprintto,
			bcmp.cmp_invformat,
			bcmp.cmp_transfertype,
			invoiceheader.ivh_mbstatus,
			@money trp_linehaulmax,
			@money trp_totchargemax,
			bcmp.cmp_invcopies,
			bcmp.cmp_invoicetype,
			IsNull(invoiceheader.tar_tariffitem,''),
			IsNull(invoiceheader.tar_tarriffnumber,''),
			--IsNull(invoiceheader.ivh_ref_number,''),
			IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		IsNull(ivh_company, 'UNK'),
		isnull(ivh_showshipper, 'UNKNOWN'),
		isnull(ivh_showcons, 'UNKNOWN'), 
		 isnull(invoiceheader.car_key,0),  --40753	
		dbo.fn_inv_accessorial_charge (invoiceheader.ivh_hdrnumber), 	/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_fuel_charge (invoiceheader.ivh_hdrnumber), 			/* 08/24/2009 MDH PTS 42291: Added */
		dbo.fn_inv_linehaul_charge (invoiceheader.ivh_hdrnumber),		/* 08/24/2009 MDH PTS 42291: Added */
		isnull(invoiceheader.ivh_driver,'UNKNOWN'),
		dbh_id	
  FROM invoiceheader
	join company bcmp on bcmp.cmp_id = invoiceheader.ivh_billto
	join company scmp on scmp.cmp_id = invoiceheader.ivh_shipper
	join  company ccmp on ccmp.cmp_id = invoiceheader.ivh_consignee
  left outer join orderheader on invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber 
  WHERE  invoiceheader.dbh_id = @dbh_id    
  AND @driverid in ('UNKNOWN',invoiceheader.ivh_driver) -- PTS 48221
  AND  IsNull (ivh_user_id1, '') = case @byuser when 'Y' then  @user_id else   IsNull (ivh_user_id1, '') end
 -- GROUP BY dbh_id
END 

--PTS 51570 JJF 20100510
----PTS 40929 JJF 20071211
--SELECT @rowsecurity = gi_string1
--FROM generalinfo 
--WHERE gi_name = 'RowSecurity'

----PTS 41877
----SELECT @tmwuser = suser_sname()
--exec @tmwuser = dbo.gettmwuser_fn

--IF @rowsecurity = 'Y' AND EXISTS(SELECT * 
--				FROM UserTypeAssignment
--				WHERE usr_userid = @tmwuser) BEGIN 

--	--PTS42432 JJF 20080421	
--	--DELETE #invview
--	--from #invview tp inner join orderheader oh on tp.mov_number = oh.mov_number
--	--where  NOT ((isnull(oh.ord_BelongsTo, 'UNK') = 'UNK' 
--	--		or EXISTS(SELECT * 
--	--					FROM UserTypeAssignment
--	--					WHERE usr_userid = @tmwuser	
--	--							and (uta_type1 = oh.ord_BelongsTo
--	--									or uta_type1 = 'UNK'))))
--	DELETE #invview
--	from #invview tp inner join invoiceheader ivh on tp.ivh_hdrnumber = ivh.ivh_hdrnumber
--	where  NOT ((isnull(ivh.ivh_BelongsTo, 'UNK') = 'UNK' 
--			or EXISTS(SELECT * 
--						FROM UserTypeAssignment
--						WHERE usr_userid = @tmwuser	
--								and (uta_type1 = ivh.ivh_BelongsTo
--										or uta_type1 = 'UNK'))))

--END
----END PTS 40929 JJF 20071211

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN 
	DELETE #invview
	from #invview tp inner join invoiceheader ivh on tp.ivh_hdrnumber = ivh.ivh_hdrnumber
	WHERE	NOT EXISTS	(	SELECT	*  
							FROM	RowRestrictValidAssignments_invoiceheader_fn() rsva 
							WHERE	ivh.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0
						)
END
--END PTS 51570 JJF 20100510

UPDATE	#invview
   SET	#invview.cmp_image_routing1 = company.cmp_image_routing1,
		#invview.cmp_image_routing2 = company.cmp_image_routing2,
		#invview.cmp_image_routing3 = company.cmp_image_routing3
  FROM	company
 WHERE	#invview.ivh_billto = company.cmp_id

SELECT * from #invview

GO
GRANT EXECUTE ON  [dbo].[d_invoices_printqueue_sp] TO [public]
GO
