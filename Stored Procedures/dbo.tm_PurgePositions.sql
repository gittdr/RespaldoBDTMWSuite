SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_PurgePositions] (@TruckPositionAge int, @DriverPositionAge int)
AS

/* 2010-03-17  DWG  Purge routine for the Positions folder used by AA&D. */

SET NOCOUNT ON

DECLARE @WorkFolder int, @OldDate datetime, @vi_debug int

SET @vi_debug = 0

IF (@vi_debug > 0)
	SELECT 'Input parms' StepDesc, @TruckPositionAge PositionAge

-- Purge Truck Positions folders
IF @TruckPositionAge <> -1
BEGIN
	IF (@vi_debug > 0)
		SELECT 'In Truck Positions' StepDesc

	SELECT @OldDate = DATEADD(dd, -@TruckPositionAge, GetDate() )

	IF (@vi_debug > 0)
		SELECT 'Oldest Date' StepDesc, @OldDate OldDate

	SELECT @WorkFolder = ISNULL(MIN(PositionsBox), 0)
		FROM tblTrucks (NOLOCK)
		WHERE ISNULL(PositionsBox, 0) > 0

	WHILE @WorkFolder > 0
	BEGIN
		IF (@vi_debug > 0)
			SELECT 'Truck Position Processing' StepDesc, @WorkFolder WorkFolder
	
		execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
	
		SELECT @WorkFolder = ISNULL(MIN(PositionsBox), 0)
			FROM tblTrucks (NOLOCK)
			WHERE ISNULL(PositionsBox, 0) > 0 AND PositionsBox > @WorkFolder
	END
END

-- Purge Driver Positions folders
IF @DriverPositionAge <> -1
BEGIN
	IF (@vi_debug > 0)
		SELECT 'In Driver Positions' StepDesc

	SELECT @OldDate = DATEADD(dd, -@DriverPositionAge, GetDate() )

	IF (@vi_debug > 0)
		SELECT 'Oldest Date' StepDesc, @OldDate OldDate

	SELECT @WorkFolder = ISNULL(MIN(PositionsBox), 0)
		FROM tblDrivers (NOLOCK)
		WHERE ISNULL(PositionsBox, 0) > 0

	WHILE @WorkFolder > 0
	BEGIN
		IF (@vi_debug > 0)
			SELECT 'Driver Position Processing' StepDesc, @WorkFolder WorkFolder
	
		execute dbo.tm_PurgeFolder @WorkFolder, @OldDate
	
		SELECT @WorkFolder = ISNULL(MIN(PositionsBox), 0)
			FROM tblDrivers (NOLOCK)
			WHERE ISNULL(PositionsBox, 0) > 0 AND PositionsBox > @WorkFolder
	END
END

GO
GRANT EXECUTE ON  [dbo].[tm_PurgePositions] TO [public]
GO
