SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[cloneorderextrainfo](
-- PTS 27194 -- BL (start)
--	@source_ord_hdrnumber int,
--	@new_ord_hdrnumber int)
	@source_ord_hdrnumber varchar(15),
	@new_ord_hdrnumber varchar(15))
-- PTS 27194 -- BL (end)
AS
	--PTS 25955 JJF
	--Unfortunately, a trigger on EXTRA_INFO_DATA cannot cope with 
	--multiple updates, this loop had to be used to feed each 
	--record one at a time
	--The trigger is babysitting some redundant extra info remnants
	--in order header.
	--If this weren't the case, this could've been a trivial INSERT(SELECT)

	--PTS 26663 JJF
	--Server cursor was deemed not good, so this was re-written to use a temp table loop

	DECLARE @EXTRA_ID	int,
		@TAB_ID		int,
		@COL_ID		int,	
		@COL_DATA	varchar(7665),
		@COL_ROW	int,
		@col_datetime	datetime,
		@col_number	decimal(12, 4)

	DECLARE @COPY_PTR	int,
		@COPY_COUNT	int

	DECLARE @PKey 		int

	--Create a temp table to hold the extra info records we intend to copy

	CREATE TABLE #ExtraInfo(
		PKey int NOT NULL IDENTITY (1, 1),
		EXTRA_ID int NOT NULL,
		TAB_ID int NOT NULL, 
		COL_ID int NOT NULL,
		COL_DATA varchar(7665) NULL, 
		COL_ROW int NOT NULL,
		col_datetime datetime NULL,
		col_number decimal(12,4) NULL)
	
	INSERT INTO #ExtraInfo(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, COL_ROW, col_datetime, col_number)
	SELECT 	e.EXTRA_ID, e.TAB_ID, e.COL_ID, e.COL_DATA, e.COL_ROW, e.col_datetime, e.col_number
	FROM 	EXTRA_INFO_DATA e
	WHERE	e.TABLE_KEY = @source_ord_hdrnumber AND e.EXTRA_ID = 7 AND
			NOT EXISTS(SELECT	* FROM EXTRA_INFO_DATA d
						WHERE	d.TABLE_KEY = @new_ord_hdrnumber AND
								d.EXTRA_ID = e.EXTRA_ID AND
								d.COL_ID = e.COL_ID AND
								d.COL_ROW = e.COL_ROW)

	--Loop through 
	SELECT TOP 1 @PKey = e.PKey, @EXTRA_ID = e.EXTRA_ID, @TAB_ID = e.TAB_ID, @COL_ID = e.COL_ID, @COL_DATA=  e.COL_DATA, @COL_ROW = e.COL_ROW, @col_datetime = e.col_datetime, @col_number = e.col_number
	FROM 	#ExtraInfo e
	ORDER BY e.PKey

	SELECT @COPY_COUNT = count(*) FROM #ExtraInfo
	SET @COPY_PTR = 0

	WHILE (@COPY_PTR < @COPY_COUNT) BEGIN
		INSERT EXTRA_INFO_DATA(EXTRA_ID, TAB_ID, COL_ID, COL_DATA, TABLE_KEY, COL_ROW, col_datetime, col_number)
		VALUES(@EXTRA_ID, @TAB_ID, @COL_ID, @COL_DATA, @new_ord_hdrnumber, @COL_ROW, @col_datetime, @col_number)

		SELECT TOP 1 @PKey = e.PKey, @EXTRA_ID = e.EXTRA_ID, @TAB_ID = e.TAB_ID, @COL_ID = e.COL_ID, @COL_DATA=  e.COL_DATA, @COL_ROW = e.COL_ROW, @col_datetime = e.col_datetime, @col_number = e.col_number
		FROM 	#ExtraInfo e
		WHERE 	e.PKey > @PKey 
		ORDER BY e.PKey

		SET @COPY_PTR = @COPY_PTR + 1
	END
GO
GRANT EXECUTE ON  [dbo].[cloneorderextrainfo] TO [public]
GO
