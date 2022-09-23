SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[select_order_moves] @ord_hdrnumber int
AS
CREATE TABLE #temp (mov_number int,
                    ord_hdrnumber int,
                    min_stp int,
                    max_stp int,
                    lgh_number int)

INSERT INTO #temp
SELECT stops1.mov_number, stops1.ord_hdrnumber, stops1.stp_number, stops2.stp_number, stops1.lgh_number
FROM stops stops2, stops stops1, 
	(SELECT DISTINCT mov_number, min(stp_mfh_sequence) stp_min, max(stp_mfh_sequence) stp_max 
	FROM stops
	WHERE ord_hdrnumber = @ord_hdrnumber
	GROUP BY mov_number) MovSeq, orderheader
WHERE stops1.mov_number = movseq.mov_number AND 
              stops1.stp_mfh_sequence = stp_min AND
	stops2.mov_number = movseq.mov_number AND
	stops2.stp_mfh_sequence = stp_max AND
              stops1.ord_hdrnumber = orderheader.ord_hdrnumber

SELECT orderheader.ord_number, stops1.cmp_id, cmp1.cmp_name, city1.cty_nmstct, stops1.stp_arrivaldate, 
              stops1.stp_departuredate, stops1.stp_event, stops2.cmp_id, cmp2.cmp_name, city2.cty_nmstct, 
              stops2.stp_arrivaldate, stops2.stp_departuredate, stops2.stp_event, #temp.mov_number, #temp.ord_hdrnumber,
              #temp.lgh_number, legheader.lgh_driver1, legheader.lgh_driver2, legheader.lgh_tractor, legheader.lgh_primary_trailer,
              legheader.lgh_carrier, stops2.mfh_number, stops2.stp_transfer_stp
  FROM  #temp, orderheader, stops stops1, stops stops2, company cmp1, company cmp2, city city1, city city2, legheader
 WHERE #temp.min_stp = stops1.stp_number and 
              stops1.cmp_id = cmp1.cmp_id and
              stops1.stp_city = city1.cty_code and 
              #temp.max_stp = stops2.stp_number and
              stops2.cmp_id = cmp2.cmp_id and
              stops2.stp_city = city2.cty_code and
              #temp.ord_hdrnumber = orderheader.ord_hdrnumber and
              #temp.lgh_number = legheader.lgh_number

GO
GRANT EXECUTE ON  [dbo].[select_order_moves] TO [public]
GO
