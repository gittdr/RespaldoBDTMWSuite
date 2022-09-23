SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_legdataforrating_sp] (@ordhdrnumber int)
AS
/**
 * DESCRIPTION:
 *  Returns information from the legheader and carrier tables need for
	rating 
 * PARAMETERS:
 *
 * RETURNS:
 *	
 * RESULT SETS: 
 *
 * REFERENCES:
 *
 * REVISION HISTORY:
 * 11/29/2007.01 ? PTS40462 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @long0 int
SELECT @long0 = 0

-- Find the legs this order is on
SELECT DISTINCT(lgh_number) lgh_number, @long0 minstopseq
INTO   #leg
FROM   stops
WHERE  ord_hdrnumber = @ordhdrnumber


-- Order them 
UPDATE #leg
SET  minstopseq = (Select MIN(Stp_sequence)
		FROM #leg, stops
		WHERE  stops.ord_hdrnumber = @ordhdrnumber
		AND stops.lgh_number = #leg.lgh_number)

-- Obtain the data we want to return
SELECT  ISNULL(car_board,'N') car_board,
	ISNULL(lgh_driver1,'UNKNOWN') lgh_driver1,
	ISNULL(lgh_driver2,'UNKNOWN') lgh_driver2,
	ISNULL(lgh_tractor,'UNKNOWN') lgh_tractor,
	ISNULL(lgh_primary_trailer,'UNKNOWN') gh_primary_trailer,
	ISNULL(lgh_primary_pup,'UNKNOWN') lgh_primary_pup,
	ISNULL(lgh_carrier,'UNKNOWN') lgh_carrier,
	ISNULL(lgh_type1,'UNK') lgh_type1,
	team = CASE 
			WHEN  lgh_driver2 = 'UNKNOWN' THEN 'S'
			WHEN  lgh_driver2 IS NULL THEN 'S'
			ELSE 'T'
		END
FROM    legheader LEFT OUTER JOIN carrier ON carrier.car_id = legheader.lgh_carrier, 
		#leg 
WHERE   legheader.lgh_number = #leg.lgh_number
--AND	carrier.car_id =* legheader.lgh_carrier




GO
GRANT EXECUTE ON  [dbo].[d_legdataforrating_sp] TO [public]
GO
