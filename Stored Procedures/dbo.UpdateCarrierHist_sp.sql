SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[UpdateCarrierHist_sp]
AS

/**
 * 
 * NAME:
 * dbo.Timeline_match_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 *	11/30/2001 MRH
 *	This procedure will total carrier ontime information from all trips
 *	that have happened within the last 90 days.
 *
 *	It is part of the logistics / brokerage enhancement to PowerSuite
 *
 *	This procedure should be set up as a scheduled job on the server. 
 *	I recomend that it be executed once per day. If you require more up to date
 *	on time information schedule the procedure to run more frequently however, please
 *	note that it uses a cursor to accomplish it's work and more frequent execution could
 *	degrade the perfomance of your sever.
 *
 *	Creates a table "CarrierHistory" that has the number of orders 
 *	and the number of ontime orders for all carriers that have been used in the last 90 days.
 *
 *	There is no purging at this time so if a carrier has been taken out of service, it might
 *	be a good idea to remove it fromt this table, or perhaps just occasionally truncate the
 *	contents of the tabel as it will be rewritten when the procdure is next executed.
 *
 *
 * RETURNS:
 * 	None
 *
 * RESULT SETS: 
 * 	Populates the table CarrierHistory for use in the brokerage module
 *
 * PARAMETERS:
 * 	None
 * 
 * REVISION HISTORY:
 *	MRH 12/11/01 New columns added:
 *		Carrier contact information
 *		Acessorials and Fuel average columns
 *	MRH 09/20/05 Added DISTINCT to increase performance.
 *      JG  06/05/06 33285 Use FAST_FORWARD cursor to improve fetch performance
 *  DPETE 4/19/08 PTS 40260 Pauls Hauling recode bring in Mindy Carnutt changes
 *  CAS 10/21/15 PTS 88806 Added code to run (optional) client custom stored procedure
 *		according to GI setting UserDefCarHistProc.
 **/

DECLARE @TotalOrders integer,
	@OnTimeOrders integer,
	@Daysback integer,
	@HoursSlack integer,
	@MinutesSlack INTEGER,
	@AddMinutes   INTEGER,
	@CurrentCarrier varchar(8),
	@Fstatus as integer,
	@Crh_percent	int,
	@Crh_AveFuel	money,
	@Crh_AveTotal	money,
	@Crh_AveAcc	money

CREATE TABLE #temp_legheader
(
   lgh_number INTEGER 
)

--PTS52756 MBR 06/09/10
SELECT @Daysback = gi_integer1, 
       @HoursSlack = ISNULL(gi_integer3, 0),
       @MinutesSlack = ISNULL(gi_integer4, 0) 
  FROM generalinfo 
 WHERE gi_name = 'ACS-Days-Back'

SET @daysback = ISNULL(@daysback, 90)

IF @MinutesSlack > 0
BEGIN
   SET @AddMinutes = @MinutesSlack
END
IF @MinutesSlack = 0 and @HoursSlack > 0
BEGIN
   SET @AddMinutes = @hoursslack * 60
END
IF @MinutesSlack = 0 AND @HoursSlack = 0
BEGIN
   SET @AddMinutes = 0
END

DELETE FROM CarrierHistory
-- BEGIN PTS 69505
DELETE FROM CarrierHistoryDetail WHERE ISNULL(chd_archive,'N') = 'N' OR (DATEDIFF(DAY, lgh_enddate, GETDATE()) > @Daysback)
-- END PTS 69505

DECLARE CarrierHistory CURSOR FAST_FORWARD FOR
   SELECT DISTINCT lgh_carrier 
     FROM legheader
    WHERE (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @Daysback) AND
          lgh_outstatus = 'CMP' AND
          lgh_carrier <> 'UNKNOWN'
   UNION
   SELECT DISTINCT Crh_Carrier
   FROM CarrierHistoryDetail
   WHERE Crh_Carrier NOT IN (
	SELECT DISTINCT lgh_carrier 
     FROM legheader
    WHERE (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @Daysback) AND
          lgh_outstatus = 'CMP' AND
          lgh_carrier <> 'UNKNOWN')

OPEN CarrierHistory

FETCH NEXT FROM CarrierHistory 
 INTO @CurrentCarrier

WHILE @@Fetch_status = 0
BEGIN
   DELETE FROM #temp_legheader

   INSERT INTO #temp_legheader
      SELECT lgh_number
        FROM legheader
       WHERE lgh_carrier = @currentcarrier AND
            (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @DaysBack) AND
             lgh_outstatus = 'CMP'

   -- Total number of trips for the carrier in the period
   SELECT @TotalOrders = COUNT(DISTINCT stops.ord_hdrnumber)
     FROM stops
    WHERE stops.lgh_number IN (SELECT lgh_number
                                 FROM #temp_legheader) AND
          stops.ord_hdrnumber > 0

   -- Number of on time trips for the carrier in the period
   SELECT @OnTimeOrders = COUNT(DISTINCT stops.ord_hdrnumber)
     FROM stops
    WHERE stops.lgh_number IN (SELECT lgh_number
                                 FROM #temp_legheader) AND
          stops.ord_hdrnumber IN (SELECT ord_hdrnumber
                                    FROM orderheader
                                   WHERE ord_completiondate <= DATEADD(mi, @AddMinutes, ord_dest_latestdate)) AND
          stops.ord_hdrnumber > 0
   
   -- Percent on time
   IF @TotalOrders > 0
      SET @Crh_percent = @OnTimeOrders * 100 / @TotalOrders
   ELSE
      SET @Crh_percent = 0

-- PTS 69505
SELECT @TotalOrders = @TotalOrders + (SELECT COUNT(*) FROM CarrierHistoryDetail WHERE ISNULL(chd_archive, 'N') = 'Y' AND Crh_Carrier = @CurrentCarrier)
-- END PTS 69505

   -- Paydetail information
   -- Need average total paid, average accessory, and average fuel (if we can define this)
   -- Average total paid
   DECLARE @TempSum money
 
   
   SELECT @TempSum = ISNULL(SUM(ISNULL(pyd_amount,0)), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
          --paydetail.pyd_amount > 0 AND
          paydetail.pyt_itemcode IN (SELECT pyt_itemcode
                                       FROM paytype
                                      WHERE pyt_basis = 'LGH')
                                      
   SELECT @TempSum = @TempSum + ISNULL(SUM(ISNULL(lgh_pay,0)), 0)
   FROM CarrierHistoryDetail
   WHERE (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @Daysback)
   AND Crh_Carrier = @CurrentCarrier
   AND ISNULL(chd_archive, 'N') = 'Y'                                     

   SELECT @Crh_AveTotal = CASE WHEN @TotalOrders > 0 THEN @TempSum / @TotalOrders ELSE 0 END

   -- Average total accessorial paid
   SELECT @TempSum = ISNULL(SUM(ISNULL(pyd_amount,0)), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
          --paydetail.pyd_amount > 0 AND
          paydetail.pyt_itemcode NOT IN (SELECT DISTINCT cht_itemcode 
                                           FROM fuelchargetypes
                                         UNION 
                                         SELECT DISTINCT pyt_itemcode
                                           FROM paytype
                                          WHERE pyt_basis = 'LGH'
                                         UNION
                                         SELECT DISTINCT pyt_itemcode 
                                           FROM paytype 
                                          WHERE pyt_pretax = 'N' 
                                            AND pyt_minus = 'Y')
--                                            SELECT cht_itemcode 
--                                           FROM fuelchargetypes) AND
--          paydetail.pyt_itemcode NOT IN (SELECT pyt_itemcode
--                                           FROM paytype
--                                          WHERE pyt_basis = 'LGH')

                                      
   SELECT @TempSum = @TempSum + ISNULL(SUM(ISNULL(lgh_accessorial,0)), 0)
   FROM CarrierHistoryDetail
   WHERE (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @Daysback)
   AND Crh_Carrier = @CurrentCarrier
   AND ISNULL(chd_archive, 'N') = 'Y'                                     

   SELECT @Crh_AveAcc = CASE WHEN @TotalOrders > 0 THEN @TempSum / @TotalOrders ELSE 0 END
   
   -- Average total fuel paid
   SELECT @TempSum = ISNULL(SUM(ISNULL(pyd_amount,0)), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
          --paydetail.pyd_amount > 0 AND
          paydetail.pyt_itemcode IN (SELECT cht_itemcode
                                       FROM fuelchargetypes)
 
                                       
   SELECT @TempSum = @TempSum + ISNULL(SUM(ISNULL(lgh_fsc,0)), 0)
   FROM CarrierHistoryDetail
   WHERE (DATEDIFF(DAY, lgh_enddate, GETDATE()) <= @Daysback)
   AND Crh_Carrier = @CurrentCarrier
   AND ISNULL(chd_archive, 'N') = 'Y'                                     

   SELECT @Crh_AveFuel = CASE WHEN @TotalOrders > 0 THEN @TempSum / @TotalOrders ELSE 0 END
     
   IF (SELECT ISNULL(COUNT(Crh_Carrier), 0)
         FROM CarrierHistory 
        WHERE crh_carrier = @currentcarrier) > 0
   BEGIN
      UPDATE CarrierHistory 
         SET Crh_Total = @TotalOrders, 
             Crh_ontime = @OntimeOrders, 
             Crh_percent = @Crh_percent,
             Crh_Avefuel =  @Crh_Avefuel,
             Crh_AveTotal = @Crh_AveTotal,
             Crh_AveAcc = @Crh_AveAcc
       WHERE crh_carrier = @currentcarrier
   END
   ELSE
   BEGIN
      INSERT INTO carrierhistory (crh_carrier, crh_total, crh_ontime, crh_percent,
                                  Crh_AveFuel, Crh_AveTotal, Crh_AveAcc)
                          VALUES (@CurrentCarrier, @TotalOrders, @OnTimeOrders, @crh_percent,
                                  @Crh_AveFuel, @Crh_AveTotal, @Crh_AveAcc)
   END

   FETCH NEXT FROM CarrierHistory
    INTO @CurrentCarrier

END

CLOSE CarrierHistory
DEALLOCATE CarrierHistory


-- Update the details
INSERT INTO carrierhistorydetail (ord_hdrnumber, lgh_number, ord_origincity, ord_originstate,
                                  ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial,
                                  lgh_fsc, lgh_billed, lgh_enddate, lgh_paid, orders_late, margin, lgh_invoiced, lgh_prebilled)  -- KMM 50293, add lgh_invoiced, lgh_prebilled
SELECT (select min(ord_hdrnumber) FROM stops s1 with (nolock) where s1.lgh_number = legheader.lgh_number and ord_hdrnumber > 0),
       legheader.lgh_number,
       oc.cty_code,--lgh_startcity,
       oc.cty_state,--lgh_startstate,
       dc.cty_code,--lgh_endcity,
       dc.cty_state,--lgh_endstate,
       lgh_carrier,
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         WHERE  paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
				paydetail.lgh_number = legheader.lgh_number AND
				--paydetail.pyd_amount > 0 AND
				paydetail.pyt_itemcode IN (SELECT pyt_itemcode 
                                            FROM paytype 
                                           WHERE pyt_basis = 'LGH')
				--PTS81102 JJF 20140919
				AND paydetail.asgn_type = 'CAR'
				AND paydetail.asgn_id = legheader.lgh_carrier),
				--END PTS81102 JJF 20140919
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         WHERE  paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
				paydetail.lgh_number = legheader.lgh_number AND
				--paydetail.pyd_amount > 0 AND
				paydetail.pyt_itemcode NOT IN (SELECT DISTINCT cht_itemcode 
                                                 FROM fuelchargetypes 
                                               UNION
				                               SELECT DISTINCT pyt_itemcode 
                                                 FROM paytype 
                                                WHERE pyt_basis = 'LGH'
                                               UNION
                                               SELECT DISTINCT pyt_itemcode 
                                                 FROM paytype 
                                                WHERE pyt_pretax = 'N' 
                                                  AND pyt_minus = 'Y')),
--                                               SELECT cht_itemcode 
--                                                FROM fuelchargetypes) AND
--				paydetail.pyt_itemcode NOT IN (SELECT pyt_itemcode 
--                                                FROM paytype 
--                                               WHERE pyt_basis = 'LGH')),
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         wHERE  paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
				paydetail.lgh_number = legheader.lgh_number AND
				--paydetail.pyd_amount > 0 AND
				paydetail.pyt_itemcode IN (SELECT cht_itemcode 
                                            FROM fuelchargetypes)),
       0, -- KMM PTS 50293 (SELECT ISNULL(SUM(ivd_charge), 0)
--          FROM invoicedetail
--         WHERE invoicedetail.ord_hdrnumber IN (SELECT DISTINCT stops.ord_hdrnumber
--                                                 FROM stops
--                                                WHERE stops.lgh_number = legheader.lgh_number AND
--                                                      stops.ord_hdrnumber > 0)),
--			END PTS 50293
       legheader.lgh_enddate,
       0,
       (SELECT ISNULL(COUNT(DISTINCT stops.ord_hdrnumber), 0)
               FROM stops
              WHERE stops.lgh_number = legheader.lgh_number AND
                    stops.ord_hdrnumber IN (SELECT ord_hdrnumber
                                              FROM orderheader
                                             WHERE ord_completiondate > DATEADD(mi, @AddMinutes, ord_dest_latestdate)) AND
                    stops.ord_hdrnumber > 0),
       0,
			(SELECT ISNULL(SUM(ivd_charge), 0) -- LGH_INVOICED KMM PTS 52039
               FROM invoicedetail
				inner join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
              WHERE invoicedetail.ord_hdrnumber IN (SELECT DISTINCT stops.ord_hdrnumber
                                                      FROM stops
                                                     WHERE stops.lgh_number = legheader.lgh_number AND
                                                           stops.ord_hdrnumber > 0)),
			(SELECT ISNULL(SUM(ord_totalcharge), 0) -- LGH_prebilled KMM PTS 52039
               FROM orderheader
              WHERE orderheader.ord_hdrnumber IN (SELECT DISTINCT stops.ord_hdrnumber
                                                      FROM stops
                                                     WHERE stops.lgh_number = legheader.lgh_number AND
                                                           stops.ord_hdrnumber > 0) AND
					orderheader.ord_hdrnumber not in (select ord_hdrnumber
														FROM invoiceheader
														WHERE ord_hdrnumber in (SELECT DISTINCT stops.ord_hdrnumber
																						FROM stops
																				WHERE stops.lgh_number = legheader.lgh_number AND
																				stops.ord_hdrnumber > 0))) 
  FROM legheader with (nolock) INNER JOIN stops os WITH (NOLOCK) ON legheader.lgh_number = os.lgh_number AND
                                                                    os.ord_hdrnumber > 0
                               INNER JOIN  city oc WITH (NOLOCK) ON oc.cty_code = os.stp_city
                               INNER JOIN stops ds WITH (NOLOCK) ON legheader.lgh_number = ds.lgh_number AND
                                                                    ds.ord_hdrnumber > 0
                               INNER JOIN  city dc WITH (NOLOCK) ON dc.cty_code = ds.stp_city
 WHERE (datediff(day, lgh_enddate, getdate()) <= @Daysback) AND
        lgh_outstatus = 'CMP' AND
        os.stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence)   
                                 FROM stops os2 WITH (NOLOCK)
                                WHERE os2.lgh_number = legheader.lgh_number AND
                                      os2.ord_hdrnumber > 0) AND
        ds.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)   
                                 FROM stops ds2 WITH (NOLOCK)
                                WHERE ds2.lgh_number = legheader.lgh_number AND
                                      ds2.ord_hdrnumber > 0) AND
        lgh_carrier <> 'UNKNOWN'
-- KMM PTS 50293
UPDATE	carrierhistorydetail
SET		lgh_billed = isnull(lgh_invoiced + lgh_prebilled, 0)
-- PTS 69505
WHERE ISNULL(chd_archive, 'N') <> 'Y'
-- END PTS 50293

UPDATE carrierhistorydetail
   SET lgh_paid = ISNULL((lgh_pay + lgh_accessorial + lgh_fsc), 0)
-- PTS 69505
WHERE ISNULL(chd_archive, 'N') <> 'Y'

UPDATE carrierhistorydetail
   SET margin = ROUND(((lgh_billed - lgh_paid)/lgh_billed), 4)
 WHERE lgh_billed > 0 and lgh_paid > 0
-- PTS 69505
   AND ISNULL(chd_archive, 'N') <> 'Y'

-- BEGIN PTS 88806
IF ISNULL(LEFT((SELECT gi_string1 FROM generalinfo WHERE gi_name = 'UserDefCarHistProc'), 1), 'N') = 'Y'
AND EXISTS(SELECT TOP 1 * FROM INFORMATION_SCHEMA.ROUTINES
		  WHERE ROUTINE_TYPE = 'PROCEDURE'
		  AND ROUTINE_NAME = (SELECT gi_string2 FROM generalinfo
							  WHERE gi_name = 'UserDefCarHistProc'))
BEGIN
DECLARE @procCmd nvarchar(100) = N'EXEC ' + CONVERT(nvarchar(95), (SELECT TOP 1 gi_string2 FROM generalinfo WHERE gi_name = 'UserDefCarHistProc'))
EXEC sp_executesql @procCmd
END
-- END PTS 88806

GO
GRANT EXECUTE ON  [dbo].[UpdateCarrierHist_sp] TO [public]
GO
