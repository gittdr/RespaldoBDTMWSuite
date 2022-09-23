SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[select_crossdock_segments] @ord_hdrnumber int,
                                           @mov_number int
AS
CREATE TABLE #temp (mov_number int,
                    ord_hdrnumber int,
                    min_stp int,
                    max_stp int,
                    stp_transfer_stp int)

INSERT INTO #temp
SELECT stops1.mov_number, stops1.ord_hdrnumber, stops1.stp_number, stops2.stp_number,
       movseq.stp_transfer_stp
FROM stops stops2, stops stops1, 
	(SELECT mov_number, stp_transfer_stp, min(stp_mfh_sequence) stp_min, max(stp_mfh_sequence) stp_max 
	FROM stops
	WHERE ord_hdrnumber = @ord_hdrnumber AND
              mov_number = @mov_number AND
             (stp_transfer_stp > 0 AND stp_transfer_stp is not null)
	GROUP BY mov_number, stp_transfer_stp) MovSeq, orderheader
WHERE stops1.mov_number = movseq.mov_number AND 
              stops1.stp_mfh_sequence = stp_min AND
	stops2.mov_number = movseq.mov_number AND
	stops2.stp_mfh_sequence = stp_max AND
              stops1.ord_hdrnumber = orderheader.ord_hdrnumber

SELECT orderheader.ord_number, stops1.cmp_id, cmp1.cmp_name, city1.cty_nmstct, stops1.stp_arrivaldate, 
              stops1.stp_departuredate, stops1.stp_event, stops2.cmp_id, cmp2.cmp_name, city2.cty_nmstct, 
              stops2.stp_arrivaldate, stops2.stp_departuredate, stops2.stp_event, #temp.mov_number, #temp.ord_hdrnumber,
              #temp.stp_transfer_stp
  FROM  #temp, orderheader, stops stops1, stops stops2, company cmp1, company cmp2, city city1, city city2
 WHERE #temp.min_stp = stops1.stp_number and 
              stops1.cmp_id = cmp1.cmp_id and
              stops1.stp_city = city1.cty_code and 
              #temp.max_stp = stops2.stp_number and
              stops2.cmp_id = cmp2.cmp_id and
              stops2.stp_city = city2.cty_code and
              #temp.ord_hdrnumber = orderheader.ord_hdrnumber

GO
GRANT EXECUTE ON  [dbo].[select_crossdock_segments] TO [public]
GO
