SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[tcg_freight_sp] (@startdate Datetime, @enddate Datetime)AS
SELECT DISTINCT
    RIGHT('0' + RTRIM(CAST(MONTH(oh.ord_startdate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DAY(oh.ord_startdate) As Char(2))), 2) + RIGHT(CAST(YEAR(oh.ord_startdate) As Char(4)), 2) pickup_date,
    RIGHT('0' + RTRIM(CAST(MONTH(oh.ord_completiondate) As Char(2))), 2) + RIGHT('0' + RTRIM(CAST(DAY(oh.ord_completiondate) As Char(2))), 2) + RIGHT(CAST(YEAR(oh.ord_completiondate) As Char(4)), 2) delivery_date,
    LEFT(RIGHT(RTRIM(oh.ord_number), 10) + SPACE(10), 10) freight_bill_number,
    LEFT(RTRIM(oh.ord_shipper) + SPACE(12), 12) shipper_code,
    LEFT(RTRIM(oh.ord_consignee) + SPACE(12), 12) consignee_code,
    SPACE(12) deliver_to_code,
    LEFT(RTRIM(oh.ord_billto) + SPACE(12), 12) bill_to_code,
    'F' freight_type,
    LEFT(RTRIM(CAST(oh.ord_origincity As Char(9))) + SPACE(9), 9) origin_location_code,
    LEFT(RTRIM(CAST(oh.ord_destcity As Char(9))) + SPACE(9), 9) destination_location_code,
    CASE ISNULL(oh.ord_totalweight, 0)
    WHEN 0 THEN SPACE(5) + '1'
    ELSE RIGHT(SPACE(6) + STR(ISNULL(oh.ord_totalweight, 0), 6, 0), 6)
    END actual_weight,
    billed_weight=RIGHT(SPACE(6) + STR(ISNULL((SELECT SUM(ISNULL(ivd_quantity,0)) 
                                               FROM   invoicedetail
                                               WHERE  ord_hdrnumber = oh.ord_hdrnumber AND 
                                                      cht_basisunit = 'WGT'),0), 6, 0), 6),
    RIGHT(SPACE(6) + STR(ISNULL(oh.ord_totalmiles, 0), 6, 0), 6) actual_miles,
    billed_miles=RIGHT(SPACE(6) + STR(ISNULL((SELECT SUM(ISNULL(ivd_quantity,0)) 
                                              FROM   invoicedetail 
                                              WHERE  ord_hdrnumber = oh.ord_hdrnumber AND 
                                                     cht_basisunit = 'DIS'),0), 6, 0), 6),
    SPACE(2) + '0' packaging_code,
    RIGHT(SPACE(4) + STR(ISNULL(oh.ord_totalpieces, 0), 4, 0), 4) pieces,
    SPACE(3) + '0' shipping_units,
    CASE oh.ord_terms
    WHEN 'COL' THEN '2'
    ELSE '1' 
    END prepaid_collect,
    SPACE(6) tariff,
    '2' type_of_rate,
    SPACE(9) classification,
    SPACE(6) extra_cost_codes,
    RIGHT(SPACE(9) + STR(ISNULL((SELECT SUM(ivd.ivd_charge*100) 
                                FROM   invoicedetail ivd, chargetype cht
                                WHERE  ivd.ord_hdrnumber = oh.ord_hdrnumber AND
                                       ivd.cht_itemcode = cht.cht_itemcode AND
                                       cht.cht_primary = 'Y'), 0), 9, 0), 9) gross_revenue,
    accessorial_revenue_1=RIGHT(SPACE(9) + STR(ISNULL((SELECT SUM(ivd.ivd_charge*100) 
                                                       FROM   invoicedetail ivd, chargetype cht
                                                       WHERE  ivd.ord_hdrnumber = oh.ord_hdrnumber AND 
                                                              ivd.cht_itemcode IN ('FUEL', 'FS') AND
                                                              ivd.cht_itemcode = cht.cht_itemcode AND
                                                              cht.cht_primary = 'N'),0), 9, 0), 9),
    SPACE(8) + '0' accessorial_revenue_2,
    other_accessorial_revenue=RIGHT(SPACE(9) + STR(ISNULL((SELECT SUM(ivd_charge*100) 
                                                           FROM   invoicedetail ivd, chargetype cht
                                                           WHERE  ivd.ord_hdrnumber = oh.ord_hdrnumber AND 
                                                                  ivd.cht_itemcode = cht.cht_itemcode AND
                                                                  (ivd.cht_itemcode <> 'FUEL' AND
                                                                   ivd.cht_itemcode <> 'FS') AND
                                                                  cht.cht_primary = 'N'),0), 9, 0), 9),
    RIGHT(SPACE(9) + STR(ISNULL((SELECT SUM(ivd.ivd_charge*100)
                                FROM   invoicedetail ivd
                                WHERE  ivd.ord_hdrnumber = oh.ord_hdrnumber),0), 9, 0), 9) net_revenue,
    SPACE(8) originating_linehaul_trip,
    SPACE(8) first_intermediate_trip,
    SPACE(8) second_intermediate_trip,
    SPACE(8) third_intermediate_trip,
    SPACE(8) terminating_linehaul_trip,
    additional_loadings=RIGHT(SPACE(2) + STR((SELECT COUNT(*)
                                              FROM   stops
                                              WHERE  stp_type = 'PUP' AND
                                                     ord_hdrnumber = oh.ord_hdrnumber AND
                                                     stp_sequence <> (SELECT MIN(stp_sequence) 
                                                                      FROM   stops
                                                                      WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                             stp_type = 'PUP')), 2, 0), 2),
    additional_stopoffs=RIGHT(SPACE(2) + STR((SELECT COUNT(*)
                                              FROM   stops
                                              WHERE  stp_type = 'DRP' AND
                                                     ord_hdrnumber = oh.ord_hdrnumber AND
                                                     stp_sequence <> (SELECT MAX(stp_sequence) 
                                                                      FROM   stops
                                                                      WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                             stp_type = 'DRP')), 2, 0), 2),
    SPACE(12) filler,
    SPACE(3) origin_freight_terminal,
    pickup_unit=LEFT((SELECT lgh_primary_trailer
                      FROM   legheader
                      WHERE  lgh_number = (SELECT lgh_number 
                                           FROM   stops
                                           WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                  stp_type = 'PUP' AND
                                                  stp_sequence = (SELECT MIN(stp_sequence) 
                                                                  FROM   stops
                                                                  WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                         stp_type = 'PUP') AND
                                                  stp_arrivaldate = (SELECT MIN(stp_arrivaldate)
                                                                     FROM   stops
                                                                     WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                            stp_type = 'PUP'))) + SPACE(6), 6),
    '0' dock_handling_origin,
    SPACE(3) destination_freight_terminal,
    delivery_unit=LEFT((SELECT lgh_primary_trailer
                        FROM   legheader
                        WHERE  lgh_number = (SELECT lgh_number 
                                             FROM   stops
                                             WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                    stp_type = 'DRP' AND
                                                    stp_sequence = (SELECT MAX(stp_sequence) 
                                                                    FROM   stops
                                                                    WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                           stp_type = 'DRP') AND
                                                    stp_arrivaldate = (SELECT MAX(stp_arrivaldate)
                                                                       FROM   stops
                                                                       WHERE  ord_hdrnumber = oh.ord_hdrnumber AND
                                                                              stp_type = 'DRP'))) + SPACE(8), 8),
    '0' dock_handling_destination,
    SPACE(3) intermediate_terminal_1,
    '0' dock_handling_im_1
FROM 	orderheader oh,
        invoiceheader ivh,
        legheader lgh,
        stops stp
WHERE   oh.ord_hdrnumber = ivh.ord_hdrnumber AND
        lgh.ord_hdrnumber = oh.ord_hdrnumber AND
        stp.lgh_number = lgh.lgh_number AND
        stp.stp_arrivaldate >= (SELECT MAX(stp_arrivaldate)
                                FROM   stops, legheader
                                WHERE  stops.lgh_number = legheader.lgh_number AND
                                       legheader.lgh_driver1 = lgh.lgh_driver1 AND
                                       stops.stp_event = 'DRVH' AND
                                       stops.stp_arrivaldate < @startdate) AND
        stp.stp_departuredate >= (SELECT MAX(stp_departuredate)
                                  FROM   stops, legheader
                                  WHERE  stops.lgh_number = legheader.lgh_number AND
                                         legheader.lgh_driver1 = lgh.lgh_driver1 AND
                                         stops.stp_event = 'DRVH' AND
                                         stops.stp_departuredate < @enddate) 


GO
