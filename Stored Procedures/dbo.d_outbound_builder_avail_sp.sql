SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_outbound_builder_avail_sp] (@ord_hdrnumber INT)
AS
CREATE TABLE #bols(
	legtype			VARCHAR(20)	NULL,
	fgt_weight		FLOAT 		NULL,
	fgt_description		VARCHAR(60)	NULL,
	cmd_code		VARCHAR(8)	NULL,
	fgt_count		DECIMAL(10,2)	NULL,
	fgt_countunit		VARCHAR(6)	NULL,
	stp_number		INTEGER		NULL,
	fgt_refnum		VARCHAR(30) 	NULL,
	fgt_consignee		VARCHAR(8)	NULL,
	fgt_shipper		VARCHAR(8)	NULL,
	fgt_terms		VARCHAR(6)	NULL,
	fgt_bolid		INTEGER		NULL,
	fgt_leg_origin		VARCHAR(8)	NULL,
	fgt_leg_dest		VARCHAR(8)	NULL,
	fgt_count2		DECIMAL(10,2)	NULL,
	fgt_count2unit		VARCHAR(6)	NULL,
	fgt_bol_status		VARCHAR(6)	NULL,
	stp_departuredate	DATETIME	NULL,
	same_shipperconsignee	SMALLINT	NULL,
	ord_hdrnumber		INTEGER		NULL,
	dest_stp_number		INTEGER		NULL,
	evt_eventcode		VARCHAR(6)	NULL,
	evt_startdate		DATETIME	NULL,
	evt_status		VARCHAR(6)	NULL
)

INSERT INTO #bols (legtype, fgt_weight, fgt_description, cmd_code, fgt_count,
                   fgt_countunit, stp_number, fgt_refnum, fgt_consignee,
                   fgt_shipper, fgt_terms, fgt_bolid, fgt_leg_origin,
                   fgt_leg_dest, fgt_count2, fgt_count2unit, fgt_bol_status,
                   stp_departuredate, same_shipperconsignee, ord_hdrnumber,
                   dest_stp_number)
   SELECT 'DELIVERY',
	  freightdetail.fgt_weight,   
          freightdetail.fgt_description,   
          freightdetail.cmd_code,   
          freightdetail.fgt_count,   
          freightdetail.fgt_countunit,   
          freightdetail.stp_number,   
          freightdetail.fgt_refnum,   
          freightdetail.fgt_consignee,   
          freightdetail.fgt_shipper,   
          freightdetail.fgt_terms,   
          freightdetail.fgt_bolid,   
          freightdetail.fgt_leg_origin,   
          freightdetail.fgt_leg_dest,   
          freightdetail.fgt_count2,   
          freightdetail.fgt_count2unit,   
          freightdetail.fgt_bol_status,
	  s1.stp_departuredate,
	  CASE WHEN freightdetail.fgt_shipper = freightdetail.fgt_consignee THEN 1
	       ELSE 0
	  END,
          s1.ord_hdrnumber,
         (SELECT stp_number
            FROM stops
           WHERE stops.ord_hdrnumber = s1.ord_hdrnumber AND
                 stops.cmp_id = freightdetail.fgt_leg_dest AND
                 stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) 
                                             FROM stops
                                            WHERE stops.ord_hdrnumber = s1.ord_hdrnumber AND
                                                  stops.cmp_id = freightdetail.fgt_leg_dest))
     FROM freightdetail JOIN stops s1 ON freightdetail.stp_number = s1.stp_number
    WHERE freightdetail.fgt_bolid IS NOT NULL AND
          freightdetail.fgt_bol_status = 'AVL' AND
          exists (SELECT 1 
                    FROM stops
                   WHERE stops.ord_hdrnumber = @ord_hdrnumber AND
                         stops.cmp_id = freightdetail.fgt_consignee) AND
          freightdetail.fgt_leg_dest <> freightdetail.fgt_consignee AND
          freightdetail.fgt_leg_dest IN (SELECT cmp_id
                                           FROM stops
                                          WHERE stops.ord_hdrnumber = @ord_hdrnumber)

INSERT INTO #bols (legtype, fgt_weight, fgt_description, cmd_code, fgt_count,
                   fgt_countunit, stp_number, fgt_refnum, fgt_consignee,
                   fgt_shipper, fgt_terms, fgt_bolid, fgt_leg_origin,
                   fgt_leg_dest, fgt_count2, fgt_count2unit, fgt_bol_status,
                   stp_departuredate, same_shipperconsignee, ord_hdrnumber,
                   dest_stp_number)
   SELECT 'RIDE',
          freightdetail.fgt_weight,
          freightdetail.fgt_description,   
          freightdetail.cmd_code,   
          freightdetail.fgt_count,   
          freightdetail.fgt_countunit,   
          freightdetail.stp_number,   
          freightdetail.fgt_refnum,   
          freightdetail.fgt_consignee,   
          freightdetail.fgt_shipper,   
          freightdetail.fgt_terms,   
          freightdetail.fgt_bolid,   
          freightdetail.fgt_leg_origin,   
          freightdetail.fgt_leg_dest,   
          freightdetail.fgt_count2,   
          freightdetail.fgt_count2unit,   
          freightdetail.fgt_bol_status,
	  s1.stp_departuredate,
	  CASE WHEN freightdetail.fgt_shipper = freightdetail.fgt_consignee THEN 1
	       ELSE 0
	  END same_shipperconsignee,
          s1.ord_hdrnumber,
         (SELECT stp_number
            FROM stops
           WHERE stops.ord_hdrnumber = s1.ord_hdrnumber AND
                 stops.cmp_id = freightdetail.fgt_leg_dest AND
                 stops.stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) 
                                             FROM stops
                                            WHERE stops.ord_hdrnumber = s1.ord_hdrnumber AND
                                                  stops.cmp_id = freightdetail.fgt_leg_dest))
     FROM freightdetail JOIN stops s1 ON freightdetail.stp_number = s1.stp_number
    WHERE fgt_bolid IS NOT NULL AND
          fgt_bol_status = 'AVL' AND
         (fgt_leg_dest IN (SELECT DISTINCT cmp_id
                             FROM stops 
                            WHERE stops.ord_hdrnumber = @ord_hdrnumber) AND
          fgt_consignee NOT IN (SELECT DISTINCT cmp_id
                                  FROM stops
                                 WHERE stops.ord_hdrnumber = @ord_hdrnumber) AND
          s1.ord_hdrnumber <> @ord_hdrnumber) AND
          fgt_leg_dest <> fgt_consignee

UPDATE #bols
   SET #bols.evt_eventcode = stops.stp_event,
       #bols.evt_startdate = stops.stp_arrivaldate,
       #bols.evt_status = stops.stp_status
  FROM stops
 WHERE #bols.dest_stp_number = stops.stp_number

UPDATE #bols
   SET #bols.evt_eventcode = event.evt_eventcode,
       #bols.evt_startdate = event.evt_startdate,
       #bols.evt_status = event.evt_status
  FROM event
 WHERE #bols.evt_eventcode = 'DRL' AND
       #bols.evt_status = 'DNE' AND
       #bols.dest_stp_number = event.stp_number AND
       event.evt_sequence = (SELECT MAX(evt_sequence)
                               FROM event
                              WHERE event.stp_number = #bols.dest_stp_number)

UPDATE #bols
   SET #bols.evt_eventcode = event.evt_eventcode, 
       #bols.evt_startdate = event.evt_startdate,
       #bols.evt_status = event.evt_status
  FROM event
 WHERE #bols.evt_eventcode = 'LUL' AND
       #bols.evt_status = 'DNE' AND
       #bols.dest_stp_number = event.stp_number AND
       event.evt_sequence = (SELECT MAX(evt_sequence)
                               FROM event
                              WHERE event.stp_number = #bols.dest_stp_number)

SELECT *
  FROM #bols


GO
GRANT EXECUTE ON  [dbo].[d_outbound_builder_avail_sp] TO [public]
GO
