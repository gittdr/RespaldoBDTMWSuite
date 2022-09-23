SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create proc [dbo].[estatCSRpt_sp]	
	@login 			varchar(132),   -- 40655	
	@pdtm_from_date		datetime = '4/1/97',
	@pdtm_to_date		datetime = '6/3/97',
	@pc_whichone		char (1) = 'O',
	@pc_divisionlvl		char(1) = 'N',
	@pi_latemincutoff	int = 30,
	@pi_earlymincutoff	int = 15
	
	
AS
SET NOCOUNT ON

-- 6/12/07: 37750: Crossdock support
-- 6/15/06: 33393 quick admin

CREATE TABLE #temp1 (ord_number char(12), ord_hdrnumber int)

DECLARE @loadstops int, @unloadstops int
DECLARE @totalorders int, @ordersearly int, @orderslate int, @ordersontime int

Create table #usercompanies (cmp_id varchar(8) not null) 
-- build a list of candidate orders limited only by dates and customer id.
-- note - leaves out quotes and masterbills and exotic statuses
--       if there is a batch id specified, we know we have invoice records
insert into #usercompanies select cmp_id from estatusercompanies where login = @login

/*---------------------------------------------------------------
 Use the @pc_whichone parm to determine if company selection is 
   made on bill to, shipper, consignee or order by.  Use the
   @pc_divisionlvl parm to determine if company selection should
   be made from 'master' companies to do division level reporting
-----------------------------------------------------------------*/ 
	
IF
 (@pc_whichone = 'S'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_shipper in (select cmp_id from #usercompanies) AND 
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'O'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_company in (select cmp_id from #usercompanies)  AND 
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'B'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_billto in (select cmp_id from #usercompanies) AND 
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'C'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_consignee in (select cmp_id from #usercompanies)  AND 
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'O' AND @pc_divisionlvl = 'Y')
	INSERT INTO #temp1  
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany in (select cmp_id from #usercompanies) AND 
		orderheader.ord_company = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
		
ELSE IF (@pc_whichone = 'S' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany in (select cmp_id from #usercompanies) AND 
		orderheader.ord_shipper = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
ELSE IF (@pc_whichone = 'B' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany in (select cmp_id from #usercompanies) AND 
		orderheader.ord_billto = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
ELSE IF (@pc_whichone = 'C' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany in (select cmp_id from #usercompanies) AND 
		orderheader.ord_consignee = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
ELSE 	INSERT INTO #temp1 
	SELECT '',0
	FROM 	orderheader
	WHERE 	0 = 1

SELECT t.ord_number,
	s.stp_event,
	c.cmp_name,
	y.cty_nmstct,
	s.stp_arrivaldate,
	s.stp_schdtearliest,
	s.stp_schdtlatest,
	s.stp_sequence,
	s.mfh_number,  --37750
	s.stp_refnum,
	s.stp_reftype,
	(datediff(minute,s.stp_schdtlatest,s.stp_arrivaldate) - @pi_latemincutoff) 
		minuteslate,
	(datediff(minute,s.stp_arrivaldate,s.stp_schdtearliest) - @pi_earlymincutoff)
		minutesearly,
	l.name,
	l.code,
	@pi_earlymincutoff ecut,
	@pi_latemincutoff lcut,
	-- loadorunload =                     -- 37750 stp_type = none when event is XDL or SDU 
	--   CASE s.stp_type	       -- estat does not use the loadorunload field. 	
            --   WHEN 'PUP' THEN 'L'
            --   ELSE 'U'
           --    END,
	total_loadstops = 0,
	total_unloadstops = 0,
	s.ord_hdrnumber,
	total_orders = 0,
	orders_late = 0,
	orders_early = 0,
	Order_early_flag = 0,
	order_late_flag = 1,
	orders_ontime = 0
INTO #temp2

FROM #temp1 t
  join stops s on t.ord_hdrnumber = s.ord_hdrnumber
  left outer join labelfile l on s.stp_reasonlate = l.abbr and l.labeldefinition = 'ReasonLate'
  left outer join company c on s.cmp_id = c.cmp_id
  left outer join city y on s.stp_city = y.cty_code 
WHERE 	(s.stp_type in ('PUP','DRP') or s.stp_event in ('XDL','XDU') ) --AND -- 37750 
	
	

 SELECT @totalorders  = (SELECT COUNT(DISTINCT ord_number)
 FROM #temp2)

 SELECT @orderslate  = (SELECT COUNT(DISTINCT ord_number)
			FROM #temp2
			WHERE minuteslate > 0 ) 
 SELECT @ordersearly  = (SELECT COUNT(DISTINCT ord_number)
			FROM #temp2
			WHERE minutesearly > 0 ) 

 -- 37750 SET @loadstops = (SELECT COUNT(*) from #temp2 WHERE loadorunload = 'L')
 -- 37750 set @unloadstops = (SELECT COUNT(*) FROM #temp2 WHERE loadorunload = 'U')

 SELECT ord_hdrnumber, max(minutesearly) earlymin,max(minuteslate) latemin
 INTO #temp3
 FROM #temp2 GROUP BY ord_hdrnumber
 
 UPDATE #temp2
	SET order_early_flag =
      	 CASE
         	WHEN earlymin > 0 then 1
         	ELSE 0
       	END,
	order_late_flag =
	       CASE
         WHEN latemin > 0 then 1
         ELSE 0
       END
 FROM #temp3
 WHERE #temp2.ord_hdrnumber = #temp3.ord_hdrnumber

 SELECT ord_number,sum(order_early_flag) early,sum(order_late_flag) late 
 INTO #temp4
 FROM #temp2
 GROUP BY ord_number

 SELECT @ordersontime = COUNT(DISTINCT(ord_number))
 FROM #temp4
 WHERE (early + late) = 0 
 
 UPDATE #temp2
 SET --total_loadstops = @loadstops, total_unloadstops = @unloadstops, 37750
    total_orders = @totalorders, orders_late = @orderslate, orders_early = @ordersearly,
    orders_ontime = @ordersontime

--update #temp2 set stp_event = labelfile.name from labelfile where labeldefinition = 'CheckCallEvent' and stp_event = abbr


 --SELECT * from #tempt2 ORDER BY ord_hdrnumber,  mfh_number, stp_sequence -- 9/15/08: replace with explicit columns:
 --cty_nmstctORDER BY ord_hdrnumber, 
select ord_hdrnumber,
	ord_number [Order], 
	stp_event [Event], 
	cmp_name  + ' ,' + cty_nmstct  [Company],  
	stp_arrivaldate	[Arrival],
	stp_schdtearliest	[Earliest],
	stp_schdtlatest	[Latest],    
	-- stp_sequence, mfh_number,  
	stp_refnum + ' (' + stp_reftype + ')' [Ref. Number], 
    minuteslate [Late], 
	minutesearly [Early], 
    isnull([name],'UNKNOWN') [Reason Late],                  
     -- code, ecut, lcut, total_loadstops, total_unloadstops, ord_hdrnumber, total_orders, orders_late, orders_early, 
     Order_early_flag, 
	order_late_flag,
	orders_ontime
     from #temp2
	ORDER BY ord_hdrnumber,
	 mfh_number, stp_sequence

 drop table #temp1,#temp2,#temp3
GO
GRANT EXECUTE ON  [dbo].[estatCSRpt_sp] TO [public]
GO
