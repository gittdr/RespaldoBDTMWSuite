SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*	LOR	PTS# 15514 Created for QDI		
DPETE PTS16354 remove ref number argument, return ord_fromorder for mb format 29
DPETE PTS16789 Mane @shipper default on case for master bill and @Consignee the default
LOR	PTS# 23109	add company
*/

CREATE PROC [dbo].[d_invoices_printqueue_qdi_sp] (@status VARCHAR(6), @billto VARCHAR(8),
                @shipper varchar(8), @consignee varchar(8), @orderedby varchar(8),
		@shipdate1 datetime, @shipdate2 datetime, @deldate1 datetime, 
		@deldate2 datetime, @rev1 varchar(6),
		@rev2 varchar(6), @rev3 varchar(6), @rev4 varchar(6), 
		@printdate datetime ,@doinvoices char(1), @domasterbills char(1),
		@mbnumber int, @billdate1 datetime, @billdate2 datetime, @breakon char(1),
		@mbcompany_include char(1), @user_id char(20), @byuser char(1),@paperworkstatus varchar(6),
		@xfrdate1 datetime, @xfrdate2 datetime,@imagestatus tinyint, @usr_id char(20), 
	@company varchar(6))
		--@xfrdate1 datetime, @xfrdate2 datetime,@ivhrefnumber varchar(20),@imagestatus tinyint)
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
	ivh_Mbstatus varchar(6) NULL,
	trp_linehaulmax money NULL,
	trp_totchargemax money NULL,
	cmp_invcopies smallint NULL,
	cmp_mbgroup varchar(6) NULL,
	ivh_originpoint varchar(8) NULL,
    cmd_code varchar(8) NULL,
	cmp_invoicetype varchar(6) NULL,
	ivh_currency varchar(6) null,
	tar_tariffitem varchar(12) NULL,
	tar_tariffnumber varchar(12) NULL,
	--ivh_ref_number varchar(20) NULL,
	imagestatus tinyint NULL,
	ivh_definition varchar(6) NULL,
	ivh_applyto varchar(12) NULL,
	ord_fromorder varchar(12) NULL,
	cmp_image_routing1	varchar(254) NULL,
	cmp_image_routing2	varchar(254) NULL,
	cmp_image_routing3	varchar(254) NULL,
ivh_company varchar(6) null   
	)

DECLARE	@reason_1 	varchar(6),
	@i_reason		int,
	@reasons		varchar(60),
	@rsn_len		int,
	@rsn_len_1		int

select @reasons = RTRIM(LTRIM(gi_string1))
from generalinfo
where gi_name = 'InvNoPrintReasons'

select @i_reason = 0
select @rsn_len = LEN(@reasons)

create table #rsn (rsn_id varchar(6) not null)

WHILE @rsn_len > 0
BEGIN
	select @i_reason = charindex(',', LTRIM(@reasons))
	If @i_reason > 0
	BEGIN
		SELECT @reason_1 = LTRIM(substring(@reasons, 1, (@i_reason - 1)))
		select @reasons = LTRIM(substring(@reasons, (@i_reason + 1), (60 - @i_reason)))
		select @rsn_len = LEN(@reasons)
		insert #rsn (rsn_id) values(@reason_1)
	END
	If @i_reason = 0
	BEGIN
		insert #rsn (rsn_id) values(@reasons)
		select @rsn_len = 0
	END
END

IF @doinvoices = 'Y'
BEGIN
	IF @mbcompany_include = 'N'
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
		refnumber = ivh_ref_number,
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
        cmd_code = ISNULL(orderheader.cmd_code,'UNKNOWN'),
		bcmp.cmp_invoicetype,
		ivh_currency,
		IsNull(invoiceheader.tar_tariffitem,''),
		IsNull(invoiceheader.tar_tarriffnumber,''),
		--IsNull(invoiceheader.ivh_ref_number,''),
		IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto ,
		IsNull(orderheader.ord_fromorder,''),
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK')  
		FROM invoiceheader LEFT OUTER JOIN orderheader ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber, 
			company bcmp, company scmp, company ccmp 
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
--      AND     (orderheader.ord_hdrnumber =* invoiceheader.ord_hdrnumber)
		AND     ( bcmp.cmp_id = invoiceheader.ivh_billto)
--		AND 	(bcmp.cmp_invoicetype in ('BTH','INV','NONE') )
		AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
		AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))
	--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
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
	and ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
					or invoiceheader.ivh_xferdate IS null)) or
	 	(@status not in ('XFR') and
			bcmp.cmp_invoicetype in ('BTH','INV') and 
--			(ivh_block_printing = 'N' or ivh_block_printing is null) and 
			(ivh_block_printing in ( 'N', '') or ivh_block_printing is null) and 
			(ivh_creditmemo = 'N' or ivh_creditmemo is null) and 
			(ivh_definition not in ('RBIL') or (bcmp.cmp_edi210 = 3 and ivh_definition = 'RBIL' and 
				(select cmr_reason 
				from creditmemo_reason c, invoiceheader it
				where c.ord_hdrnumber = it.ord_hdrnumber   and
					it.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
					cmr_applyto_invoicenumber = it.ivh_applyto) not in (select * from #rsn)))))
	AND @company in ('UNK', invoiceheader.ivh_company)

	IF @mbcompany_include = 'Y'
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
		refnumber = ivh_ref_number,
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
	 	cmd_code = ISNULL(orderheader.cmd_code,'UNKNOWN'),
		bcmp.cmp_invoicetype,
		ivh_currency,
		IsNull(invoiceheader.tar_tariffitem,''),
		IsNull(invoiceheader.tar_tarriffnumber,''),
		--IsNull(invoiceheader.ivh_ref_number,''),
		IsNull(invoiceheader.ivh_imagestatus,0),
		ivh_definition,
		ivh_applyto,
		IsNull(orderheader.ord_fromorder,''),
		@varchar254 cmp_image_routing1,
		@varchar254 cmp_image_routing2,
		@varchar254 cmp_image_routing3,
	IsNull(ivh_company, 'UNK')   
		FROM invoiceheader LEFT OUTER JOIN orderheader ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber, 
			company bcmp, company scmp, company ccmp 
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
--		AND 	(bcmp.cmp_invoicetype in ('BTH','INV','NONE') )
		AND     ( scmp.cmp_id = invoiceheader.ivh_shipper)
		AND	( ccmp.cmp_id = invoiceheader.ivh_consignee)
--      AND ( orderheader.ord_hdrnumber =* invoiceheader.ord_hdrnumber)
		AND ( invoiceheader.ivh_billdate between @BillDate1 and @BillDate2 )
		AND (@paperworkstatus in ('UNK', invoiceheader.ivh_paperworkstatus ))	
		--(@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
		AND @imagestatus in (0,IsNull(ivh_imagestatus,0))
  		--DPH PTS 23007
		-- PTS 28804 -- BL (start)
--  		AND (@usr_id in ( CASE ivh_user_id2
  		AND (@usr_id in ( CASE isnull(ivh_user_id2, 'NULL')
		-- PTS 28804 -- BL (end)
    		    	  WHEN 'NULL' THEN ivh_user_id1
     		     	   ELSE ivh_user_id2
                    	  END,
		    	  'UNK'))
  		--DPH PTS 23007 
 		and ((@status = 'XFR' and ((invoiceheader.ivh_xferdate between @xfrdate1 and @xfrdate2) 
					or invoiceheader.ivh_xferdate IS null)) or
	 	(@status not in ('XFR') and
			bcmp.cmp_invoicetype in ('BTH','INV', 'MAS') and 
--			(ivh_block_printing = 'N' or ivh_block_printing is null) and 
			(ivh_block_printing in ( 'N', '') or ivh_block_printing is null) and 
			(ivh_creditmemo = 'N' or ivh_creditmemo is null) and 
			(ivh_definition not in ('RBIL') or (bcmp.cmp_edi210 = 3 and ivh_definition = 'RBIL' and 
				(select cmr_reason 
				from creditmemo_reason c, invoiceheader it
				where c.ord_hdrnumber = it.ord_hdrnumber   and
					it.ivh_hdrnumber = invoiceheader.ivh_hdrnumber and
					cmr_applyto_invoicenumber = it.ivh_applyto) not in (select * from #rsn)))))
	AND @company in ('UNK', invoiceheader.ivh_company)
END
-- for RTP masterbills (the invoice selection only allows masterbills
-- requested for RTP status or status = "PRN' with a masterbill#
-- @breakon <> 'Y'

IF @domasterbills = 'Y' and ISNULL(@mbnumber,0) = 0

BEGIN
    IF @status = 'RTP'
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
			   WHEN 'DRPUCMDPO'THEN
			      min(invoiceheader.ivh_consignee)
			   WHEN 'DRCMDPO'THEN
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
	@varchar6 cmp_subcompany,
	@money totallinehaul,
	@int0 negativecharges,
	@int0 edi_210_flag,
	@chary ismasterbill,
	'TrlType3' trltype3name,
	MAX(company.cmp_mastercompany) cmp_mastercompany,
	--@varchar20 refnumber,
	max(ivh_ref_number),
	@char3 cmp_invoiceto,
	@char1 cmp_invprintto,
	@int0  cmp_invformat,
	max(company.cmp_transfertype) cmp_transfertype,
	@Status ivh_Mbstatus,
	@money trp_linehaulmax,
	@money trp_totchargemax,
	max(company.cmp_invcopies) cmp_invcopies,
	max(company.cmp_mbgroup) cmp_mbgroup,
	max(invoiceheader.ivh_originpoint) ivh_originpoint,
	cmd_code = CASE max(company.cmp_mbgroup)
	    		   WHEN 'DRPUCMDPO' THEN
				min(orderheader.cmd_code) 
			   WHEN 'DRCMDPO' THEN
				min(orderheader.cmd_code)
			   WHEN 'PUCMDPO' THEN
				min(orderheader.cmd_code)
			   WHEN 'CMDPO' THEN
				min(orderheader.cmd_code)
                           WHEN 'ORGCMD' THEN  
                                min(orderheader.cmd_code) 
		 	   ELSE 
				'UNKNOWN'
			   END,   
	max(company.cmp_invoicetype) cmp_invoicetype,
	max(ivh_currency),
	max(IsNull(invoiceheader.tar_tariffitem,'')),
	max(IsNull(invoiceheader.tar_tarriffnumber,'')),
	--Max(IsNull(invoiceheader.ivh_ref_number,'')),
	Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
	max(ivh_definition) ivh_definition,
	max(ivh_applyto) ivh_applyto,
	Max(IsNull(orderheader.ord_fromorder,'')),
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	max(IsNull(ivh_company, 'UNK')) 
	--INTO #invview
	FROM invoiceheader LEFT OUTER JOIN orderheader ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber, 
		company  
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
    --AND (orderheader.ord_hdrnumber =* invoiceheader.ord_hdrnumber)
	AND ( dateadd ( day , company.cmp_mbdays , company.cmp_lastmb ) <= @PrintDate ) 
	--AND (  @Status = case @status when 'XFR' then invoiceheader.ivh_invoicestatus else invoiceheader.ivh_mbstatus end)   
	AND (  @Status = invoiceheader.ivh_mbstatus)	
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
	--And (@ivhrefnumber in ('',Isnull(invoiceheader.ivh_ref_number,'')))
	AND @imagestatus in (0,IsNull(ivh_mbimagestatus,0)) 
	AND @company in ('UNK', invoiceheader.ivh_company)
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
                  WHEN 'DRPUPO' then invoiceheader.ivh_billto + invoiceheader.ivh_currency + 
				     isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + 
				     invoiceheader.ivh_consignee 
		  WHEN 'DRPUCMDPO'  then invoiceheader.ivh_billto + invoiceheader.ivh_currency + 
					 isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + 
					 invoiceheader.ivh_consignee + orderheader.cmd_code
		  WHEN 'DRCMDPO' then invoiceheader.ivh_billto + invoiceheader.ivh_currency + 
				      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee + 
				      orderheader.cmd_code
		  WHEN 'PUPO'    then invoiceheader.ivh_billto + invoiceheader.ivh_currency + 
				      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper 
		  WHEN 'PUCMDPO' then invoiceheader.ivh_billto + invoiceheader.ivh_currency + 
				      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_shipper + 
				      orderheader.cmd_code
		  WHEN 'PO'      then invoiceheader.ivh_billto + invoiceheader.ivh_currency +
				      isnull(invoiceheader.tar_tariffitem,'') 
		  WHEN 'CMDPO'   then invoiceheader.ivh_billto + invoiceheader.ivh_currency  + 
				      isnull(invoiceheader.tar_tariffitem,'') + orderheader.cmd_code
		  WHEN 'DRPO'    then invoiceheader.ivh_billto + invoiceheader.ivh_currency  + 
				      isnull(invoiceheader.tar_tariffitem,'') + invoiceheader.ivh_consignee	
		WHEN 'FROMORD' Then invoiceheader.ivh_billto + IsNull(orderheader.ord_fromorder,'')
		  ELSE invoiceheader.ivh_billto
		 END 
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
	max(ivh_tractor) ivh_tractor,
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
	@varchar30 refnumber,
	@char3 cmp_invoiceto,
	@char1 cmp_invprintto,
	@int0  cmp_invformat,
	@varchar6 cmp_transfertype,
	min(invoiceheader.ivh_mbstatus)  ivh_Mbstatus,
	@money trp_linehaulmax,
	@money trp_totchargemax,
	max(company.cmp_invcopies) cmp_invcopies,
	max(company.cmp_mbgroup) cmp_mbgroup,
	max(invoiceheader.ivh_originpoint) ivh_originpoint,
	max(orderheader.cmd_code) orderheader_cmd_code,
	max(company.cmp_invoicetype) cmp_invoicetype,
	max(ivh_currency),
	max(IsNull(invoiceheader.tar_tariffitem,'')),
	max(IsNull(invoiceheader.tar_tarriffnumber,'')),
	--Max(IsNull(invoiceheader.ivh_ref_number,'')),
	Max(IsNull(invoiceheader.ivh_mbimagestatus,0)),
	max(ivh_definition) ivh_definition,
	max(ivh_applyto) ivh_applyto,
	Max(IsNull(orderheader.ord_fromorder,'')),
	@varchar254 cmp_image_routing1,
	@varchar254 cmp_image_routing2,
	@varchar254 cmp_image_routing3,
	max(IsNull(ivh_company, 'UNK')) 
	--INTO #invview
	FROM invoiceheader LEFT OUTER JOIN orderheader ON orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber,
		company 
	WHERE ( company.cmp_id = invoiceheader.ivh_billto )
    --AND (orderheader.ord_hdrnumber =* invoiceheader.ord_hdrnumber)
	AND ( ivh_mbnumber = @mbnumber)
	AND @status = (case @status when 'XFR' then invoiceheader.ivh_invoicestatus else @status end)
	And invoiceheader.ivh_invoicestatus <> (case @status when 'XFR' then ' ' else 'XFR'  end)
End 

UPDATE	#invview
   SET	#invview.cmp_image_routing1 = company.cmp_image_routing1,
		#invview.cmp_image_routing2 = company.cmp_image_routing2,
		#invview.cmp_image_routing3 = company.cmp_image_routing3
  FROM	company
 WHERE	#invview.ivh_billto = company.cmp_id

SELECT * from #invview
GO
GRANT EXECUTE ON  [dbo].[d_invoices_printqueue_qdi_sp] TO [public]
GO
