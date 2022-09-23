SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[UpdateCarrierHist_withAssetData_sp]
AS

/**
 * 
 * NAME:
 * dbo.UpdateCarrierHist_withAssetData_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
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
 *	JET 08/28/10 New proc to augment the Carrier History table with Asset Based data
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
	@Crh_AveAcc	money,
	@IncludeAssetStats varchar(1),
	@MyCarrierCode varchar(8)
	
SELECT @IncludeAssetStats = LEFT(ISNULL(gi_string1, 'N'), 1),
       @MyCarrierCode = ISNULL(gi_string2, '')
  FROM generalinfo 
 WHERE gi_name = 'ACS-IncludeCompanyAssetsStats'

IF @IncludeAssetStats = 'N' OR LEN(RTRIM(@MyCarrierCode)) = 0
	RETURN

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

DELETE FROM CarrierHistory where crh_carrier = @MyCarrierCode
DELETE FROM CarrierHistoryDetail where crh_carrier = @MyCarrierCode

-- Carrier Summary Information
BEGIN
   DELETE FROM #temp_legheader

   INSERT INTO #temp_legheader
      SELECT lgh_number
        FROM legheader
       WHERE lgh_carrier = 'UNKNOWN' AND
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

   -- Paydetail information
   -- Need average total paid, average accessory, and average fuel (if we can define this)
   -- Average total paid
   SELECT @Crh_AveTotal = ISNULL(AVG(pyd_amount), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND -- KMM PTS 50293
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
          paydetail.pyt_itemcode IN (SELECT pyt_itemcode
                                       FROM paytype
                                      WHERE	pyt_basis = 'LGH')

   -- Average total accessorial paid
   SELECT @Crh_AveAcc = ISNULL(AVG(pyd_amount), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND 
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
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

   -- Average total fuel paid
   SELECT @Crh_AveFuel = ISNULL(AVG(pyd_amount), 0)
     FROM paydetail
    WHERE paydetail.pyd_status <> 'DNS' AND 
		  paydetail.lgh_number IN (SELECT lgh_number
                                     FROM #temp_legheader) AND
          paydetail.pyt_itemcode IN (SELECT cht_itemcode
                                       FROM fuelchargetypes)
   
   IF (SELECT ISNULL(COUNT(Crh_Carrier), 0)
         FROM CarrierHistory 
        WHERE crh_carrier = @MyCarrierCode) > 0
   BEGIN
      UPDATE CarrierHistory 
         SET Crh_Total = @TotalOrders, 
             Crh_ontime = @OntimeOrders, 
             Crh_percent = @Crh_percent,
             Crh_Avefuel =  @Crh_Avefuel,
             Crh_AveTotal = @Crh_AveTotal,
             Crh_AveAcc = @Crh_AveAcc
       WHERE crh_carrier = @MyCarrierCode
   END
   ELSE
   BEGIN
      INSERT INTO carrierhistory (crh_carrier, crh_total, crh_ontime, crh_percent,
                                  Crh_AveFuel, Crh_AveTotal, Crh_AveAcc)
                          VALUES (@MyCarrierCode, @TotalOrders, @OnTimeOrders, @crh_percent,
                                  @Crh_AveFuel, @Crh_AveTotal, @Crh_AveAcc)
   END
END

-- Update the details
INSERT INTO carrierhistorydetail (ord_hdrnumber, lgh_number, ord_origincity, ord_originstate,
                                  ord_destcity, ord_deststate, crh_carrier, lgh_pay, lgh_accessorial,
                                  lgh_fsc, lgh_billed, lgh_enddate, lgh_paid, orders_late, margin, lgh_invoiced, lgh_prebilled)  -- KMM 50293, add lgh_invoiced, lgh_prebilled
SELECT (select min(ord_hdrnumber) FROM stops s1 with (nolock) where s1.lgh_number = legheader.lgh_number and ord_hdrnumber > 0),
       legheader.lgh_number,
       oc.cty_code, 
       oc.cty_state, 
       dc.cty_code, 
       dc.cty_state, 
       @MyCarrierCode,
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         WHERE  paydetail.pyd_status <> 'DNS' AND 
				paydetail.lgh_number = legheader.lgh_number AND
				paydetail.pyt_itemcode IN (SELECT pyt_itemcode 
                                            FROM paytype 
                                           WHERE pyt_basis = 'LGH')),
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         WHERE  paydetail.pyd_status <> 'DNS' AND 
				paydetail.lgh_number = legheader.lgh_number AND
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
       (SELECT ISNULL(SUM(pyd_amount), 0)
          FROM paydetail
         wHERE  paydetail.pyd_status <> 'DNS' AND 
				paydetail.lgh_number = legheader.lgh_number AND
				paydetail.pyt_itemcode IN (SELECT cht_itemcode 
                                            FROM fuelchargetypes)),
       0,        legheader.lgh_enddate,
       0,
       (SELECT ISNULL(COUNT(DISTINCT stops.ord_hdrnumber), 0)
               FROM stops
              WHERE stops.lgh_number = legheader.lgh_number AND
                    stops.ord_hdrnumber IN (SELECT ord_hdrnumber
                                              FROM orderheader
                                             WHERE ord_completiondate > DATEADD(mi, @AddMinutes, ord_dest_latestdate)) AND
                    stops.ord_hdrnumber > 0),
       0,
			(SELECT ISNULL(SUM(ivd_charge), 0) 
               FROM invoicedetail
				inner join invoiceheader on invoicedetail.ivh_hdrnumber = invoiceheader.ivh_hdrnumber
              WHERE invoicedetail.ord_hdrnumber IN (SELECT DISTINCT stops.ord_hdrnumber
                                                      FROM stops
                                                     WHERE stops.lgh_number = legheader.lgh_number AND
                                                           stops.ord_hdrnumber > 0)),
			(SELECT ISNULL(SUM(ord_totalcharge), 0) 
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
        lgh_carrier = 'UNKNOWN'

UPDATE	carrierhistorydetail
SET		lgh_billed = isnull(lgh_invoiced + lgh_prebilled, 0)

UPDATE carrierhistorydetail
   SET lgh_paid = ISNULL((lgh_pay + lgh_accessorial + lgh_fsc), 0)

UPDATE carrierhistorydetail
   SET margin = ROUND(((lgh_billed - lgh_paid)/lgh_billed), 4)
 WHERE lgh_billed > 0 and lgh_paid > 0

GO
GRANT EXECUTE ON  [dbo].[UpdateCarrierHist_withAssetData_sp] TO [public]
GO
