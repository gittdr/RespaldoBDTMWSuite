SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[invoices_byreferencenbr_sp] ( @searchloc varchar(25),
			@searchref             varchar(35),
			@searchtype          varchar(6),
			@searchfor           varchar(3),
                        @billto              varchar(8))
			
AS

/**
 * NAME:
 * dbo.invoices_byreferencenbr_sp
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * looking up invoices by R (Referencenumber). These queries don't work for ref numbers attached to stops or freight detail
 * not associated with an order.  It will bring back orders which are not yet invoiced (filtered by datawindow), so requestor 
 * knows the ref# exists. 
 * 
 * RETURN:
 * none.
 * 
 * RESULT SETS:
 * Refer the select list. 
 *
 * PARAMETERS:
 * 01 @searchloc 	varchar(25)	
 * 02 @searchref        varchar(35)	
 * 03 @searchtype       varchar(6)
 * 04 @searchfor        varchar(3)
 * 05 @billto           varchar(8)
 * 
 * REFERENCES: (called by and calling references only, don't include table/view/object references)
 * Calls001    ? NONE
 * CalledBy001 ? NONE
 *
 * REVISION HISTORY:
 * PTS 28016 - DPM 08/03/05 - added select to UNION to correcty pull back Splitbill ref numbers where one Order ultimately becomes multiple invoices 
 * 05/01/06 PTS 32758 - JGUO  - rewrite rewrite "@searchtype in ( R.ref_type, '?')" and "@billto in (orderheader.ord_billto,'UNKNOWN')and" 
            in third union's where clause to improve performance
 * 09/21/06 PTS 34196 - EK - Added isinvoiceable column for orders available for invoicing
 * 11/30/2007.01 - PTS40464 - JGUO - convert old style outer join syntax to ansi outer join syntax.
 * 05/06/2011 - PTS 56949 MTC. Added nolocks to all table accesses to prevent this from being blocked
 * 03/23/2012 -- PTS 62139 Changed REFERENCENUMBER to be a global TableVar instead of a direct table join in all queries across unions
 **/

DECLARE			@SplitbillMilkrun char (1),
			@int0  int -- PTS 28016 - DPM 

--DPH PTS 29547
If RTRIM(LTRIM(@searchref)) = ''
	Select @searchref = '%%'
--DPH PTS 29547

SELECT @searchloc = ISNULL(@searchloc,'?')
SELECT @searchtype = ISNULL(@searchtype,'?')

SELECT @SplitbillMilkrun = gi_string1 FROM generalinfo WHERE gi_name = 'SplitbillMilkrun' -- PTS 28016 - DPM

--PTS 62139
DECLARE @Reference TABLE
(ref_tablekey	INT
,ref_type	varchar(6)
,ref_number	varchar(30)
,ref_table	varchar(18))

INSERT INTO @Reference
SELECT ref_tablekey,ref_type,ref_number,ref_table
FROM referencenumber
WHERE ref_number LIKE @searchref
------------------------- Stops reference numbers

SELECT 	orderheader.ord_shipper shipper, 
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
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	R.ref_number refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
        'Stop' tabletype,
	ISNULL(invoiceheader.ivh_invoicenumber,'None') ivh_invoicenumber,
	R.ref_type reftype,	--PTS62139
	stops.cmp_name stopcompanyname,
        stops.stp_city stopcity,
        stopscity.cty_nmstct stopcitynmstct,
	stops.stp_description commodity,
	@searchfor searchfor,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
	,isinvoiceable=case isnull(ord_invoicestatus,'X') WHEN 'AVL' THEN 'Y' ELSE 'N' END
FROM company company_a with (NOLOCK)  RIGHT OUTER JOIN  orderheader with (NOLOCK)  ON  company_a.cmp_id  = orderheader.ord_shipper   
			LEFT OUTER JOIN  company company_b with (NOLOCK)  ON  company_b.cmp_id  = orderheader.ord_consignee   
			LEFT OUTER JOIN  company company_c  with (NOLOCK) ON  company_c.cmp_id  = orderheader.ord_billto ,
	 invoiceheader with (NOLOCK) RIGHT OUTER JOIN  stops with (NOLOCK) ON  invoiceheader.ord_hdrnumber  = stops.ord_hdrnumber ,
	 @Reference R,	--PTS 62139
	 city stopscity with (NOLOCK)
WHERE 	@searchloc in ('?','stops') and
	R.ref_table = 'stops'  and
    R.ref_number like @searchref and 
	@searchtype in ( R.ref_type, '?') and   
    stops.stp_number = R.ref_tablekey and
    stops.ord_hdrnumber > 0 and
	orderheader.ord_hdrnumber = stops.ord_hdrnumber  and 
    @billto in (orderheader.ord_billto,'UNKNOWN') and
--	company_a.cmp_id =* orderheader.ord_shipper and 
--	company_b.cmp_id =* orderheader.ord_consignee and
--	company_c.cmp_id =* orderheader.ord_billto and
    stopscity.cty_code = stops.stp_city 
--  invoiceheader.ord_hdrnumber  =* stops.ord_hdrnumber



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
	orderheader.ord_number ord_number, 
	ISNULL(invoiceheader.ivh_invoicestatus,'None') invoicestatus,  
	orderheader.ord_hdrnumber hdrnumber, 
	orderheader.ord_revtype1 revtype1, 
	orderheader.ord_revtype2 revtype2, 
	orderheader.ord_revtype3 revtype3, 
	orderheader.ord_revtype4 revtype4, 
	orderheader.mov_number movnumber, 
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	R.ref_number refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
        'Freightdetail' tabletype,
	ISNULL(invoiceheader.ivh_invoicenumber,'None') ivh_invoicenumber,
	R.ref_type reftype,
	stops.cmp_name stopcompanyname,
        stops.stp_city stopcity,
        stopscity.cty_nmstct stopcitynmstct,
	freightdetail.fgt_description commodity,
	@searchfor searchfor,
	freightdetail.fgt_bolid -- PTS 28016 - DPM 
	,isinvoiceable=case isnull(ord_invoicestatus,'X') WHEN 'AVL' THEN 'Y' ELSE 'N' END
FROM company company_a with (NOLOCK) RIGHT OUTER JOIN  orderheader with (NOLOCK) ON  company_a.cmp_id  = orderheader.ord_shipper   
			LEFT OUTER JOIN  company company_b with (NOLOCK) ON  company_b.cmp_id  = orderheader.ord_consignee   
			LEFT OUTER JOIN  company company_c with (NOLOCK) ON  company_c.cmp_id  = orderheader.ord_billto ,
	 invoiceheader  with (NOLOCK) RIGHT OUTER JOIN  stops with (NOLOCK) ON  invoiceheader.ord_hdrnumber  = stops.ord_hdrnumber ,
	 freightdetail with (NOLOCK),
	 @Reference R,	--PTS62139
	 city stopscity with (NOLOCK)
WHERE 	@searchloc in ('?','freightdetail') and
	R.ref_table = 'freightdetail'  and
        R.ref_number like @searchref and 
	@searchtype in ( R.ref_type, '?')   and  
	freightdetail.fgt_number = R.ref_tablekey and 
        stops.stp_number = freightdetail.stp_number and
        stops.ord_hdrnumber > 0 and
	orderheader.ord_hdrnumber = stops.ord_hdrnumber    and 
        @billto in (orderheader.ord_billto,'UNKNOWN') and 
--	company_a.cmp_id =* orderheader.ord_shipper and 
--	company_b.cmp_id =* orderheader.ord_consignee and
--	company_c.cmp_id =* orderheader.ord_billto and 
--    invoiceheader.ord_hdrnumber  =* stops.ord_hdrnumber and
    stopscity.cty_code = stops.stp_city and
	@SplitbillMilkrun = 'N' --PTS 28016 - DPM  

 UNION

-- Freightdetail reference numbers related to Splitbilled Invoices

SELECT 	distinct ISNULL(invoiceheader.ivh_shipper,'None') shipper, 
	ISNULL(company_a.cmp_name,'None') shippername, 
	ISNULL(invoiceheader.ivh_consignee,'None') consignee, 
	ISNULL(company_b.cmp_name,'None') consigneename, 
	ISNULL(invoiceheader.ivh_billto,'None') billto,  
	orderheader.ord_company company, 
	ISNULL(company_c.cmp_name,'None') billtoname, 
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
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	R.ref_number refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
        'Freightdetail' tabletype,
	ISNULL(invoiceheader.ivh_invoicenumber,'None') ivh_invoicenumber,
	R.ref_type reftype,
	stops.cmp_name stopcompanyname,
        stops.stp_city stopcity,
        stopscity.cty_nmstct stopcitynmstct,
	freightdetail.fgt_description commodity,
	@searchfor searchfor,
	freightdetail.fgt_bolid -- PTS 28016 - DPM 
	,isinvoiceable=case isnull(ord_invoicestatus,'X') WHEN 'AVL' THEN 'Y' ELSE 'N' END
	from @Reference R --PTS 62139
	join freightdetail with (NOLOCK) on R.ref_tablekey = freightdetail.fgt_number 
	and 	@searchloc in ('?','freightdetail') 
	and 	R.ref_table = 'freightdetail'  
	and 	R.ref_number like @searchref  
	and	@searchtype in ( R.ref_type, '?') 
	and 	@SplitbillMilkrun = 'Y'
	join stops with (NOLOCK) on stops.stp_number = freightdetail.stp_number
	and	stops.ord_hdrnumber > 0 
	join orderheader with (NOLOCK) on orderheader.ord_hdrnumber = stops.ord_hdrnumber
	join city stopscity with (NOLOCK) on stopscity.cty_code = stops.stp_city 
	left outer join invoiceheader with (NOLOCK) on invoiceheader.ivh_hdrnumber = 
(select ih1.ivh_hdrnumber from invoiceheader ih1 with (NOLOCK)	join invoicedetail id with (NOLOCK) on ih1.ivh_hdrnumber = id.ivh_hdrnumber and id.fgt_number = freightdetail.fgt_number)
	and 	@billto in (invoiceheader.ivh_billto,'UNKNOWN') 
	left outer join company company_a with (NOLOCK) on company_a.cmp_id = invoiceheader.ivh_shipper
	left outer join company company_b with (NOLOCK) on company_b.cmp_id = invoiceheader.ivh_consignee
	left outer join company company_c with (NOLOCK) on company_c.cmp_id = invoiceheader.ivh_billto
			
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
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	R.ref_number refnumber, 
	'RevType1'hrevtype1,
	'RevType2' hrevtype2,
	'RevType3' hrevtype3,
	'RevType4' hrevtype4,
	'Order' tabletype ,
	ISNULL(invoiceheader.ivh_invoicenumber,'None') ivh_invoicenumber,
	R.ref_type reftype ,
	'ANY' stopcompanyname,
        0 stopcitynmstct,
        'ANY' stopcitynmstct,
	commodity =  CASE  ord_rateby
           WHEN 'T' THEN ord_description
           WHEN 'D' THEN 'ANY'
           END ,
        @searchfor searchfor,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
	,isinvoiceable=case isnull(ord_invoicestatus,'X') WHEN 'AVL' THEN 'Y' ELSE 'N' END
FROM invoiceheader with (NOLOCK) RIGHT OUTER JOIN  @Reference R ON  invoiceheader.ord_hdrnumber  = R.ref_tablekey ,
	 company company_a  with (NOLOCK) RIGHT OUTER JOIN  orderheader with (NOLOCK) ON  company_a.cmp_id  = orderheader.ord_shipper   
			LEFT OUTER JOIN  company company_b  with (NOLOCK) ON  company_b.cmp_id  = orderheader.ord_consignee   
			LEFT OUTER JOIN  company company_c with (NOLOCK)  ON  company_c.cmp_id  = orderheader.ord_billto  
WHERE	@searchloc in ('?','orderheader') and
	R.ref_table = 'orderheader'  and
        R.ref_number LIKE @searchref and 
	--jg begin
	(R.ref_type = @searchtype or @searchtype  = '?') and
	--@searchtype in ( R.ref_type, '?')  and  
	--jg end 
        orderheader.ord_hdrnumber = R.ref_tablekey   and 
	--jg begin
	(orderheader.ord_billto = @billto or @billto  = 'UNKNOWN') 
        --@billto in (orderheader.ord_billto,'UNKNOWN')and
	--jg end
--  invoiceheader.ord_hdrnumber =* R.ref_tablekey  and
--	company_a.cmp_id =* orderheader.ord_shipper and 
--	company_b.cmp_id =* orderheader.ord_consignee and
--	company_c.cmp_id =*  orderheader.ord_billto

-- iNVOICEHEADER REFERENCE NUMBERS

UNION 
SELECT 	invoiceheader.ivh_shipper shipper, 
	company_a.cmp_name shippername, 
	invoiceheader.ivh_consignee consignee, 
	company_b.cmp_name consigneename, 
	invoiceheader.ivh_billto billto, 
	'' company, 
	company_c.cmp_name billtoname, 
	invoiceheader.ivh_shipdate shipdate, 
	invoiceheader.ivh_deliverydate deliverydate, 
	invoiceheader.ord_number ord_number, 
	invoiceheader.ivh_invoicestatus invoicestatus,
	0 hdrnumber, 
	invoiceheader.ivh_revtype1 revtype1, 
	invoiceheader.ivh_revtype2 revtype2, 
	invoiceheader.ivh_revtype3 revtype3, 
    	invoiceheader.ivh_revtype3 revtype4, 
	invoiceheader.mov_number movnumber, 
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	R.ref_number refnumber, 
	'RevType1'hrevtype1 ,
	'RevType2' hrevtype2 ,
	'RevType3' hrevtype3 ,
	'RevType4' hrevtype4 ,
	'Invoice' tabletype,
	invoiceheader.ivh_invoicenumber ivh_invoicenumber,
	R.ref_type reftype ,
	'ANY' stopcompanyname,
        0 stopcity,
        'ANY' stopcitynmstct,
	'ANY' commodity ,

	@searchfor,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
	,isinvoiceable= 'N'
FROM 
	company company_a  with (NOLOCK) RIGHT OUTER JOIN  invoiceheader with (NOLOCK) ON  company_a.cmp_id  = invoiceheader.ivh_shipper   
		LEFT OUTER JOIN  company company_b with (NOLOCK) ON  company_b.cmp_id  = invoiceheader.ivh_consignee   
		LEFT OUTER JOIN  company company_c  with (NOLOCK) ON  company_c.cmp_id  = invoiceheader.ivh_billto ,
	 @Reference R
WHERE 	@searchloc in ('?','invoiceheader') and
	R.ref_table = 'invoiceheader'  and
        R.ref_number LIKE @searchref and
	@searchtype in ( R.ref_type, '?') and   
        invoiceheader.ivh_hdrnumber = R.ref_tablekey   and 
        @billto in (invoiceheader.ivh_billto,'UNKNOWN')
--	company_a.cmp_id =* invoiceheader.ivh_shipper and 
--	company_b.cmp_id =* invoiceheader.ivh_consignee and
--	company_c.cmp_id =*  invoiceheader.ivh_billto

-- INVOICEDETAIL REFERENCE NUMBERS (for misc invoices only)
-- May take a long time, so it is only done if only misc invoice search is selected

UNION 
SELECT 	invoiceheader.ivh_shipper shipper, 
	company_a.cmp_name shippername, 
	invoiceheader.ivh_consignee consignee, 
	company_b.cmp_name consigneename, 
	invoiceheader.ivh_billto billto, 
	'' company, 
	company_c.cmp_name billtoname, 
	invoiceheader.ivh_shipdate shipdate, 
	invoiceheader.ivh_deliverydate deliverydate, 
	invoiceheader.ord_number ord_number, 
	invoiceheader.ivh_invoicestatus invoicestatus,
	0 hdrnumber, 
	invoiceheader.ivh_revtype1 revtype1, 
	invoiceheader.ivh_revtype2 revtype2, 
	invoiceheader.ivh_revtype3 revtype3, 
    	invoiceheader.ivh_revtype3 revtype4, 
	invoiceheader.mov_number movnumber, 
	invoiceheader.ivh_totalcharge totalcharge, 
	company_a.cty_nmstct shippercity, 
	company_b.cty_nmstct consigneecity, 
	invoicedetail.ivd_refnum refnumber, 
	'RevType1'hrevtype1 ,
	'RevType2' hrevtype2 ,
	'RevType3' hrevtype3 ,
	'RevType4' hrevtype4 ,
	'Invoice' tabletype,
	invoiceheader.ivh_invoicenumber ivh_invoicenumber,
	invoicedetail.ivd_reftype reftype ,
	'ANY' stopcompanyname,
        0 stopcity,
        'ANY' stopcitynmstct,
	'ANY' commodity ,

	@searchfor,
	@int0 'fgt_bolid' -- PTS 28016 - DPM
	,isinvoiceable= 'N'
FROM 	company company_a  with (NOLOCK) RIGHT OUTER JOIN  invoiceheader with (NOLOCK) ON  company_a.cmp_id  = invoiceheader.ivh_shipper   
			LEFT OUTER JOIN  company company_b with (NOLOCK) ON  company_b.cmp_id  = invoiceheader.ivh_consignee   
			LEFT OUTER JOIN  company company_c with (NOLOCK) ON  company_c.cmp_id  = invoiceheader.ivh_billto ,
	 invoicedetail with (NOLOCK)
WHERE 	@searchloc in ('?','invoiceheader') and
        invoicedetail.ord_hdrnumber = 0 and
        invoicedetail.ivd_refnum like @searchref and
	@searchtype in ( invoicedetail.ivd_reftype, '?') and   
        invoiceheader.ivh_hdrnumber = invoicedetail.ivh_hdrnumber   and 
        @billto in (invoiceheader.ivh_billto,'UNKNOWN')
--	company_a.cmp_id =* invoiceheader.ivh_shipper and 
--	company_b.cmp_id =* invoiceheader.ivh_consignee and
--	company_c.cmp_id =*  invoiceheader.ivh_billto

GO
GRANT EXECUTE ON  [dbo].[invoices_byreferencenbr_sp] TO [public]
GO
