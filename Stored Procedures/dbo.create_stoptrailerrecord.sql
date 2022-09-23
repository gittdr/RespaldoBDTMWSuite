SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

			
		CREATE PROC [dbo].[create_stoptrailerrecord] @mov integer
		AS
		
		/**************************************************************************************************
		Object Description:

		Proc to update the StopTrailer record on stops with a Drop Event
		for a movement to indicate that the Trailer was Dropped on that Event. 
		This is typically handled in the Operations application and Totalmail, but 
		a customer upgraded Ops without updating Totalmail and it is preventing
		editing of a Trip (in Ops) once Totalmail has completed a Drop stop
		without setting the Drop flag on the corresponding StopTrailer record.


		NOTE: This only works for trailer1. 

		  Date         Name             Label/PTS    Description
		  -----------  ---------------  ----------  ----------------------------------------
		  7/11/2016	   Doug McRowe		            Initial version
		  7/28/2016    Mark Hampton     104514      Modified to delete if trailer reset to UNKNOWN,
													insert rows for all trailer stops, restrict
													inserted not exists to bucket 1, and update
													drop status on all stops, not just completed ones.
		 8/10/2016	   Mike Luoma		104468      Merge into NSuite Sprint.  If the StopTrailer table 
													does not exist create this stub proc
		**************************************************************************************************/

		DECLARE @movstps TABLE(stp_number INTEGER NOT NULL,
			strl_bucket TINYINT NOT NULL,
			trl_id VARCHAR(13) NULL,
			stp_lgh_status VARCHAR(6) NULL,
			stp_departure_status VARCHAR(6) NULL,
			stp_event VARCHAR(6) NOT NULL,
			stp_isdrop CHAR(1) NOT NULL
			PRIMARY KEY (stp_number,strl_bucket))

		SET NOCOUNT ON 

		INSERT INTO @movstps
		SELECT Distinct s.stp_number,
		1, 
		e.evt_trailer1,
		s.stp_lgh_status,
		s.stp_departure_status,
		s.stp_event,
		CASE 
			WHEN (SELECT 1 FROM eventcodetable WHERE mile_typ_from_stop = 'BT' AND ect_trlend = 'Y' AND abbr = stp_event) = 1 THEN 'Y'
			WHEN stp_event = 'CTR' THEN 'Y'
			ELSE 'N'
		END
		FROM stops s LEFT JOIN stoptrailer st ON s.stp_number = st.stp_number
			JOIN event e ON s.stp_number = e.stp_number
		WHERE s.mov_number = @mov
			AND e.evt_sequence = 1
			AND isnull(e.evt_trailer1, 'UNKNOWN') <> 'UNKNOWN'

		INSERT INTO @movstps
		SELECT Distinct s.stp_number,
		2, 
		e.evt_trailer2,
		s.stp_lgh_status,
		s.stp_departure_status,
		s.stp_event,
		CASE 
			WHEN (SELECT 1 FROM eventcodetable WHERE mile_typ_from_stop = 'BT' AND ect_trlend = 'Y' AND abbr = stp_event) = 1 THEN 'Y'
			WHEN stp_event = 'CTR' THEN 'Y'
			ELSE 'N'
		END
		FROM stops s LEFT JOIN stoptrailer st ON s.stp_number = st.stp_number
			JOIN event e ON s.stp_number = e.stp_number
		WHERE s.mov_number = @mov
			AND e.evt_sequence = 1
			AND isnull(e.evt_trailer1, 'UNKNOWN') <> 'UNKNOWN'


		-- Remove any stoptrailer records for unknown trailers
		DELETE stoptrailer 
		FROM stops s JOIN event e ON s.stp_number = e.stp_number AND e.evt_sequence = 1
		WHERE s.stp_number = stoptrailer.stp_number
		AND s.mov_number = @mov
		AND ((stoptrailer.strl_bucket = 1
		AND e.evt_trailer1 = 'UNKNOWN')
		OR (stoptrailer.strl_bucket = 2
		AND e.evt_trailer2 = 'UNKNOWN'));

		-- Create a stop record for any stop that requires one and one does not already exist
		INSERT INTO stoptrailer (stp_number, trl_id, strl_bucket, strl_dropped)
		SELECT ms.stp_number,
			trl_id,
			ms.strl_bucket,
			ms.stp_isdrop
		FROM @movstps ms JOIN event e ON ms.stp_number = e.stp_number AND e.evt_sequence = 1
		WHERE NOT EXISTS (SELECT 1 FROM stoptrailer WHERE stoptrailer.stp_number = ms.stp_number AND stoptrailer.strl_bucket = ms.strl_bucket)
			AND ((e.evt_trailer1 <> 'UNKNOWN'
			AND ms.strl_bucket = 1)
			 OR (e.evt_trailer2 <> 'UNKNOWN'
			AND ms.strl_bucket = 2));
	
		-- Since TM is not updating the Trailer on stops, need to verify that the trailer on StopTrailer record is the 
	
GO
GRANT EXECUTE ON  [dbo].[create_stoptrailerrecord] TO [public]
GO
