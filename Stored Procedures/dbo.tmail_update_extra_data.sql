SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tmail_update_extra_data] @ExtraID varchar(6), @TabID varchar(6), @ColID varchar(6), @Row varchar(6), @KeyData varchar(50), @ExtraData varchar(7665)
as
/* If the Row is nonnumeric or less than 0, then the actual data will be put onto the final row 
	which already has data in ANY column, AS LONG AS the value for this column in that row 
	is currently unset, blank, or 0.  If there is already a different value for this element
	then the next row will be used. */
-- edit history
-- HMA 12/10/14 - pts 65655 - adding col_datetime/getdate()	to last INSERT line in this proc

	SET NOCOUNT ON 
	
DECLARE @TestData varchar(7665), @RealRow int

IF ISNULL(@ExtraData, '') = '' RETURN	-- Do nothing if new value is blank.

SELECT @RealRow = -1
IF ISNUMERIC(@Row) <> 0 SELECT @RealRow = CONVERT(Int, @Row)
if @RealRow <= 0
	BEGIN
	--PRINT 'Auto Row'
		SELECT @RealRow = MAX(COL_ROW) 
		FROM EXTRA_INFO_DATA (NOLOCK)
		where EXTRA_ID = CONVERT(int, @ExtraID) AND TAB_ID = CONVERT(int, @TabID) AND TABLE_KEY = @KeyData
	IF @RealRow IS NOT NULL
		BEGIN
		--PRINT 'Last Row' + CONVERT(varchar(20), @RealRow)
			SELECT @TestData = COL_DATA 
			FROM EXTRA_INFO_DATA (NOLOCK)
			where EXTRA_ID = CONVERT(int, @ExtraID) AND TAB_ID = CONVERT(int, @TabID) AND TABLE_KEY = @KeyData AND COL_ID = CONVERT(int, @ColID) AND COL_ROW = @RealRow 
		--PRINT 'TestData:' + ISNULL(@TestData, '(null)')
		IF ISNULL(@TestData, '0') <> '0' AND ISNULL(@TestData, '') <> ''
			SELECT @RealRow = @RealRow + 1
		END
	ELSE
		SELECT @RealRow = 1
	END
--PRINT 'Final Row' + CONVERT(varchar(20), @RealRow)
if exists (select * 
			from EXTRA_INFO_DATA (NOLOCK)
			where EXTRA_ID = CONVERT(int, @ExtraID) AND TAB_ID = CONVERT(int, @TabID) 
			AND COL_ID = convert(int, @ColID) AND COL_ROW = @RealRow AND TABLE_KEY = @KeyData)
	UPDATE EXTRA_INFO_DATA SET COL_DATA = @ExtraData where EXTRA_ID = CONVERT(int, @ExtraID) 
	AND TAB_ID = CONVERT(int, @TabID) AND COL_ID = convert(int, @ColID) AND COL_ROW = @RealRow AND TABLE_KEY = @KeyData
ELSE
	INSERT INTO EXTRA_INFO_DATA (COL_DATA, EXTRA_ID, TAB_ID, COL_ID, COL_ROW, TABLE_KEY,col_datetime) VALUES (@ExtraData, CONVERT(int, @ExtraID), CONVERT(int, @TabID), CONVERT(int, @ColID), @RealRow, @KeyData,getdate())

GO
GRANT EXECUTE ON  [dbo].[tmail_update_extra_data] TO [public]
GO
