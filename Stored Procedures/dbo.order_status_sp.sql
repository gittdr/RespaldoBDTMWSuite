SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[order_status_sp]( @delstart datetime,@delend datetime,
			      @revtype1 varchar(6),
			      @status0 char,@status1 char, @status2 char,
			      @status3 char, @status4 char, @status5 char,
				@status6 char, @status10 char,@batchid varchar(10),
				@revtype2 varchar(6),@revtype3 varchar(6),@revtype4 varchar(6),
				@xferdatefrom datetime, @xferdateto datetime) 
as

declare @varchar30 varchar(30),@varchar25 varchar(25),
	@money money, @varchar8 varchar(8),@varchar12 varchar(12),
	@varchar6 varchar(6),@int int, @char char, @ordstat1 varchar(6),
	@ordstat2 varchar(6), @ordinvstat1 varchar(6), @ordinvstat2 varchar(6),

	@statusstring varchar(15), @loopcount int, @reportstatus int
SELECT 	@int = 0
SELECT  @reportstatus = 99 

CREATE TABLE #biglist (
	ord_hdrnumber int null,
	ord_status varchar(6) null,
	ord_invoicestatus varchar(6) null,
	ivh_invoicestatus varchar(6) null,
	ivh_hdrnumber int null,
	ivh_batch_id varchar(10) null,
	reportstatus int null,
	ivh_mbstatus varchar(6) null
	)

-- build a list of candidate orders limited only by dates and terminal
-- if there are more than one invoice for an order multiple records are returned
-- note - leaves out quotes and masterbills and exotic statuses
--       if there is a batch id specified, we know we have invoice records

if @batchid is not null and
   @batchid <> 'ALL' and
   @batchid > '' 
   

	INSERT INTO #biglist
	SELECT  ord.ord_hdrnumber,
		ord_status,
		ord_invoicestatus,
		ivh_invoicestatus,
		ivh_hdrnumber,
		ivh_batch_id,
		@int reportstatus,
		ivh_mbstatus
	--INTO	#biglist
	FROM	orderheader ord, invoiceheader ivh
	WHERE	ord.ord_status in ('CMP','ICO')
		AND	ord.ord_invoicestatus in ('PPD','HLD','PRN','PRO','XFR','RTP')
		AND	ord_completiondate between @delstart AND @delend
		/* PTS 26794 (recode 21776) -- allow for null xferdate	*/
		AND  	((ivh_xferdate between @xferdatefrom AND @xferdateto) or ivh_xferdate is null)
		AND	@revtype1 in ('UNK',ord_revtype1)
		AND	ivh.ord_hdrnumber = ord.ord_hdrnumber
--		AND	ISNULL(ivh.ivh_creditmemo ,'N') = 'N'
		AND	ivh_batch_id IS NOT NULL
		AND     ivh_batch_id = @batchid 
		AND	@revtype2 in ('UNK',ord_revtype2)
		AND	@revtype3 in ('UNK',ord_revtype3)
		AND	@revtype4 in ('UNK',ord_revtype4)
	ORDER BY ord.ord_hdrnumber

if @BATCHID is null OR
   @BATCHID = 'ALL' OR
   @BATCHID = '' 
	BEGIN
	INSERT INTO #biglist
	SELECT  ord.ord_hdrnumber,
		ord_status,
		ord_invoicestatus,
		ivh_invoicestatus,
		ivh_hdrnumber,
		ivh_batch_id,
		@int reportstatus,
		ivh_mbstatus
	--INTO	#biglist
	FROM	invoiceheader ivh RIGHT OUTER JOIN orderheader ord ON ivh.ord_hdrnumber = ord.ord_hdrnumber
	WHERE	ord.ord_status in ('AVL','CAN','PLN','DSP','STD','CMP','ICO')
		AND	ord_completiondate between @delstart AND @delend
		/* PTS 26794 (recode 21776) -- allow for null xferdate	*/
		AND  	((ivh_xferdate between @xferdatefrom AND @xferdateto) or ivh_xferdate is null)
		AND	@revtype1 in ('UNK',ord_revtype1)
		--AND	ivh.ord_hdrnumber =* ord.ord_hdrnumber
--		AND	ISNULL(ivh.ivh_creditmemo ,'N') = 'N'
		AND	@revtype2 in ('UNK',ord_revtype2)
		AND	@revtype3 in ('UNK',ord_revtype3)
		AND	@revtype4 in ('UNK',ord_revtype4)
	ORDER BY ord.ord_hdrnumber

	END

-- Set the report status from the information on the big list
------- Cancelled orders
UPDATE #biglist
SET	reportstatus = 0
WHERE	ord_status = 'CAN' 
------- New/not dispatched orders (XIN is do not invoice)
UPDATE #biglist
SET	reportstatus = 1
WHERE	ord_status = 'AVL' 
AND	ord_invoicestatus in ('PND','XIN','RTP')
------- Dispatched orders
UPDATE #biglist
SET	reportstatus = 2
WHERE	(ord_status = 'PLN' OR ord_status = 'DSP')
AND	ord_invoicestatus in ('PND','XIN','RTP')
------- Trip in progress orders
UPDATE #biglist
SET	reportstatus = 3
WHERE	ord_status = 'STD' 
AND	ord_invoicestatus in ('PND','AVL','XIN','RTP')
------- Trip completed/not invoiced orders (ICO is cancelled but invoice)
UPDATE #biglist
SET	reportstatus = 4
WHERE	ord_status in ('CMP','ICO')
AND	ord_invoicestatus in ('AVL','PND','RTP')
------- Order in billing
UPDATE #biglist
SET	reportstatus = 5
WHERE	ord_status in ( 'CMP','ICO') 
AND	ord_invoicestatus = 'PPD'
AND	ivh_invoicestatus <> 'XFR'
--DPH PTS 27834 6/8/05
AND	IsNull(ivh_mbstatus,'') <> 'XFR'
--DPH PTS 27834 6/8/05
------- Order transferred to A/R
UPDATE #biglist
SET	reportstatus = 6
WHERE	ord_status  in ( 'CMP','ICO') 
AND	ord_invoicestatus = 'PPD'
AND	ivh_invoicestatus = 'XFR'
------- Order completed - marked do not invoice
UPDATE #biglist
SET	reportstatus = 10
WHERE	ord_status = 'CMP' 
AND	ord_invoicestatus = 'XIN'

-- Now remove any orders which where notin the statuses requested.
If ISNULL(@status0,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 0
If ISNULL(@status1,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 1
If ISNULL(@status2,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 2
If ISNULL(@status3,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 3
If ISNULL(@status4,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 4
If ISNULL(@status5,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 5
If ISNULL(@status6,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 6
If ISNULL(@status10,'N') = 'N'
	DELETE FROM #biglist WHERE reportstatus = 10


-- Now that we have our list of orders, pick up the rest of the information

SELECT	b.ord_hdrnumber,
	o.ord_number,
	b.reportstatus,
	o.mov_number,
	o.ord_originpoint,
	o.ord_destpoint,
	b.ord_status,
	b.ord_invoicestatus,
	o.ord_revtype1,
	'RevType1' revtype1name,
	ISNULL(i.ivh_shipdate,o.ord_startdate) shipdate,
	ISNULL(i.ivh_deliverydate,o.ord_completiondate) deliverydate ,
	o.ord_billto,
	bcmp.cmp_name billtoname,
	scmp.cmp_name shippername,
	scty.cty_nmstct shippernmstct,
	ccmp.cmp_name consigneename,
	ccty.cty_nmstct consigneenmstct, 
	b.ivh_hdrnumber,
	ISNULL(i.ivh_invoicenumber,'') ivhinvoicenumber,
	ISNULL(i.ivh_invoicestatus,'') ivhinvoicestatus,
	ISNULL(i.ivh_mbstatus,'') ivhmbstatus,
	ISNULL(i.ivh_totalcharge,0.00) ivhtotalcharge,
	@int	laststpnumber,
	@int	lastlghnumber,
	@varchar6	lastlghoutstatus,
	@varchar8	lastlghdriver,
	@varchar8	lastlghtractor,
	@varchar8	lastlghtrailer,
	@int		missingpaperworkcount,
	@int	stpordmiles,
	@int	triploadmiles,
	@int	tripuloadmiles,
	i.ivh_batch_id,
	o.ord_revtype2,
	'RevType2' revtype2name,
	o.ord_revtype3,
	'RevType3' revtype3name,
	o.ord_revtype4,
	'RevType4' revtype4name
INTO	#ostat
FROM 	invoiceheader i  RIGHT OUTER JOIN  #biglist b  ON  i.ivh_hdrnumber  = b.ivh_hdrnumber ,
	 orderheader o,
	 company bcmp,
	 company scmp,
	 company ccmp,
	 city ccty,
	 city scty 
WHERE	o.ord_hdrnumber = b.ord_hdrnumber
--AND	i.ivh_hdrnumber =* b.ivh_hdrnumber
AND	bcmp.cmp_id = o.ord_billto
AND	scmp.cmp_id = o.ord_originpoint
AND	scty.cty_code = o.ord_origincity
AND	ccmp.cmp_id = o.ord_destpoint
AND	ccty.cty_code = o.ord_destcity


-- sum the order miles
UPDATE	#ostat
SET	stpordmiles = (SELECT SUM(ISNULL(stp_ord_mileage,0))
			FROM	stops
			WHERE	stops.ord_hdrnumber = #ostat.ord_hdrnumber
			)


-- sum the loaded miles for the trip (may include other orders
UPDATE	#ostat
SET	triploadmiles = (SELECT SUM(ISNULL(stp_lgh_mileage,0))
			FROM	stops
			WHERE	stops.mov_number = #ostat.mov_number
			AND	stp_loadstatus = 'LD'	
			)

/* JLB PTS 29550  Correcly sum MT miles if the status
-- sum the unloaded miles for the entire trip 
UPDATE	#ostat
SET	tripuloadmiles = (SELECT SUM(ISNULL(stp_lgh_mileage,0))
			FROM	stops
			WHERE	stops.mov_number = #ostat.mov_number
			AND	(stops.stp_loadstatus IS NULL
				OR
				 stops.stp_loadstatus = 'MT')
			)
*/
UPDATE	#ostat
SET	tripuloadmiles = (SELECT SUM(ISNULL(stp_lgh_mileage,0))
			FROM	stops
			WHERE	stops.mov_number = #ostat.mov_number
			AND	Isnull(stops.stp_loadstatus, 'MT') <> 'LD'
			)
--end 29550			
			
			

-- determine the stp_number and lgh_number of the last leg of the trip

UPDATE #ostat
SET		laststpnumber = stp_number,
		lastlghnumber = lgh_number
FROM	#ostat, stops
WHERE	stops.mov_number = #ostat.mov_number
AND	stp_sequence = (SELECT max(stp_sequence)
			FROM stops
			WHERE mov_number = #ostat.mov_number
			AND  stops.ord_hdrnumber = #ostat.ord_hdrnumber)

UPDATE #ostat
SET	lastlghoutstatus = lgh_outstatus,
	lastlghdriver = lgh_driver1,
	lastlghtractor = lgh_tractor,
	lastlghtrailer = lgh_primary_trailer
FROM	legheader, #ostat
WHERE	legheader.lgh_number = lastlghnumber

-- check for any missing paperwork
UPDATE #ostat
SET	missingpaperworkcount = (SELECT COUNT(*)
			FROM	paperwork
			WHERE	paperwork.ord_hdrnumber = #ostat.ord_hdrnumber
			AND	pw_received = 'N')
UPDATE #ostat
SET	missingpaperworkcount = 1
FROM    #ostat
WHERE	missingpaperworkcount > 0

	
select * from #ostat



GO
GRANT EXECUTE ON  [dbo].[order_status_sp] TO [public]
GO
