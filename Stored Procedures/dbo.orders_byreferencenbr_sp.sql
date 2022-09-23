SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object: orders_byreferencenbr_sp   Script Date: 12/13/99 10:30:12 PM ******/

create proc [dbo].[orders_byreferencenbr_sp] 
			(@searchloc varchar(25), 
			@searchref             varchar(35),
			@searchtype          varchar(6),
			@searchfor           varchar(3),
                        @billto              varchar(8))
AS

/*
 * NAME:
 * dbo.orders_byreferencenbr_sp
 *
 * TYPE:
 * Stored Procedure
 *
 * 
 * REVISION HISTORY:
 * PTS 28420 - DJM - 1/26/06 - Update joins to be ANSI compliant and removed Index
 *	hints.
 * PTS 42919 SGB 06/12/08 Removed Stops and Freight reference restrictions on ord_hdrnumber > 0
*/

DECLARE @int0  int -- PTS 28016 - DPM

Create Table #TempRef
	(
		Tsearchref              varchar(30) NULL,
		Tsearchtype          	char(6) NULL,
		Tsearchloc 		varchar(18) NULL,
		ref_tablekey		int --sp_help referencenumber
	)
CREATE INDEX Temp_idx  ON  #TempRef (Tsearchref, Tsearchtype)

SELECT @searchloc = ISNULL(@searchloc,'?')
SELECT @searchtype = ISNULL(@searchtype,'?')

--DPH PTS 29547
If LTrim(RTrim(@searchref)) = ''
	Select @searchref = '%%'
--DPH PTS 29547

CREATE TABLE #TempOrderRef
   (shipper				varchar(8), 
	shippername			varchar(100), 
	consignee			varchar(8), 
	consigneename		varchar(100), 
	billto				varchar(8), 
	company				varchar(8), 
	billtoname			varchar(100), 
	shipdate			datetime, 
	deliverydate		datetime, 
	ord_number			varchar(12), 
	ivh_invoicestatus	varchar(6), 
	hdrnumber			INT, 
	revtype1			varchar(6), 
	revtype2			varchar(6), 
	revtype3			varchar(6), 
	revtype4			varchar(6), 
	movnumber			INT, 
	totalcharge			DECIMAL(10,4), 
	shippercity			varchar(25), 
	consigneecity		varchar(25), 
	refnumber			varchar(30), 
	hrevtype1			varchar(8),
	hrevtype2			varchar(8),
	hrevtype3			varchar(8),
	hrevtype4			varchar(8),
    tabletype			varchar(13),
	ivh_invoicenumber	varchar(12),
	reftype				varchar(6),
	stopcompanyname		varchar(30),
    stopcity			INT,
    stopcitynmstct		varchar(30),
	commodity			varchar(64),
	searchfor			varchar(3),
	ord_status			varchar(6),
	fgt_bolid			INT
)

Set rowcount 1000

Insert into #TempRef
	Select 
		ref_number,
		ref_type,
		ref_table,
		ref_tablekey
	From
		referencenumber (nolock)
	where
		ref_number like @searchref
		and
		(
		@searchtype ='?'
		or
		ref_type=@searchtype			 
		)
		and
		(
		@searchloc='?'
		or
		ref_table=@searchloc
		)
		
Set rowcount 0
	




INSERT INTO #TempOrderRef
-------------- Stops reference numbers
SELECT 	orderheader.ord_shipper shipper, 
	company_a.cmp_name shippername, 
	orderheader.ord_consignee consignee, 
	company_b.cmp_name consigneename, 
	orderheader.ord_billto billto, 
	orderheader.ord_company company, 
	company_c.cmp_name billtoname, 
	orderheader.ord_startdate shipdate, 
	orderheader.ord_completiondate deliverydate, 
	ISNULL(orderheader.ord_number, 0) ord_number, --PTS 42919 SGB 06/12/08 added isnull
	ISNULL(ivh_invoicestatus,'None') ivh_invoicestatus, 
	orderheader.ord_hdrnumber hdrnumber, 
	orderheader.ord_revtype1 revtype1, 
	orderheader.ord_revtype2 revtype2, 
	orderheader.ord_revtype3 revtype3, 
	orderheader.ord_revtype4 revtype4, 
	stops.mov_number movnumber, 
	orderheader.ord_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	#TempRef.Tsearchref refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
        'Stop' tabletype,
	ISNULL(ivh_invoicenumber,'NONE') ivh_invoicenumber,
	#TempRef.Tsearchtype reftype,
	stops.cmp_name stopcompanyname,
        stops.stp_city stopcity,
        stopscity.cty_nmstct stopcitynmstct,
	stops.stp_description commodity,
	@searchfor searchfor,
	orderheader.ord_status,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
FROM 	#TempRef inner join stops on stops.stp_number = #TempRef.ref_tablekey 
	--PTS 42919 SGB 06/12/08 
	--inner join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
	left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
	left outer join company company_a on orderheader.ord_shipper = company_a.cmp_id
	left outer join company company_b on orderheader.ord_consignee = company_b.cmp_id
	left outer join company company_c on orderheader.ord_billto = company_c.cmp_id
	inner join city stopscity on stopscity.cty_code = stops.stp_city
	left outer join invoiceheader 
		on (orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
		    and invoiceheader.ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)) 
WHERE #TempRef.Tsearchref like @searchref 
	AND (@searchtype='?' OR	#TempRef.Tsearchtype = @searchtype)
	AND #TempRef.Tsearchloc='stops'		
    --PTS 42919 SGB 06/12/08 
    --AND stops.ord_hdrnumber > 0 
    AND @billto in (orderheader.ord_billto,'UNKNOWN') 
	--PTS 38816 JJF 20080312 add additional needed parms
    --AND dbo.RowRestrictByUser (orderheader.ord_belongsto, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
    AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
                                       
-- Freightdetail reference numbers
UNION
SELECT 	orderheader.ord_shipper shipper, 
	company_a.cmp_name shippername, 
	orderheader.ord_consignee consignee, 
	company_b.cmp_name consigneename, 
	orderheader.ord_billto billto, 
	orderheader.ord_company company, 
	company_c.cmp_name billtoname, 
	orderheader.ord_startdate shipdate, 
	orderheader.ord_completiondate deliverydate, 
	ISNULL(orderheader.ord_number, 0) ord_number, --PTS 42919 SGB 06/12/08 added isnull
	ISNULL(invoiceheader.ivh_invoicestatus,'None') invoicestatus,  
	orderheader.ord_hdrnumber hdrnumber, 
	orderheader.ord_revtype1 revtype1, 
	orderheader.ord_revtype2 revtype2, 
	orderheader.ord_revtype3 revtype3, 
	orderheader.ord_revtype4 revtype4, 
	stops.mov_number movnumber, 
	orderheader.ord_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	#TempRef.Tsearchref refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
        'Freightdetail' tabletype,
	ISNULL(ivh_invoicenumber,'NONE') ivh_invoicenumber,
	#TempRef.Tsearchtype reftype,
	stops.cmp_name stopcompanyname,
        stops.stp_city stopcity,
        stopscity.cty_nmstct stopcitynmstct,
	freightdetail.fgt_description commodity,
	@searchfor searchfor,
	orderheader.ord_status,
	freightdetail.fgt_bolid -- PTS 28016 - DPM
FROM freightdetail inner join #TempRef on freightdetail.fgt_number = #TempRef.ref_tablekey 
	inner join stops on stops.stp_number = freightdetail.stp_number
	--PTS 42919 SGB 06/12/08 
	--inner join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
	left outer join orderheader on stops.ord_hdrnumber = orderheader.ord_hdrnumber
	left outer join company company_a on orderheader.ord_shipper = company_a.cmp_id
	left outer join company company_b on orderheader.ord_consignee = company_b.cmp_id
	left outer join company company_c on orderheader.ord_billto = company_c.cmp_id
	inner join city stopscity on stopscity.cty_code = stops.stp_city
	left outer join invoiceheader 
		on (orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
		    and invoiceheader.ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)) 
WHERE #TempRef.Tsearchref like @searchref 
	AND (@searchtype='?' OR #TempRef.Tsearchtype = @searchtype)
	AND #TempRef.Tsearchloc='freightdetail'	
    --PTS 42919 SGB 06/12/08
    --AND stops.ord_hdrnumber > 0
    AND @billto in (orderheader.ord_billto,'UNKNOWN') 
	--PTS 38816 JJF 20080312 add additional needed parms
	--PTS 51570 JJF 20100510
    --AND dbo.RowRestrictByUser (orderheader.ord_belongsto, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
    AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
				
-- Ordrheader reference numbers		
UNION 
SELECT	orderheader.ord_shipper shipper, 
	company_a.cmp_name shippername, 
	orderheader.ord_consignee consignee, 
	company_b.cmp_name consigneename, 
	orderheader.ord_billto billto, 
	orderheader.ord_company company, 
	company_c.cmp_name billtoname, 
	orderheader.ord_startdate shipdate, 
	orderheader.ord_completiondate deliverydate, 
	orderheader.ord_number ord_number, 
	ISNULL(invoiceheader.ivh_invoicestatus,'None') invoicestatus, 
	orderheader.ord_hdrnumber hdrnumber, 
	orderheader.ord_revtype1 revtype1, 
	orderheader.ord_revtype2 revtype2, 
	orderheader.ord_revtype3 revtype3, 
	orderheader.ord_revtype4 revtype4, 
	orderheader.mov_number movnumber, 
	orderheader.ord_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	#TempRef.Tsearchref refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
	'Order' tabletype ,
	ISNULL(ivh_invoicenumber,'NONE') ivh_invoicenumber,
	#TempRef.Tsearchtype reftype ,
	'ANY' stopcompanyname,
        0 stopcitynmstct,
        'ANY' stopcitynmstct,
	commodity =  CASE  ord_rateby
           WHEN 'T' THEN ord_description
           WHEN 'D' THEN 'ANY'
           END ,
        @searchfor searchfor,
	orderheader.ord_status,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
FROM 	orderheader inner join #TempRef on orderheader.ord_hdrnumber = #TempRef.ref_tablekey 
	left outer join company company_a on orderheader.ord_shipper = company_a.cmp_id
	left outer join company company_b on orderheader.ord_consignee = company_b.cmp_id
	left outer join company company_c on orderheader.ord_billto = company_c.cmp_id
	left outer join invoiceheader 
		on (orderheader.ord_hdrnumber = invoiceheader.ord_hdrnumber 
		    and invoiceheader.ivh_hdrnumber = (select min(ivh_hdrnumber) from invoiceheader where invoiceheader.ord_hdrnumber = orderheader.ord_hdrnumber)) 
WHERE	#TempRef.Tsearchref like @searchref 
	AND (@searchtype='?' OR	#TempRef.Tsearchtype = @searchtype)
	AND #TempRef.Tsearchloc='orderheader'	
    AND @billto in (orderheader.ord_billto,'UNKNOWN')
	--PTS 38816 JJF 20080312 add additional needed parms
	--PTS 51570 JJF 20100510
    --AND dbo.RowRestrictByUser (orderheader.ord_belongsto, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
    AND dbo.RowRestrictByUser('orderheader', orderheader.rowsec_rsrv_id, '', '', '') = 1	-- 11/28/2007 MDH PTS 40119: Added
order by Tsearchref

	
	--****@searchloc in ('?','orderheader') and
	--****referencenumber.ref_table = 'orderheader'  and
        --****referencenumber.ref_number LIKE @searchref and 
	--****@searchtype in ( referencenumber.ref_type, '?')  and   
        --****orderheader.ord_hdrnumber = referencenumber.ref_tablekey   and 
        --****@billto in (orderheader.ord_billto,'UNKNOWN')and
	--****company_a.cmp_id =* orderheader.ord_shipper and 
	--****company_b.cmp_id =* orderheader.ord_consignee and
	--****company_c.cmp_id =*  orderheader.ord_billto and
        --****invoiceheader.ivh_hdrnumber  =* (
        --****        SELECT MIN(ivh_hdrnumber) FROM invoiceheader
        --****        Where ord_hdrnumber =* referencenumber.ref_tablekey
        --****  

SELECT * FROM #TempOrderRef


GO
GRANT EXECUTE ON  [dbo].[orders_byreferencenbr_sp] TO [public]
GO
