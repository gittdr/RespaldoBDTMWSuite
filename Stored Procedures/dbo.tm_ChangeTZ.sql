SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Some Timezones:
-- Note that DSTCodes only matter if DST applies.  For those regions with
--   "X", you may pass any number for DSTCode because it will be ignored.
--     Region               TimeZone     DSTCode   AddlMins
--     US: Ohio             5            0            0
--     US: Indianapolis     5            -1           0
--     US: Chicago          6            0            0
--     US: Denver           7            0            0
--     US: Arizona          7            -1           0
--     US: California       8            0            0
--     Canada: NewFoundland 3            0            30
--     Canada: Nova Scotia  4            0            0
--     Canada: Quebec       5            0            0
--     Canada: Manitoba     6            0            0
--     Canada: Sasketchawan 6            -1           0
--     Canada: Alberta      7            0            0
--     Canada: BC (Most)    8            0            0
--     England              0            1            0
--     France & Germany     -1           1            0
--     Greece & Romania     -2           1            0
--     Ukraine              -2           1            0
--     Russia: Kaliningrad  -2           1            0
--     Russia: Moscow       -3           1            0
--     Russia: Vladivostok  -10          1            0
--     Russia: Kamchatka    -12          1            0
--     China                -8           -1           0
--     Afghanistan          -4           -1           -30
--     Brazil (Southeast)   3            2            0
--     Brazil (Northeast)   3            -1           0
--     Brazil (Southwest)   4            2            0
--     Brazil (Northwest)   4            -1           0
CREATE PROCEDURE [dbo].[tm_ChangeTZ](@sSourceDate VARCHAR(30), 
								@sSourceTZ VARCHAR(10), 
								@sSourceDSTCode VARCHAR(10), 
								@sSourceTZAddlMins VARCHAR(10), 
								@sDestTZ VARCHAR(10), 
								@sDestDSTCode VARCHAR(10), 
								@sDestTZAddlMins VARCHAR(10),
								@slFlags VARCHAR(12))
AS

DECLARE @ResultDate datetime

BEGIN
    DECLARE @ZuluDate datetime, 
			@SourceDate datetime, 
			@SourceTZ int,
			@SourceDSTCode int,
	 		@SourceTZAddlMins int,
			@DestTZ int,
			@DestDSTCode int,
			@DestTZAddlMins int
	
	if ISDATE(@sSourceDate) = 1
		SET @SourceDate = convert(datetime, @sSourceDate)
	else
		BEGIN
		RAISERROR('Source date must be passed in and must be a date', 16,1 )
		RETURN
		END

	SET @SourceTZ = CONVERT(int, @sSourceTZ)
	SET @SourceDSTCode = CONVERT(int, @sSourceDSTCode)
	SET @SourceTZAddlMins = CONVERT(int, @sSourceTZAddlMins)
	SET @DestTZ = CONVERT(int, @sDestTZ)
	SET @DestDSTCode = CONVERT(int, @sDestDSTCode)
	SET @DestTZAddlMins = CONVERT(int, @sDestTZAddlMins)

	SELECT dbo.ChangeTZ(@SourceDate, @SourceTZ, @SourceDSTCode, @SourceTZAddlMins, @DestTZ, @DestDSTCode, @DestTZAddlMins ) ResultDate
	
END

GO
GRANT EXECUTE ON  [dbo].[tm_ChangeTZ] TO [public]
GO
