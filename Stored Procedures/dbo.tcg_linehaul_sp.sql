SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[tcg_linehaul_sp] (@startdate Datetime, @enddate Datetime, @mileagetype Int)AS
SELECT DISTINCT
         lgh.lgh_driver1 driver,
         stp.stp_arrivaldate arrival_date,
         CASE stp.stp_event
             WHEN 'DRVH' THEN 'H'
             ELSE 'C'
         END stop_code,
         CASE stp.stp_type
             WHEN 'PUP' THEN 'L'
             WHEN 'DRP' THEN 'U'
             ELSE SPACE(1) 
         END handling,
         CASE
             WHEN stp.stp_event = 'HPL' OR stp.stp_event = 'DRL' THEN '3'
             WHEN stp.stp_event = 'DLD' OR stp.stp_event = 'DUL' THEN '1'
             ELSE '2'
         END load_code,
         SPACE(10) trip_number,
         SPACE(3) terminal_code,
         LEFT(CAST(stp.stp_city As Char(9)) + SPACE(9), 9) location_code,
         CASE stp.stp_event
             WHEN 'DRVH' THEN LEFT(lgh.lgh_driver1 + SPACE(12), 12)
             ELSE LEFT(stp.cmp_id + SPACE(12), 12)
         END customer_code,
         oh.ord_number freight_bill_number,
         SPACE(4) equipment_code,
         CASE stp.stp_weight
             WHEN 0 THEN SPACE(4) + '1'
             ELSE RIGHT(SPACE(5) + STR(ISNULL(stp.stp_weight, 1), 5, 0), 5) 
         END weight,
         RIGHT('0' + RTRIM(CAST(MONTH(stp.stp_arrivaldate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DAY(stp.stp_arrivaldate) As Char(2))), 2) + RIGHT(CAST(YEAR(stp.stp_arrivaldate) As Char(4)), 2) arrive_date,
         RIGHT('0' + RTRIM(CAST(DATEPART(hh, stp.stp_arrivaldate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DATEPART(mi, stp.stp_arrivaldate) As Char(2))), 2) arrive_time,
         RIGHT('0' + RTRIM(CAST(MONTH(stp.stp_departuredate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DAY(stp.stp_departuredate) As Char(2))), 2) + RIGHT(CAST(YEAR(stp.stp_departuredate) As Char(4)), 2) depart_date,
         RIGHT('0' + RTRIM(CAST(DATEPART(hh, stp.stp_departuredate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DATEPART(mi, stp.stp_departuredate) As Char(2))), 2) depart_time,
         SPACE(5) + '0' load_unload_wages,
         SPACE(5) + '0' other_payment,
         SPACE(4) miles,
         CASE
         WHEN (stp.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                       FROM   stops
                                       WHERE  lgh_number = lgh.lgh_number) AND
               stp_arrivaldate = (SELECT MAX(stp_arrivaldate)
                                  FROM   stops
                                  WHERE  lgh_number = lgh.lgh_number AND
                                         stp_event <> 'BMT' AND
                                         stp_event <> 'EMT' AND
                                         stp_event <> 'BBT' AND
                                         stp_event <> 'EBT')) THEN RIGHT(SPACE(6) + STR(ISNULL((SELECT SUM(pyd_amount*100)
                                                                                                FROM   paydetail
                                                                                                WHERE  lgh_number = lgh.lgh_number AND
                                                                                                       pyd_pretax = 'Y' AND
                                                                                                       pyd_prorap = 'P'),0), 6, 0), 6)
         ELSE SPACE(5) + '0' 
         END wages,
         CASE
         WHEN (stp.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence)
                                       FROM   stops
                                       WHERE  lgh_number = lgh.lgh_number) AND
               stp_arrivaldate = (SELECT MAX(stp_arrivaldate)
                                  FROM   stops
                                  WHERE  lgh_number = lgh.lgh_number AND
                                         stp_event <> 'BMT' AND
                                         stp_event <> 'EMT' AND
                                         stp_event <> 'BBT' AND
                                         stp_event <> 'EBT')) THEN RIGHT(SPACE(6) + STR(ISNULL((SELECT SUM(pyd_amount*100)
                                                                                                FROM   paydetail
                                                                                                WHERE  lgh_number = lgh.lgh_number AND
                                                                                                       pyd_pretax = 'Y' AND
                                                                                                       pyd_prorap = 'A'),0), 6, 0), 6)
         ELSE SPACE(5) + '0' 
         END linehaul,
         SPACE(5) + '0' other_costs
INTO     #linehaul_all  
FROM     orderheader oh,
         legheader lgh,
         stops stp,
         invoiceheader ivh 
WHERE    lgh.lgh_number = stp.lgh_number AND
         lgh.ord_hdrnumber = oh.ord_hdrnumber AND
         ivh.ord_hdrnumber = oh.ord_hdrnumber AND
         lgh.lgh_driver1 IS NOT NULL AND
         lgh.lgh_driver1 <> 'UNKNOWN' AND
         stp.stp_event <> 'BMT' AND
         stp.stp_event <> 'EMT' AND
         stp.stp_event <> 'BBT' AND
         stp.stp_event <> 'EBT' AND
         stp.stp_arrivaldate >= (SELECT MAX(stp_arrivaldate)
                                 FROM   stops, legheader
                                 WHERE  stops.lgh_number = legheader.lgh_number AND
                                        legheader.lgh_driver1 = lgh.lgh_driver1 AND
                                        stops.stp_event = 'DRVH' AND
                                        stops.stp_arrivaldate < @startdate) AND
         stp.stp_departuredate <= (SELECT MAX(stp_departuredate)
                                   FROM   stops, legheader
                                   WHERE  stops.lgh_number = legheader.lgh_number AND
                                          legheader.lgh_driver1 = lgh.lgh_driver1 AND
                                          stops.stp_event = 'DRVH' AND
                                          stops.stp_departuredate > @enddate) 
ORDER BY driver,
         arrival_date,
         stop_code,
         handling,
         load_code,
         trip_number,
         terminal_code,
         location_code,
         customer_code,
         freight_bill_number,
         equipment_code,
         weight,
         arrive_date,
         arrive_time,
         depart_date,
         depart_time,
         load_unload_wages,
         other_payment,
         miles,
         wages,
         linehaul,
         other_costs  

DECLARE @current_driver varchar(8),
        @previous_driver varchar(8),
        @current_location char(9),
        @previous_location char(9),
        @arrival_date Datetime

DECLARE linehaul_cursor CURSOR FOR 
    SELECT driver, location_code, arrival_date
    FROM #linehaul_all
    ORDER BY driver, arrival_date
  
OPEN linehaul_cursor
FETCH NEXT FROM linehaul_cursor INTO @current_driver, @current_location, @arrival_date
  
WHILE @@FETCH_STATUS = 0
BEGIN
    IF @current_driver <> @previous_driver
        BEGIN
            UPDATE #linehaul_all
            SET    miles = SPACE(3) + '0'
            WHERE driver = @current_driver AND
                  arrival_date = @arrival_date AND
                  location_code = @current_location
        END 
    ELSE
        BEGIN
            UPDATE #linehaul_all
            SET    miles = RIGHT(SPACE(4) + STR(ISNULL((SELECT DISTINCT mt_miles
                                                        FROM mileagetable
                                                        WHERE ((mt_origin = RTRIM(@current_location) AND
                                                               mt_destination = RTRIM(@previous_location)) OR
                                                              (mt_origin = RTRIM(@previous_location) AND
                                                               mt_destination = RTRIM(@current_location))) AND
                                                               mt_type = @mileagetype), 0), 4, 0), 4)
            WHERE driver = @current_driver AND
                  arrival_date = @arrival_date AND
                  location_code = @current_location
        END

    SET @previous_driver = @current_driver
    SET @previous_location = @current_location

    FETCH NEXT FROM linehaul_cursor INTO @current_driver, @current_location, @arrival_date
END
  
CLOSE linehaul_cursor
DEALLOCATE linehaul_cursor

SELECT   stop_code,
         handling,
         load_code,
         trip_number,
         terminal_code,
         location_code,
         customer_code,
         freight_bill_number,
         equipment_code,
         weight,
         arrive_date,
         arrive_time,
         depart_date,
         depart_time,
         load_unload_wages,
         other_payment,
         miles,
         wages,
         linehaul,
         other_costs      
FROM     #linehaul_all
ORDER BY driver, arrival_date

GO
