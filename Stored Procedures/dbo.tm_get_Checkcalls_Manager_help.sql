SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_get_Checkcalls_Manager_help]	
					@TruckNumber varchar(13),
					@DriverID varchar(10),
					@TrailerID varchar(13),
					@CheckCallNumber int,
					@MaxPositions int,
					@FromDate datetime,
					@ToDate datetime,
					@OrderByDate varchar(20),
					@OrderByDateOrder varchar(20)

AS

SET NOCOUNT ON 

DECLARE @sSQL NVARCHAR(4000)
DECLARE @sSQL_SUBSET NVARCHAR(4000)
DECLARE @sSQL_WHERE NVARCHAR(4000)

DECLARE @iStatus int, @iStatusToCheck int

if ISNULL(@TruckNumber, '') > ''
	BEGIN
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' Checkcall.ckc_number
			FROM Checkcall (nolock) '
		
		SET @sSQL_WHERE = ' WHERE ckc_Tractor = ''' + CONVERT(VARCHAR(12), @TruckNumber) + ''''
		
	END

if ISNULL(@DriverID, '') > ''
	BEGIN
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' Checkcall.ckc_number
			FROM Checkcall (nolock) '
		
		SET @sSQL_WHERE = ' WHERE ckc_asgntype = ''DRV'' AND ckc_asgnID = ''' + CONVERT(VARCHAR(12), @DriverID) + ''''

	END

if ISNULL(@TrailerID, '') > ''
	BEGIN
		-- Get the full position list into a temp table.
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' Checkcall.ckc_number
		FROM Checkcall (nolock) '
		
		SET @sSQL_WHERE = ' WHERE ckc_asgntype = ''TRL'' AND ckc_asgnID = ''' + CONVERT(VARCHAR(12), @TrailerID) + ''''

	END

if ISNULL(@TruckNumber, '') = '' 
	AND ISNULL(@DriverID, '') = '' 
	AND ISNULL(@TrailerID, '') = '' 
	AND ISNULL(@CheckCallNumber, 0) = 0 
	BEGIN
		-- Get the full position list into a temp table.
		IF ISNULL(@MaxPositions, 0) > 0 
			SET @sSQL_SUBSET = ' SELECT TOP ' + CONVERT(VARCHAR(12), @MaxPositions)
		ELSE
			SET @sSQL_SUBSET = ' SELECT'

		SET @sSQL_SUBSET = @sSQL_SUBSET + ' Checkcall.ckc_number
			FROM Checkcall (nolock) '

		SET @sSQL_WHERE = ''
		
	END

if ISNULL(@FromDate, '') <> ''
	BEGIN
	if @FromDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( ckc_date >= ''' + CONVERT(VARCHAR(30), @FromDate) + ''')'
	END
	
if ISNULL(@ToDate, '') <> ''
	BEGIN
	if @ToDate > '1/1/1901' 
		SET @sSQL_WHERE = @sSQL_WHERE + ' AND ( ckc_date <= ''' + CONVERT(VARCHAR(30), @ToDate) + ''')'
	END

SET @sSQL = @sSQL_SUBSET + ' ' + @sSQL_WHERE

if ISNULL(@OrderByDate, '') <> ''
	SET @sSQL = @sSQL + ' order by ' + @OrderByDate 
ELSE
	SET @sSQL = @sSQL + ' order by ckc_date'
	
if ISNULL(@OrderByDateOrder, '') <> ''
	SET @sSQL = @sSQL + ' ' + @OrderByDateOrder
ELSE
	SET @sSQL = @sSQL + ' desc'

PRINT @sSQL

EXEC sp_ExecuteSQL @sSQL

GO
GRANT EXECUTE ON  [dbo].[tm_get_Checkcalls_Manager_help] TO [public]
GO
