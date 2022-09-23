SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_Get_Position_Information]	
						@sPositionSN varchar(12),
						@sFlags varchar(12)
AS

	/* 08/29/11 DWG: PTS 54332 - Chnaged retrieval to be based on DateAndTime not SN */
	/* 08/30/11 DWG: PTS 54332 - Fixed flags and flag code */
	/* 09/27/11 DWG: PTS 51092 - Changed flag 32 to be last "processed" Position. */
	
	/* Flags
	1 = Previous Position relative to passed in SN
	2 = Previous Position in Motion
	4 = Previous Position not in Motion
	8 = Previous Unknown Motion Position
	16 = First Motion Position after last not in motion position
	32 = Last processed position for Unit
	64 = Next Position
	128 = First Non-Motion Position after last Motion position
	256 = Last Non-Motion Position after last Motion position and a Unknown stop was processed
	*/
SET NOCOUNT ON

	DECLARE @iPositionSN int,
			@iReturnPositionSN int,
			@iLastArrivePosition int,
			@iFlags int,
			@PositionDateAndTime datetime,
			@LastDateAndTime datetime,
			@PriorDateAndTime datetime

	if ISNULL(@sPositionSN, '') = ''
		BEGIN
		RAISERROR ('tm_Get_Position_Information:Position SN must be passed in.', 16, 1)
		RETURN
		END
	
	SET @iPositionSN = CONVERT(int, @sPositionSN)
	SET @iFlags = CONVERT(int, @sFlags)

	SELECT @PositionDateAndTime = DateAndTime 
	FROM tblLatLongs (NOLOCK)
	WHERE SN = @iPositionSN

	IF @iFlags & 1 > 0 --Previous Position
		BEGIN
		SELECT @iReturnPositionSN = MAX(SN) 
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
			GROUP BY DateAndTime
			ORDER BY DateAndTime
		END
	ELSE IF @iFlags & 2 > 0 --Previous Position in motion
		BEGIN
		SELECT @iReturnPositionSN = MAX(SN) 
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, 0) <> 0
			GROUP BY DateAndTime
			ORDER BY DateAndTime
		END
	ELSE IF @iFlags & 4 > 0 --Previous Position not in motion
		BEGIN
		SELECT @iReturnPositionSN = MAX(SN) 
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, 0) = 0
			GROUP BY DateAndTime
			ORDER BY DateAndTime
		END
	ELSE IF @iFlags & 8 > 0 --Previous Known Motion Position
		BEGIN
		SELECT @iReturnPositionSN = MAX(SN) 
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, -1) = -1
			GROUP BY DateAndTime
			ORDER BY DateAndTime
		END
	ELSE IF @iFlags & 16 > 0 --First Motion Position after last not in motion position
		BEGIN

		--find the last not in motion (arrive) position before this position
		SELECT @LastDateAndTime = MAX(DateAndTime)
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, -1) = 0

		--find the first in motion (depart) position that is between this position and the last arrived
		IF @LastDateAndTime IS NOT NULL
			BEGIN
				SELECT @PriorDateAndTime = MIN(DateAndTime)
					FROM tblLatLongs (NOLOCK)
					WHERE DateAndTime < @PositionDateAndTime
							AND DateAndTime > @LastDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs
											WHERE SN = @iPositionSN)
							AND ISNULL(TripStatus, -1) > 0

				if @PriorDateAndTime IS NOT NULL
					SELECT @iReturnPositionSN = SN 
					FROM tblLatLongs (NOLOCK)
						WHERE  DateAndTime = @PriorDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs (NOLOCK)
											WHERE SN = @iPositionSN)

			END
		END

	ELSE IF @iFlags & 32 > 0 --Last Processed Position
		BEGIN

		--find the last processed position
		SELECT @LastDateAndTime = MAX(DateAndTime)
			FROM tblLatLongs (NOLOCK)
			WHERE ISNULL(Status, 0) > 0 
				AND Unit = (SELECT Unit
									FROM tblLatLongs (NOLOCK)
									WHERE SN = @iPositionSN)
					
		IF @LastDateAndTime IS NOT NULL
			SELECT @iReturnPositionSN = SN 
			FROM tblLatLongs (NOLOCK) 
				WHERE  DateAndTime = @LastDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs (NOLOCK)
									WHERE SN = @iPositionSN)

		END

	ELSE IF @iFlags & 64 > 0 --Next Position
		BEGIN

		SELECT @iReturnPositionSN = MIN(SN) 
			FROM tblLatLongs (NOLOCK)
			WHERE DateAndTime > @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs (NOLOCK)
									WHERE SN = @iPositionSN)
			GROUP BY DateAndTime
			ORDER BY DateAndTime

		END

	ELSE IF @iFlags & 128 > 0 --First Non-Motion Position after last Motion position
		BEGIN

		--find the last Motion (Depart) position before this position
		SELECT @LastDateAndTime = MAX(DateAndTime)
			FROM tblLatLongs
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, -1) <> 0

		--find the first in Non-Motion (Arrive) position that is between this position and the last depart
		IF @LastDateAndTime IS NOT NULL
			BEGIN
				SELECT @PriorDateAndTime = MIN(DateAndTime)
					FROM tblLatLongs
					WHERE DateAndTime < @PositionDateAndTime
							AND DateAndTime > @LastDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs
											WHERE SN = @iPositionSN)
							AND ISNULL(TripStatus, -1) = 0

				if @PriorDateAndTime IS NOT NULL
					SELECT @iReturnPositionSN = SN FROM tblLatLongs 
						WHERE  DateAndTime = @PriorDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs
											WHERE SN = @iPositionSN)

			END
		END

	ELSE IF @iFlags & 256 > 0 --First Non-Motion Position after last Motion position and a Unknown stop was processed
		BEGIN

		--find the last Motion (Depart) position before this position
		SELECT @LastDateAndTime = MAX(DateAndTime)
			FROM tblLatLongs
			WHERE DateAndTime < @PositionDateAndTime
					AND Unit = (SELECT Unit
									FROM tblLatLongs
									WHERE SN = @iPositionSN)
					AND ISNULL(TripStatus, -1) <> 0

		--find the last in Non-Motion (Arrive) position that is between this position and the last depart
		IF @LastDateAndTime IS NOT NULL
			BEGIN
				SELECT @PriorDateAndTime = MAX(DateAndTime)
					FROM tblLatLongs
					WHERE DateAndTime < @PositionDateAndTime
							AND DateAndTime > @LastDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs
											WHERE SN = @iPositionSN)
							AND ISNULL(TripStatus, -1) = 0
							AND (ISNULL(Status, -1) & 8192) > 0

				if @PriorDateAndTime IS NOT NULL
					SELECT @iReturnPositionSN = SN FROM tblLatLongs 
						WHERE  DateAndTime = @PriorDateAndTime
							AND Unit = (SELECT Unit
											FROM tblLatLongs
											WHERE SN = @iPositionSN)

			END
		END

	ELSE
		SET @iReturnPositionSN =@iPositionSN


	--see if we still have a position SN
	IF ISNULL(@iReturnPositionSN, 0) > 0 
		SELECT tblLatLongs.SN, Unit, DateAndTime, Lat, Long, Lat * 3600 as [LatSec], Long * 3600 as [LongSec], 
		Remark, UpdatePS, Quality, Landmark, Miles, Direction, CityName, State, Zip, 
		NearestLargeCityName, NearestLargeCityState, NearestLargeCityZip, NearestLargeCityDirection, 
		NearestLargeCityMiles, VehicleIgnition, UpdateDisp, GetDate() as NOW, UnitID, LinkedAddrType, 
		LinkedObjSN, InstanceId, Odometer, TripStatus, odometer2, speed, speed2, heading, gps_type, gps_miles, fuel_meter, idle_meter, AssociatedMsgSN, STATUS, StatusReason
			FROM tblLatLongs (NOLOCK)
			INNER JOIN tblCabUnits (NOLOCK) ON tblCabUnits.SN = Unit
			WHERE tblLatLongs.SN = ISNULL(@iReturnPositionSN, -1)
			ORDER BY tblLatLongs.SN
	ELSE
		SELECT tblLatLongs.SN, Unit, DateAndTime, Lat, Long, Lat * 3600 as [LatSec], Long * 3600 as [LongSec], 
		Remark, UpdatePS, Quality, Landmark, Miles, Direction, CityName, State, Zip, NearestLargeCityName, 
		NearestLargeCityState, NearestLargeCityZip, NearestLargeCityDirection, NearestLargeCityMiles, 
		VehicleIgnition, UpdateDisp, GetDate() as NOW, UnitID, LinkedAddrType, LinkedObjSN, InstanceId, 
		Odometer, TripStatus, odometer2, speed, speed2, heading, gps_type, gps_miles, fuel_meter, idle_meter, AssociatedMsgSN, STATUS, StatusReason
			FROM tblLatLongs (NOLOCK)
			INNER JOIN tblCabUnits (NOLOCK) ON tblCabUnits.SN = Unit
			WHERE 1=2

GO
GRANT EXECUTE ON  [dbo].[tm_Get_Position_Information] TO [public]
GO
