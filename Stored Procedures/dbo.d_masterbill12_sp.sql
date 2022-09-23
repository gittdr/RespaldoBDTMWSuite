SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_masterbill12_sp] (@reprintflag varchar(10),@mbnumber int, @billto varchar(8),@shipper varchar(8),
                               @consignee varchar(8), @orderedby varchar(8),@shipstart datetime, 
                               @shipend datetime,@deldatestart datetime, @deldateend datetime, 
	                       @revtype1 varchar(6), @revtype2 varchar(6), @revtype3 varchar(6), @revtype4 varchar(6), 
                               @mbstatus varchar(6), @paperworkstatus varchar(6),@billdate datetime,@copy int)
AS
/**
 * DESCRIPTION:
 *
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * pts 11362 customer claims they need to select invoices by delivery date as well as ship date. Add other selection criterea
 * Also remove group by's since sorting and grouping is done on the datawindow (dont want possible conflict)
 * PTS 15576 - get new parameters.
 * 10/30/2007.01 ? PTS40029 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/


CREATE TABLE #temp 
       (ivh_hdrnumber INT        NULL,
        shipper       VARCHAR(8) NULL, 
        bill_to       VARCHAR(8) NULL,
        bill_date     DATETIME   NULL,
	routes        INT        NULL, 
        stops         INT        NULL, 
        total_miles   FLOAT      NULL, 
        store_delays  FLOAT      NULL, 
        route_delays  FLOAT      NULL, 
        wrong_del     INT        NULL, 
        missing_del   INT        NULL, 
        damaged_del   INT        NULL, 
        redeliveries  INT        NULL,
        transfers     INT        NULL, 
        credit_chrgs  FLOAT      NULL, 
        cost          FLOAT      NULL,
	delivery_cost float      null,
	car_cost      float      null,
	car_stops     int        null,
	car_trips	int	null,
	transfer_cost float 		null)

--PTS 27733	JZ	4/14/2005	Changes from KMM for CARDINAL - 3/29/05	
CREATE TABLE #temp2
       (ivh_hdrnumber INT        NULL,
        shipper       VARCHAR(8) NULL, 
        bill_to       VARCHAR(8) NULL,
        bill_date     DATETIME   NULL,
	routes        INT        NULL, 
        stops         INT        NULL, 
        total_miles   FLOAT      NULL, 
        store_delays  FLOAT      NULL, 
        route_delays  FLOAT      NULL, 
        wrong_del     INT        NULL, 
        missing_del   INT        NULL, 
        damaged_del   INT        NULL, 
        redeliveries  INT        NULL,
        transfers     INT        NULL, 
        credit_chrgs  FLOAT      NULL, 
        total_cost    FLOAT      NULL,
	delivery_cost float      null,
	car_cost      float      null,
	car_stops     int        null,
	car_trips     int	null,
	transfer_cost float 	null)

SELECT @shipstart = convert(char(12),@shipstart)+'00:00:00'
SELECT @shipend   = convert(char(12),@shipend  )+'23:59:59'

IF UPPER(@reprintflag) = 'REPRINT' 
   BEGIN
        INSERT INTO #temp (ivh_hdrnumber, shipper, bill_to, bill_date, routes, cost, delivery_cost, car_cost, car_stops)
        SELECT ivh_hdrnumber, 
               ivh_shipper, 
	       ivh_billto, 
               MIN(ivh_billdate), 
               ord_hdrnumber, 
               SUM(ivh_totalcharge),0,0,0
          FROM invoiceheader
         WHERE invoiceheader.ivh_mbnumber = @mbnumber 
        GROUP BY ivh_hdrnumber, ivh_shipper, ivh_billto, ord_hdrnumber
   END

IF UPPER(@reprintflag) <> 'REPRINT' 
   BEGIN
        INSERT INTO #temp (ivh_hdrnumber, shipper, bill_to, bill_date, routes, cost, delivery_cost, car_cost, car_stops)
        SELECT ivh_hdrnumber, 
               ivh_shipper, 
	       ivh_billto, 
               MIN(ivh_billdate), 
               ord_hdrnumber, 
               SUM(ivh_totalcharge),0,0,0 
          FROM invoiceheader 
         WHERE ivh_mbnumber = 0 AND 
               ivh_shipdate BETWEEN @shipstart AND @shipend AND 
               ivh_mbstatus = 'RTP' AND 
               @revtype1 IN (ivh_revtype1,'UNK') AND 
               ivh_billto = @billto 
        GROUP BY ivh_hdrnumber, ivh_shipper, ivh_billto, ord_hdrnumber
   END
   -- update stop related information
   UPDATE #temp
      SET stops = (SELECT SUM(CASE stp_type1 
                                   WHEN 'SHP' THEN 0 
                                   WHEN 'CON' THEN 0 
                                   ELSE 1 
                              END) 
                     FROM stops 
                    WHERE stops.ord_hdrnumber = #temp.routes AND 
                          stops.ord_hdrnumber <> 0), 
          total_miles = (SELECT SUM(stp_ord_mileage) 
                           FROM stops 
                          WHERE stops.ord_hdrnumber = #temp.routes AND 
                                stops.ord_hdrnumber <> 0), 
          store_delays = (SELECT SUM(CASE stp_reasonlate 
                                          WHEN 'ST' THEN stp_delayhours
                                          WHEN 'SHIP' THEN stp_delayhours  
                                          ELSE 0 
                                     END) 
                            FROM stops 
                           WHERE stops.ord_hdrnumber = #temp.routes AND 
                                 stops.ord_hdrnumber <> 0), 
          route_delays = (SELECT SUM(CASE stp_reasonlate 
                                          WHEN 'RE' THEN stp_delayhours 
                                          ELSE 0 
                                     END) 
                            FROM stops 
                           WHERE stops.ord_hdrnumber = #temp.routes AND 
                                 stops.ord_hdrnumber <> 0), 
          redeliveries = (SELECT SUM(CASE stp_redeliver 
                                          WHEN '1' THEN 1
                                          ELSE 0
                                     END) 
                            FROM stops 
                           WHERE stops.ord_hdrnumber = #temp.routes AND 
                                 stops.ord_hdrnumber <> 0), 
          -- JET - 8/28/00 - PTS #8812, modified transfers column to include fly by stops
          transfers = (SELECT SUM(CASE stp_type1 
                                       WHEN 'FY' THEN 1
                                       WHEN 'TR' THEN 1 
                                       ELSE 0
                                  END) 
                            FROM stops 
                           WHERE stops.ord_hdrnumber = #temp.routes AND 
                                 stops.ord_hdrnumber <> 0) 

/*
-- KMM PTS 22389 per Clay Holmes and Jonathan Turner from 3/15/04 on site visit,
-- do not need to populate OSD information.  Outer join to this table causes
-- serious performance issues

--    -- update stop related information
--    UPDATE #temp
--       SET wrong_del = (SELECT SUM(CASE osd_type 
--                                        WHEN 'O' THEN 1
--                                        ELSE 0
--                                   END)
--                             FROM stops, osd 
--                            WHERE #temp.routes = stops.ord_hdrnumber AND 
--                                  stops.stp_number *= osd.osd_stp_number AND 
--                                  stops.ord_hdrnumber <> 0), 
--           missing_del = (SELECT SUM(CASE osd_type 
--                                          WHEN 'S' THEN 1 
--                                          ELSE 0
--                                     END) 
--                            FROM stops, osd 
--                           WHERE #temp.routes = stops.ord_hdrnumber AND 
--                                 stops.stp_number *= osd.osd_stp_number AND 
--                                 stops.ord_hdrnumber <> 0), 
--           damaged_del = (SELECT SUM(CASE osd_type 
--                                          WHEN 'D' THEN 1
--                                          ELSE 0
--                                     END) 
--                            FROM stops, osd 
--                           WHERE #temp.routes = stops.ord_hdrnumber AND 
--                                 stops.stp_number *= osd.osd_stp_number AND 
--                                 stops.ord_hdrnumber <> 0) 
-- KMM end PTS 22389 per Clay Holmes and Jonathan Turner from 3/15/04 on site visit,
-- do not need to populate OSD information.  Outer join to this table causes
-- serious performance issues
*/


   -- update invoice detail
   UPDATE #temp
      SET credit_chrgs = (SELECT SUM(CASE cht_crchg 
                                          WHEN 1 THEN ivd_charge 
                                          ELSE 0
                                     END) 
                            FROM invoicedetail, chargetype
                           WHERE #temp.ivh_hdrnumber = invoicedetail.ivh_hdrnumber AND 
                                 invoicedetail.cht_itemcode = chargetype.cht_itemcode)
   -- update invoice detail
   UPDATE #temp
      SET delivery_cost = (SELECT SUM(CASE cht_itemcode
                                          WHEN 'CRYIN1' THEN 0
                                          WHEN 'CRYIN2' THEN 0
                                          ELSE ivd_charge
                                     END) 
                            FROM invoicedetail
                           WHERE #temp.ivh_hdrnumber = invoicedetail.ivh_hdrnumber)

   -- update stop - invoiceheader info
   update #temp
      set car_cost = cost from invoiceheader
      where #temp.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
            and ivh_carrier <> 'UNKNOWN'
   update #temp
      set car_stops = (select count(*) from invoiceheader,stops
      where #temp.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
            and ivh_carrier <> 'UNKNOWN' 
            and invoiceheader.ord_hdrnumber=stops.ord_hdrnumber
            and (stops.stp_type1 NOT IN ('SHP', 'CON') OR stops.stp_type1 IS NULL)
            and stops.ord_hdrnumber <> 0)

	--update transfer cost - invoice header info
UPDATE #temp
      SET transfer_cost = (SELECT SUM(CASE cht_itemcode
                                          WHEN 'STPFY' THEN ivd_charge 
                                          WHEN 'STPTR' THEN ivd_charge
                                          ELSE 0
                                     END) 
                            FROM invoicedetail
                           WHERE #temp.ivh_hdrnumber = invoicedetail.ivh_hdrnumber)

update #temp
      set car_trips = (select count (distinct ord_hdrnumber) from invoiceheader
      where #temp.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
            and ivh_carrier  <> 'UNKNOWN' and ord_hdrnumber <> 0)
            
--PTS 27733	JZ	4/14/2005	Changes from KMM for CARDINAL - 3/29/05	
-- KMM Done on site at Cardinal 03/29/05, remove select into
   Insert into #temp2 (ivh_hdrnumber,
		        shipper,
		        bill_to,
		        bill_date,
			routes,
		        stops,
		        total_miles,
		        store_delays,
		        route_delays,
		        wrong_del,
		        missing_del,
		        damaged_del,
		        redeliveries,
		        transfers,
		        credit_chrgs,
		        total_cost,
			delivery_cost,
			car_cost,
			car_stops,
			car_trips,
			transfer_cost)
		(SELECT ivh_hdrnumber, 
		          shipper, 
		          bill_to, 
		          bill_date, 
		          COUNT(routes),
		          SUM(stops),
		          SUM(total_miles),
		          SUM(store_delays),
		          SUM(route_delays),
		          SUM(wrong_del),
		          SUM(missing_del),
		          SUM(damaged_del),
		          SUM(redeliveries),
		          SUM(transfers),
		          SUM(credit_chrgs),
		          MIN(cost),
		          SUM(delivery_cost),
		          SUM(car_cost),
		          SUM(car_stops),
		          SUM(car_trips),
			  SUM(transfer_cost)
		--pts40029 outer join conversion
		FROM #temp left outer join company cmp on #temp.bill_to = cmp.cmp_id
		GROUP BY ivh_hdrnumber, shipper, bill_to, bill_date)

   DROP TABLE #temp

   SELECT ivh_hdrnumber, 
          @mbnumber invoice_number, 
          shipper, 
          bill_to, 
          cmp.cmp_name billto_name,
          CASE cmp.cmp_mailto_name 
	       WHEN NULL THEN ''
               WHEN '' THEN ''
	       WHEN ' ' THEN ''
               ELSE cmp.cmp_mailto_address1
	  END billto_address,
          CASE cmp.cmp_mailto_name 
	       WHEN NULL THEN ''
               WHEN '' THEN ''
	       WHEN ' ' THEN ''
               ELSE cmp.cmp_mailto_address2
	  END billto_address2,
          CASE cmp.cmp_mailto_name 
	       WHEN NULL THEN ''
               WHEN '' THEN ''
	       WHEN ' ' THEN ''
               ELSE SUBSTRING(cmp.mailto_cty_nmstct,1,(CHARINDEX('/',cmp.mailto_cty_nmstct)) - 1)
	  END billto_nmstct,
          CASE cmp.cmp_mailto_name
	       WHEN NULL THEN ''
               WHEN '' THEN ''
	       WHEN ' ' THEN ''
               ELSE cmp.cmp_mailto_zip
          END billto_zip, 
          bill_date, 
          @copy copies, 
          @shipend period_ending, 
	  routes, 
          stops, 
          total_miles, 
          store_delays, 
          route_delays, 
          wrong_del, 
          missing_del, 
          damaged_del, 
          redeliveries, 
          transfers, 
          credit_chrgs, 
          total_cost, 
          total_cost/stops cost_stop,
          delivery_cost,
          car_cost,
          car_stops,
          car_trips,
			transfer_cost

     FROM #temp2 left outer join company cmp on #temp2.bill_to = cmp.cmp_id

   DROP TABLE #temp2
GO
GRANT EXECUTE ON  [dbo].[d_masterbill12_sp] TO [public]
GO
