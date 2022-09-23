SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[d_customer_service_report]
	@pc_whichone		char (1) = 'O',
	@pc_who			character varying(50) = 'TGSP',
	@pc_divisionlvl		char(1) = 'N',
	@pdtm_from_date		datetime = '4/1/97',
	@pdtm_to_date		datetime = '6/3/97',
	@pi_earlymincutoff	int = 15,
	@pi_latemincutoff	int = 30,
	@pc_companyname		character varying(100) = ''
	
AS
/**
 * 
 * NAME:
 * dbo.d_customer_service_report
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * 
 *
 * RETURNS:
 * 
 * 
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - 
 *       
 * 002 - 
 *
 * REFERENCES: 
 *              
 * Calls001:    
 * Calls002:    
 *
 * CalledBy001:  
 * CalledBy002:  
 *
 * 
 * REVISION HISTORY:
 * 5/11/00 Since we must provide % of total information, even for
 *         reports filtered for exceptions only, and because we 
 *         cannot sum group level computed columns in the summary section
 *         we are forced to bring back totals in the return set
 * 08/08/2005.01 PTS29148 - jguo - replace double quotes around literals, table and column names
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 **/


CREATE TABLE #temp1 (ord_number char(12), ord_hdrnumber int)

DECLARE @loadstops int, @unloadstops int
DECLARE @totalorders int, @ordersearly int, @orderslate int, @ordersontime int
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
	WHERE	orderheader.ord_shipper = @pc_who AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'O'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_company = @pc_who  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'B'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_billto = @pc_who  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'C'  AND @pc_divisionlvl = 'N') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader
	WHERE	orderheader.ord_consignee = @pc_who  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date

ELSE IF (@pc_whichone = 'O' AND @pc_divisionlvl = 'Y')
	INSERT INTO #temp1  
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany = @pc_who AND
		orderheader.ord_company = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
		
ELSE IF (@pc_whichone = 'S' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany = @pc_who AND
		orderheader.ord_shipper = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
ELSE IF (@pc_whichone = 'B' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany = @pc_who AND
		orderheader.ord_billto = company.cmp_id  AND
		orderheader.ord_status in ('STD','CMP') AND
		orderheader.ord_startdate between @pdtm_from_date and @pdtm_to_date
ELSE IF (@pc_whichone = 'C' AND @pc_divisionlvl = 'Y') 
	INSERT INTO #temp1 
	SELECT 	DISTINCT
		orderheader.ord_number,
		orderheader.ord_hdrnumber
	FROM	orderheader, company
	WHERE	company.cmp_mastercompany = @pc_who AND
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
	loadorunload = 
	   CASE s.stp_type
               WHEN 'PUP' THEN 'L'
               ELSE 'U'
           END,
	total_loadstops = 0,
	total_unloadstops = 0,
	s.ord_hdrnumber,
	total_orders = 0,
	orders_late = 0,
	orders_early = 0,
	Order_early_flag = 0,
	order_late_flag = 1,
        ' ' earlyorlate,	
        orders_ontime = 0
        
INTO #temp2
FROM stops s LEFT OUTER JOIN labelfile l ON (l.abbr = s.stp_reasonlate and l.labeldefinition = 'ReasonLate'),  --pts40462 outer join conversion
	#temp1 t, company c, city y
WHERE s.ord_hdrnumber = t.ord_hdrnumber AND
	s.cmp_id = c.cmp_id AND
	s.stp_type in ('PUP','DRP') AND
	s.stp_city = y.cty_code 

 SELECT @totalorders  = (SELECT COUNT(DISTINCT ord_number)
 FROM #temp2)

 SELECT @orderslate  = (SELECT COUNT(DISTINCT ord_number)
			FROM #temp2
			WHERE minuteslate > 0 ) 
 SELECT @ordersearly  = (SELECT COUNT(DISTINCT ord_number)
			FROM #temp2
			WHERE minutesearly > 0 )

 

 SET @loadstops = (SELECT COUNT(*) from #temp2 WHERE loadorunload = 'L')
 set @unloadstops = (SELECT COUNT(*) FROM #temp2 WHERE loadorunload = 'U')


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
 SET total_loadstops = @loadstops, total_unloadstops = @unloadstops,
    total_orders = @totalorders, orders_late = @orderslate, orders_early = @ordersearly,
    orders_ontime = @ordersontime

 SELECT * 
 FROM #temp2 ORDER BY ord_hdrnumber,stp_sequence
 drop table #temp1,#temp2,#temp3


GO
GRANT EXECUTE ON  [dbo].[d_customer_service_report] TO [public]
GO
