SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
 
create procedure [dbo].[update_trip_mileage] (@pl_mov int)as
begin
	SET NOCOUNT ON
	declare @CalcStlmntMileageInDispatch as varchar (20)
	declare @stp_number int
	select @stp_number = 0


	--PTS 30877 CGK 3/20/2006
	select @CalcStlmntMileageInDispatch = Upper (Left(gi_string1,1)) from generalinfo where gi_name = 'CalcStlmntMileageInDispatch'
	IF @CalcStlmntMileageInDispatch = 'Y' Begin
		-- RE - PTS #45272 BEGIN
		SELECT	@stp_number = MIN(stops.stp_number) 
		  FROM	stops
					INNER JOIN event on stops.stp_number = event.stp_number and event.evt_sequence = 1
		 WHERE	stops.mov_number = @pl_mov 
		   AND	stops.stp_stl_mileage_flag IS NULL 
		   AND	stops.stp_number > @stp_number
		   AND	(event.evt_driver1 = 'UNKNOWN' OR ISNULL(stops.stp_trip_mileage, -1234) = -1234)
		   AND	ISNULL(stp_trip_mileage, -1234) <> ISNULL(stp_lgh_mileage, -1234)

		WHILE ISNULL(@stp_number, -1) <> -1
		BEGIN
			UPDATE	stops
			   SET	stp_trip_mileage = stp_lgh_mileage
			 WHERE	stp_number = @stp_number

			SELECT	@stp_number = MIN(stops.stp_number) 
			  FROM	stops
						INNER JOIN event on stops.stp_number = event.stp_number and event.evt_sequence = 1
			 WHERE	stops.mov_number = @pl_mov 
			   AND	stops.stp_stl_mileage_flag IS NULL 
			   AND	stops.stp_number > @stp_number
			   AND	(event.evt_driver1 = 'UNKNOWN' OR ISNULL(stops.stp_trip_mileage, -1234) = -1234)
			   AND	ISNULL(stp_trip_mileage, -1234) <> ISNULL(stp_lgh_mileage, -1234)
		END

--		while exists (select * from stops, event
--				where   stops.stp_number = event.stp_number
--				and event.evt_sequence = 1
--				and stops.mov_number = @pl_mov 
--				and stp_stl_mileage_flag is null 
--				and (evt_driver1 = 'UNKNOWN' or IsNull (stp_trip_mileage, -1234) = -1234)
--				and stops.stp_number > @stp_number )
--		begin
--			select @stp_number = min(stops.stp_number)
--			from stops, event
--				where   stops.stp_number = event.stp_number
--				and event.evt_sequence = 1
--				and stops.mov_number = @pl_mov 
--				and stp_stl_mileage_flag is null 
--				and (evt_driver1 = 'UNKNOWN' or IsNull (stp_trip_mileage, -1234) = -1234)
--				and stops.stp_number > @stp_number 
--			
--			
--			update 	stops 
--			set 	stp_trip_mileage = stp_lgh_mileage 
--			where   stp_number = @stp_number 
--				
--	
--		end
		-- RE - PTS #45272 END

	End
	Else Begin
		-- RE - PTS #45272 BEGIN
		SELECT	@stp_number = MIN(stp_number) 
		  FROM	stops
		 WHERE	mov_number = @pl_mov 
		   AND	stp_stl_mileage_flag IS NULL 
		   AND	stp_number > @stp_number
		   AND	ISNULL(stp_trip_mileage, -1234) <> ISNULL(stp_lgh_mileage, -1234)

		WHILE ISNULL(@stp_number, -1) <> -1
		BEGIN
			UPDATE	stops
			   SET	stp_trip_mileage = stp_lgh_mileage
			 WHERE	stp_number = @stp_number

			SELECT	@stp_number = MIN(stp_number) 
			  FROM	stops
			 WHERE	mov_number = @pl_mov 
			   AND	stp_stl_mileage_flag IS NULL 
			   AND	stp_number > @stp_number
			   AND	ISNULL(stp_trip_mileage, -1234) <> ISNULL(stp_lgh_mileage, -1234)
		END
--		while exists (select * from stops 
--				where   mov_number = @pl_mov and
--					stp_stl_mileage_flag is null and
--					stp_number > @stp_number and 
--					isnull(stp_trip_mileage, -1234) <> isnull(stp_lgh_mileage, -1234))
--		begin
--			select @stp_number = min(stp_number)
--			from stops
--			where   mov_number = @pl_mov and
--					stp_stl_mileage_flag is null and
--					stp_number > @stp_number and 
--					isnull(stp_trip_mileage, -1234) <> isnull(stp_lgh_mileage, -1234)
--			
--			
--			update 	stops 
--			set 	stp_trip_mileage = stp_lgh_mileage 
--			where   stp_number = @stp_number 
--				
--	
--		end
		-- RE - PTS #45272 END
	End

	return 1
end

GO
GRANT EXECUTE ON  [dbo].[update_trip_mileage] TO [public]
GO
