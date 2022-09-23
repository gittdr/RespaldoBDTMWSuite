SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[lgh_cons_tr_SVStopsExtract_sp] (
@inserted UtLegheaderConsolidated READONLY
	,@deleted UtLegheaderConsolidated READONLY
	)
AS
/*******************************************************************************************************************  
  Object Description:

  Revision History:

  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ----------------------------------------
  2017-01-27   Dan Clemens			          Handle logic for SVStopsExtract GI setttings that are used in ut_legheader_consolidated.
                                            rewrote parts to handle multirow
********************************************************************************************************************/
  /*
   PTS 17428 VV Insert rows into stops_extract if legheader.lgh_type2 changes to 'SENT' 
   that signifies that order is ready to be sent to CADEC
   will not work if order is created and immediately dispatched in VD 
  */


DECLARE @mov_number INT
	,@route_dt DATETIME
	,@ord_hdrn INT
	,@lgh_num INT
	,@trc VARCHAR(8);

BEGIN

WITH CTE
AS (
	SELECT 
     s.mov_number
    ,s.stp_arrivaldate
		,s.ord_hdrnumber
		,s.lgh_number
		,evt_tractor
	FROM dbo.stops s
	INNER JOIN dbo.EVENT e ON e.stp_number = s.stp_number
	INNER JOIN @inserted i ON i.mov_number = s.mov_number
	WHERE s.ord_hdrnumber > 0
		AND e.evt_sequence = 1
		AND s.stp_mfh_sequence = (
			SELECT MIN(ss.stp_mfh_sequence)
			FROM dbo.stops ss
			INNER JOIN @inserted i ON i.mov_number = ss.mov_number
			WHERE ss.ord_hdrnumber > 0
			)
	)
INSERT dbo.stops_extract
SELECT o.mov_number
	,s.stp_mfh_sequence
	,e.evt_driver1
	,e.evt_trailer1
	,e.evt_trailer2
	,o.ord_refnum
	,cte.stp_arrivaldate
	,s.cmp_id
	,s.stp_arrivaldate
	,s.stp_departuredate
	,s.stp_lgh_mileage
	,(
		SELECT stp_departuredate
		FROM dbo.stops
		WHERE mov_number = cte.mov_number
			AND stp_mfh_sequence = s.stp_mfh_sequence - 1
		)
	,o.ord_revtype1
	,'N'
	,'N'
	,GETDATE()
FROM dbo.stops s
CROSS JOIN dbo.orderheader o
INNER JOIN dbo.EVENT e ON e.stp_number = s.stp_number
INNER JOIN CTE ON cte.mov_number = s.mov_number
	AND cte.ord_hdrnumber = o.ord_hdrnumber
WHERE e.evt_sequence = 1;

UPDATE dbo.legheader
SET lgh_dsp_date = GETDATE()
WHERE lgh_number IN (
		SELECT DISTINCT lgh_number
		FROM @inserted
		);
END;
	/* end PTS 17428 VV */
GO
GRANT EXECUTE ON  [dbo].[lgh_cons_tr_SVStopsExtract_sp] TO [public]
GO
