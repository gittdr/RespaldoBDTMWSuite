SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


/*
  PTS 17378 -- BL (8/8/2003)
  NEW PROC  (for Express Leasing) (copied and modified from 'd_invoices_printqueue2_sp')
     Will ONLY work with 'GREAT PLAINS' accounting system
	(explicit reference to table and column on database)

LOR	PTS# 23109	add company
*/

CREATE  PROC [dbo].[d_invoices_printqueue_balance_due_sp] (@status VARCHAR(6), @billto VARCHAR(8),
		@shipper varchar(8), @consignee varchar(8), @orderedby varchar(8),
		@shipdate1 datetime, @shipdate2 datetime, @deldate1 datetime, 
		@deldate2 datetime, @rev1 varchar(6),
		@rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6), 
		@printdate datetime ,@doinvoices char(1), @domasterbills char(1),
		@mbnumber int, @billdate1 datetime, @billdate2 datetime, @breakon char(1), 
		@user_id char(20), @byuser char(1),@paperworkstatus varchar(6),
		@xfrdate1 datetime, @xfrdate2 datetime,@imagestatus tinyint, @usr_id char(20), 
	@company varchar(6))
AS

DECLARE @int0  int, @varchar6 varchar(6), @varchar8 varchar (8), @money money, 
	@varchar254 varchar(254), @varchar30 varchar(30), @char3 char(3), @charn char,
	@chary char, @varchar20 varchar(20), @char1 char(1), @dummystatus varchar(6)


SELECT @int0 = 0, @money = 0.00, @varchar8 = '', @varchar30 = '', @varchar254 = '',
     @varchar6 = '', @char3 = '', @charn = 'N', @chary = 'Y',@varchar20 = '',
	@dummystatus = '>'

-- for reprinting invoices treat the PRN and PRO status as if they are the same
-- (for reprinting masterbills the status is not used)
IF @status = 'PRN' 
	SELECT @dummystatus = 'PRO'
IF @status = 'PRO' 
	SELECT @dummystatus = 'PRN'
 
CREATE TABLE #invview (	
	mov_number int NULL,
	ivh_invoicenumber varchar(12),
	ivh_invoicestatus varchar(6) NULL,
	ivh_billto varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	billto_name varchar(30) NULL,
	billto_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
	ivh_shipper varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	shipper_name varchar(30) NULL,
	shipper_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
	ivh_consignee varchar(8) NULL,
-- PTS 30277 -- BL (start)
--	consignee_name varchar(30) NULL,
	consignee_name varchar(100) NULL,
-- PTS 30277 -- BL (end)
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
	ivh_Mbstatus varchar(6) NULL,
	trp_linehaulmax money NULL,
	trp_totchargemax money NULL,
	cmp_invcopies smallint NULL,
	cmp_invoicetype varchar(6) NULL,
	tar_tariffitem varchar(12) NULL,
	tar_tariffnumber varchar(12) NULL,
	ivh_ref_number varchar(30) NULL,
	imagestatus tinyint NULL,
	ivh_definition varchar(6) NULL,
	ivh_applyto varchar(12) NULL,
	cmp_image_routing1	varchar(254) NULL,
	cmp_image_routing2	varchar(254) NULL,
	cmp_image_routing3	varchar(254) NULL,
	balance_due	money NULL,
ivh_company varchar(6) null )

IF @doinvoices = 'Y'
BEGIN
	IF @byuser = 'N'
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
		IsNull(invoiceheader.ivh_ref_number,''),
		IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		0,
	IsNull(ivh_company, 'UNK')
	FROM invoiceheader, company bcmp, company scmp, company ccmp 
	WHERE ( invoiceheader.ivh_invoicestatus in (@status,@dummystatus)  ) 
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
	AND 	(bcmp.cmp_invoicetype in ('BTH','INV','NONE') )
	AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
	AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)
	AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
	AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and
	 ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
					or invoiceheader.ivh_xferdate IS null)) or
	 @status not in ('XFR'))
	AND @imagestatus in (0,IsNull(ivh_imagestatus,0)) 
  	--DPH PTS 23007
	-- PTS 28804 -- BL (start)
--  	AND (@usr_id in ( CASE ivh_user_id2
  	AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
	-- PTS 28804 -- BL (end)
    		    	  WHEN 'NULL' THEN ivh_user_id1
     		     	   ELSE ivh_user_id2
                    	  END,
		    	  'UNK'))
  	--DPH PTS 23007 
	AND @company in ('UNK', invoiceheader.ivh_company)	

	IF @byuser = 'Y'
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
		IsNull(invoiceheader.ivh_ref_number,''),
		IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
		0,
	IsNull(ivh_company, 'UNK')
	FROM invoiceheader, company bcmp, company scmp, company ccmp 
	WHERE ( invoiceheader.ivh_invoicestatus in (@status,@dummystatus)  ) 
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
	AND 	(bcmp.cmp_invoicetype in ('BTH','INV','NONE') )
	AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
	AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)
	AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
	and ivh_user_id1 = @user_id
	AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus )) and
	 ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
					or invoiceheader.ivh_xferdate IS null)) or
	 @status not in ('XFR'))
	AND @imagestatus in (0,IsNull(ivh_imagestatus,0))
	 --DPH PTS 23007
	-- PTS 28804 -- BL (start)
--  	AND (@usr_id in ( CASE ivh_user_id2
  	AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
	-- PTS 28804 -- BL (end)
    		    	  WHEN 'NULL' THEN ivh_user_id1
     		     	   ELSE ivh_user_id2
                    	  END,
		    	  'UNK'))
  	--DPH PTS 23007 
	AND @company in ('UNK', invoiceheader.ivh_company)

	--	LOR	PTS# 15300	do updates for Floridarock only
	if (select Upper(gi_string1) from generalinfo where gi_name = 'SystemOwner') = 'FLORIDAROCK'
	begin
-- return the trltype3 column value (for flarock indicates tank, dump, flatbed) 
	UPDATE	#invview 
	SET	#invview.trltype3 =  t.trl_type3 
	FROM	trailerprofile t
	Where	t.trl_number = #invview.ivh_trailer


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

	-- update the shippers ticket as the ref number
	UPDATE 	#invview
	SET	#invview.refnumber = r.ref_number
	FROM	referencenumber r
	WHERE	r.ref_table = 'ORDERHEADER'
	AND	r.ref_tablekey = #invview.ord_hdrnumber
	AND     r.ref_type = 'SHIPTK'

	-- retrieve any max charges for edi qualification
	UPDATE 	#invview
	SET	#invview.trp_linehaulmax = t.trp_linehaulmax,
		#invview.trp_totchargemax = t.trp_totchargemax
	FROM	edi_trading_partner t
	WHERE	t.cmp_id = #invview.ivh_billto
	end

END

UPDATE	#invview
  SET	#invview.cmp_image_routing1 = company.cmp_image_routing1,
		#invview.cmp_image_routing2 = company.cmp_image_routing2,
		#invview.cmp_image_routing3 = company.cmp_image_routing3
 FROM	company
WHERE	#invview.ivh_billto = company.cmp_id

SELECT * from #invview

GO
GRANT EXECUTE ON  [dbo].[d_invoices_printqueue_balance_due_sp] TO [public]
GO
