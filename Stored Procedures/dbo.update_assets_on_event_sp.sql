SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



CREATE PROCEDURE [dbo].[update_assets_on_event_sp] 	@tractor 	varchar(8),
						@driver1 	varchar(8),
						@driver2 	varchar(8),						
						@trailer1 	varchar(13),
						@lgh_num 	int,
						@mov_num 	int
AS

	UPDATE 	event
	SET 	evt_driver1 = @driver1,
		evt_driver2 = @driver2,
		evt_tractor = @tractor,
		evt_trailer2 = 'UNKNOWN', 
		evt_dolly = 'UNKNOWN', 
		evt_chassis = 'UNKNOWN', 
		evt_carrier = 'UNKNOWN'
	FROM 	event, stops
	WHERE 	stops.lgh_number = @lgh_num AND
		stops.stp_number = event.stp_number
	
	UPDATE 	event
	SET
		evt_trailer1 = @trailer1
	FROM 	event, stops
	WHERE 	stops.mov_number = @mov_num AND
		stops.stp_number = event.stp_number

GO
GRANT EXECUTE ON  [dbo].[update_assets_on_event_sp] TO [public]
GO
