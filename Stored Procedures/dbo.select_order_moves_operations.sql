SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*******************************************************************************************************************  
  Object Description:
  This stored procedure is used to determine possile moves to open when TTS50.INI setting 
  [.NetOperations] CrossDockPrompt=Y
  
  Revision History:
  Date         Name             Label/PTS      Description
  -----------  ---------------  ----------    ----------------------------------------
  11/29/2016   Mark Hampton     PTS: 99294    Initial Release
  06/14/2017   Matt Zerefos     NSUITE-201618 Cancelled orders have a lgh_number stamped on the stop, but the leg doesn't
											   exist in legheader. Changed to LEFT OUT JOIN on return query to handle this case.
********************************************************************************************************************/

CREATE PROCEDURE [dbo].[select_order_moves_operations] @ord_number varchar (13), @type int, @debug int = 0
AS
SET NOCOUNT ON
DECLARE @temp TABLE (mov_number int,
                    ord_hdrnumber int,
                    min_stp int,
                    max_stp int,
                    lgh_number int)
DECLARE @ord_hdrnumber int
IF @type = 1 
	SELECT @type = 0, @ord_hdrnumber = ord_hdrnumber FROM orderheader WHERE ord_number = @ord_number
ELSE
	SELECT @ord_hdrnumber = @ord_number
IF ISNULL (@ord_hdrnumber, -1)  < 0
	RETURN
INSERT INTO @temp
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

IF @debug = 1 
	SELECT * FROM @temp

SELECT orderheader.ord_number OrderNumber, 
       stops1.cmp_id OriginCmpId, 
       cmp1.cmp_name OriginCmpName, 
       city1.cty_nmstct OriginCityNameState, 
       stops1.stp_arrivaldate OriginArrivalDate, 
       stops1.stp_departuredate OriginDepartureDate, 
       stops1.stp_event OriginEvent, 
       stops2.cmp_id DestinationCmpId, 
       cmp2.cmp_name DestinationCmpName, 
       city2.cty_nmstct DestinationCityNameState, 
       stops2.stp_arrivaldate DestinationArrivalDate, 
       stops2.stp_departuredate DestinationDepartureDate, 
       stops2.stp_event DestinationEvent, 
       tmpTable.mov_number MoveNumber, 
       tmpTable.ord_hdrnumber OrdHdrNumber,
       tmpTable.lgh_number LegNumber, 
       COALESCE(legheader.lgh_driver1, 'UNKNOWN') Driver1,
       COALESCE(legheader.lgh_driver2, 'UNKNOWN') Driver2, 
       COALESCE(legheader.lgh_tractor, 'UNKNOWN') Tractor, 
       COALESCE(legheader.lgh_primary_trailer, 'UNKNOWN') Trailer1,
       COALESCE(legheader.lgh_carrier, 'UNKNOWN') Carrier,
	   COALESCE(legheader.lgh_outstatus, 'UNK') LegStatus
  FROM @temp tmpTable JOIN stops stops1 ON tmpTable.min_stp = stops1.stp_number
  		JOIN stops stops2 ON tmpTable.max_stp = stops2.stp_number
  		JOIN company cmp1 ON cmp1.cmp_id = stops1.cmp_id
  		JOIN company cmp2 ON cmp2.cmp_id = stops2.cmp_id
  		JOIN city city1 ON city1.cty_code = stops1.stp_city
  		JOIN city city2 ON city2.cty_code = stops2.stp_city
  		JOIN orderheader ON orderheader.ord_hdrnumber = tmpTable.ord_hdrnumber
  		LEFT OUTER JOIN legheader ON legheader.lgh_number = tmpTable.lgh_number
ORDER BY stops1.mfh_number 
GO
GRANT EXECUTE ON  [dbo].[select_order_moves_operations] TO [public]
GO
