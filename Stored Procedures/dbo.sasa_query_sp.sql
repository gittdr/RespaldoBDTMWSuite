SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sasa_query_sp]
AS

CREATE TABLE #sasa (
	evt_enddate		DATETIME,
	evt_driver1		VARCHAR(8),
	evt_driver2		VARCHAR(8),
	evt_tractor		VARCHAR(8),
	ord_hdrnumber	INTEGER)


INSERT #SASA
 	SELECT DISTINCT	e1.evt_enddate, 
					e1.evt_driver1, 
					e1.evt_driver2,
					e1.evt_tractor, 
					e1.ord_hdrnumber
	  FROM	event e1 
	 WHERE	e1.evt_driver1 <> 'UNKNOWN' AND 
			e1.evt_sequence = 1 AND 
			e1.evt_enddate = (SELECT	MAX(ISNULL(e2.evt_enddate, '19500101')) 
								FROM	event e2 
							   WHERE 	e2.evt_sequence = 1 and 
										e1.evt_tractor = e2.evt_tractor AND
										e2.evt_enddate < CONVERT(DATETIME, CONVERT(VARCHAR(10),DATEADD(dd, 1, GETDATE()), 101))) AND
			e1.evt_enddate between  CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 101)) and CONVERT(DATETIME, CONVERT(VARCHAR(10),DATEADD(dd, 1, GETDATE()), 101))
	ORDER BY e1.evt_enddate ASC,
			 e1.evt_driver1,  
			 e1.ord_hdrnumber


INSERT #SASA
	SELECT	getdate(),
			trc_driver,
			trc_driver2,
			trc_number,
			0
	  FROM	tractorprofile 
	 WHERE	NOT EXISTS (SELECT	*
						  FROM	#sasa
						 WHERE	#sasa.evt_tractor = trc_number)

UPDATE	#SASA
   SET	evt_driver1 = 'UNKNOWN' 
 WHERE	ISNULL(evt_driver1, '') = ''

UPDATE	#SASA
   SET	evt_driver2 = 'UNKNOWN'
 WHERE	ISNULL(evt_driver2, '') = ''

SELECT * FROM #sasa
GO
GRANT EXECUTE ON  [dbo].[sasa_query_sp] TO [public]
GO
