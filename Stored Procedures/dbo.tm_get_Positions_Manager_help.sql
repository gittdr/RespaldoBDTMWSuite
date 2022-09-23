SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_get_Positions_Manager_help]	
					@TruckSN int,
					@DriverSN int,
					@CabUnitSN int,
					@PositionSN int,
					@MaxPositions int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20),
					@Status varchar(12)

AS

DECLARE @sSQL NVARCHAR(4000)
DECLARE @sSQL_SUBSET NVARCHAR(4000)
DECLARE @sSQL_WHERE NVARCHAR(4000)

DECLARE @iStatus int, @iStatusToCheck int

if ISNULL(@TruckSN, 0) > 0
	BEGIN

		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblLatLongs.SN
			FROM tbllatlongs (nolock)
			INNER JOIN tblCabUnits ON tblCabUnits.SN = tbllatlongs.Unit '

		SET @sSQL_WHERE = ' WHERE tblCabUnits.LinkedObjSN = ' + CONVERT(VARCHAR(12), @TruckSN) + ' AND tblCabUnits.LinkedAddrType = 4 '

	END

if ISNULL(@DriverSN, 0) > 0
	BEGIN
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblLatLongs.SN
		FROM tbllatlongs (nolock)
		INNER JOIN tblCabUnits ON tblCabUnits.SN = tbllatlongs.Unit '

		SET @sSQL_WHERE = ' WHERE tblCabUnits.LinkedObjSN = ' + CONVERT(VARCHAR(12), @DriverSN) + ' AND tblCabUnits.LinkedAddrType = 5 '

	END

if ISNULL(@CabUnitSN, 0) > 0
	BEGIN

		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblLatLongs.SN
			FROM tbllatlongs (nolock) '

		SET @sSQL_WHERE = ' WHERE Unit = ' + CONVERT(VARCHAR(12), @CabUnitSN)

	END

if ISNULL(@TruckSN, 0) = 0 
	AND ISNULL(@DriverSN, 0) = 0 
	AND ISNULL(@CabUnitSN, 0) = 0 
	AND ISNULL(@PositionSN, 0) = 0 
	BEGIN
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' tblLatLongs.SN
			FROM tbllatlongs (nolock)
			INNER JOIN tblCabUnits ON tblCabUnits.SN = tbllatlongs.Unit '

		SET @sSQL_WHERE = ''

	END

if ISNULL(@FromDate, '') <> ''
	BEGIN
	if @FromDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( DateAndTime >= ''' + CONVERT(VARCHAR(30), @FromDate) + ''')'
	END

if ISNULL(@ToDate, '') <> ''
	BEGIN
	if @ToDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( DateAndTime <= ''' + CONVERT(VARCHAR(30), @ToDate) + ''')'
	END

if @Status IS NOT NULL
	BEGIN
		if ISNUMERIC(@Status) = 1
		BEGIN
			IF @Status = '0'
			BEGIN
				SET @sSQL_WHERE = @sSQL_WHERE + ' AND (ISNULL(Status, 0) = 0)'
				SET @iStatus = @iStatus + 1
			END
			ELSE
			BEGIN
				SET @iStatus = 1
				SET @iStatusToCheck = 1
				WHILE @iStatus < 11
				BEGIN
					SET @iStatusToCheck = @iStatusToCheck ^ 2
					If @iStatus & @iStatusToCheck > 0
						SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( ISNULL(Status, 0) & ' + RTRIM(LTRIM(@Status)) + ' > 0)'
					SET @iStatus = @iStatus + 1
				END
			END
		END
	END

SET @sSQL = @sSQL_SUBSET + ' ' + @sSQL_WHERE

if ISNULL(@OrderByDate, '') <> ''
	SET @sSQL = @sSQL + ' ORDER BY ' + @OrderByDate 
ELSE
	SET @sSQL = @sSQL + ' ORDER BY DateAndTime'
	
if ISNULL(@OrderByDateOrder, '') <> ''
	SET @sSQL = @sSQL + ' ' + @OrderByDateOrder
ELSE
	SET @sSQL = @sSQL + ' desc'

PRINT @sSQL

EXEC sp_ExecuteSQL @sSQL

GO
GRANT EXECUTE ON  [dbo].[tm_get_Positions_Manager_help] TO [public]
GO
