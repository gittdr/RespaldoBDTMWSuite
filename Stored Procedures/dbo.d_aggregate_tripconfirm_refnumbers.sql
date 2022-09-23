SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_aggregate_tripconfirm_refnumbers](@tractor_id varchar(8), @driver_id varchar(8), @trailer_id varchar(13), @carrier_id varchar(8), @start_date datetime, @end_date datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_aggregate_tripconfirm_refnumbers
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves reference numbers on aggregate trip confirm window
 *
 *
 * RESULT SETS: 
 * ord_hdrnumber
 * ord_number
 * ref_type
 * ref_number
 *
 * PARAMETERS:
@end_date datetime)
 * 001 - @tractor               varchar(8)     	Tractor id
 * 002 - @driver_id             varchar(8)     	driver id
 * 003 - @trailer_id           	varchar(13)	trailer id
 * 004 - @carrier_id            varchar(8)    	carrier id
 * 005 - @start_date            datetime       	Starting date to determine what legs to include
 * 006 - @end_date            	datetime	Ending date to determine what legs to include
 * 
 * 
 * REVISION HISTORY:
 * 12/14/2006 ? PTS35005 - JJF ? Original Release
 *
 36257 1-9-07, jg, rewrite using dynamic sql to avoid the multiple index scans on legheader table, and make it possible 
            for optimizer to use index seek on datetime column.
*/

DECLARE @StartDateCompare char(1), 
	@EndDateCompare char(1)
DECLARE @SQLString NVARCHAR(4000)
DECLARE @ParmDefinition NVARCHAR(1000)
DECLARE @Crlf as CHAR(1)
DECLARE @Debug as CHAR(1)

	SELECT 	@StartDateCompare = UPPER(LEFT(ISNULL(gi_string1, 'S'), 1)),
		@EndDateCompare = UPPER(LEFT(ISNULL(gi_string2, 'S'), 1))
	FROM	generalinfo  
	WHERE ( gi_name = 'QuickEntryOrderDateToUse' ) 


SET @Debug = 'N'
SET @Crlf = char(10) 

/*
	SELECT	o.ord_hdrnumber, 
		o.ord_number, 
		r.ref_type,
		r.ref_number
	FROM 	orderheader o 
		INNER JOIN legheader l ON o.mov_number = l.mov_number AND o.ord_invoicestatus <> 'PPD' 
		INNER JOIN referencenumber r on r.ref_tablekey = o.ord_hdrnumber AND r.ref_table = 'orderheader'
	WHERE 	((l.lgh_tractor = @tractor_id OR @tractor_id = 'UNKNOWN')
		AND (l.lgh_driver1 = @driver_id OR @driver_id = 'UNKNOWN')
		AND (l.lgh_primary_trailer = @trailer_id OR @trailer_id = 'UNKNOWN')
		AND (l.lgh_carrier = @carrier_id OR @carrier_id = 'UNKNOWN'))
		AND (Case @StartDateCompare 
			WHEN 'C' THEN o.ord_completiondate 
			WHEN 'L' THEN l.lgh_startdate 
			WHEN 'E' THEN l.lgh_enddate
			ELSE o.ord_startdate END >= @start_date)
		AND (Case @EndDateCompare 
			WHEN 'C' THEN o.ord_completiondate 
			WHEN 'L' THEN l.lgh_startdate 
			WHEN 'E' THEN l.lgh_enddate
			ELSE o.ord_startdate END <= @end_date)
	ORDER BY r.ref_type, 
		 r.ref_number
*/

SET @SQLString = 
	'SELECT	o.ord_hdrnumber, ' + @crlf +
		'o.ord_number, ' + @crlf +
		'r.ref_type, ' + @crlf +
		'r.ref_number ' + @crlf +
	'FROM 	orderheader o ' + @crlf +
		' INNER JOIN legheader l ON o.mov_number = l.mov_number AND o.ord_invoicestatus <> ''PPD''' + 
		' INNER JOIN referencenumber r on r.ref_tablekey = o.ord_hdrnumber AND r.ref_table = ''orderheader''' +
	' WHERE 1 = 1 ' + @crlf

	if @tractor_id <> 'UNKNOWN' 
	begin
		set @SQLString = @SQLString + 'AND l.lgh_tractor = @v_tractor_id' + @Crlf
	end
 
	if @driver_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND l.lgh_driver1 = @v_driver_id' + @Crlf
	end

	if @trailer_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND l.lgh_primary_trailer = @v_trailer_id' + @Crlf
	end

	if @carrier_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND l.lgh_carrier = @v_carrier_id' + @Crlf
	end

	select @SQLString = @SQLString + @Crlf + 'AND ' + 
				Case @StartDateCompare 
				WHEN 'C' THEN 'o.ord_completiondate' 
				WHEN 'L' THEN 'l.lgh_startdate'
				WHEN 'E' THEN 'l.lgh_enddate'
				ELSE 'o.ord_startdate' END + ' >= @v_start_date' + @Crlf
	
	select @SQLString = @SQLString + 'AND ' +
				Case @EndDateCompare 
				WHEN 'C' THEN 'o.ord_completiondate'
				WHEN 'L' THEN 'l.lgh_startdate' 
				WHEN 'E' THEN 'l.lgh_enddate'
				ELSE 'o.ord_startdate' END +' <= @v_end_date' + @Crlf

	select @SQLString = @SQLString + @Crlf + 'ORDER BY r.ref_type,' + @Crlf +
		 'r.ref_number'

SET @ParmDefinition = N'@v_tractor_id varchar(8), @v_driver_id varchar(8), @v_trailer_id varchar(13), @v_carrier_id varchar(8), @v_start_date datetime, @v_end_date datetime'

--denug generated sql stmt
if @Debug = 'Y' PRINT @SQLString

EXECUTE sp_executesql @SQLString, @ParmDefinition,
			@v_tractor_id = @tractor_id , 
			@v_driver_id = @driver_id, 
			@v_trailer_id = @trailer_id,
			@v_carrier_id = @carrier_id,
			@v_start_date = @start_date, 
			@v_end_date = @end_date

GO
GRANT EXECUTE ON  [dbo].[d_aggregate_tripconfirm_refnumbers] TO [public]
GO
