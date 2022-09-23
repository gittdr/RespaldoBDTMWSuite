SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_notes_by_parms_sp] (@tractor_id varchar(8), @driver_id varchar(8), @trailer_id varchar(13), @carrier_id varchar(8), @start_date datetime, @end_date datetime)
AS
/**
 * 
 * NAME:
 * dbo.d_notes_by_parms_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves notes associated with assets and orders in trip confirm
 *
 *
 * RESULT SETS: 
 * not_number, 
 * not_text, 
 * not_type, 
 * not_urgent, 
 * not_expires, 
 * ntb_table, 
 * nre_tablekey, 
 * not_sequence, 
 * last_updatedby,
 * last_updatedatetime,
 * not_viewlevel
 *
 * PARAMETERS:
 * 001 - @tractor               varchar(8)     	Tractor id
 * 002 - @driver_id             varchar(8)     	driver id
 * 003 - @trailer_id           	varchar(13)	trailer id
 * 004 - @carrier_id            varchar(8)    	carrier id
 * 005 - @start_date            datetime       	Starting date to determine what legs to include
 * 006 - @end_date            	datetime	Ending date to determine what legs to include *
 
 * 
 * REVISION HISTORY:
 * 12/14/2006 ? PTS35005 - JJF ? Original Release
 * 11/28/06 - 36257 - (JJF/JGUO)  use nolock hint to avoid blocking due to potential index scan on legheader table
 * 36257 1-9-07, jg, rewrite using dynamic sql to avoid the multiple index scans on legheader table, and make it possible 
 *            for optimizer to use index seek on datetime column.
 **/

DECLARE @StartDateCompare char(1),
	@EndDateCompare char(1)
DECLARE @SQLString NVARCHAR(4000)
DECLARE @ParmDefinition NVARCHAR(1000)
DECLARE @Crlf as CHAR(1)
DECLARE @Debug as CHAR(1)

--PTS 36939 JJF 20070911
declare @showexpired char(1)
declare @grace integer
--END PTS 36939 JJF 20070911

CREATE TABLE #legassets
	(lgh_tractor		varchar(8),
	lgh_driver1		varchar(8),
	lgh_primary_trailer	varchar(13),
	lgh_carrier		varchar(8),
	ord_number		char(12),	
	cmd_code		varchar(8) NULL)

SELECT @StartDateCompare = UPPER(LEFT(ISNULL(gi_string1, 'S'), 1)),
	@EndDateCompare = UPPER(LEFT(ISNULL(gi_string2, 'S'), 1))
FROM	generalinfo  
WHERE ( gi_name = 'QuickEntryOrderDateToUse' ) 

--PTS 36939 JJF 20070911
select @showexpired =isnull(gi_string1,'Y')
from generalinfo
where gi_name = 'showexpirednotes'

select @grace =isnull(gi_integer1,0)
from generalinfo
where gi_name = 'showexpirednotesgrace'
--END PTS 36939 JJF 20070911

--jg, dynamic sql begin
/*
INSERT INTO #legassets
SELECT 	l.lgh_tractor,
	l.lgh_driver1,
	l.lgh_primary_trailer,
	l.lgh_carrier,
	o.ord_number,
	o.cmd_code
--11/28/06 - 36257 - (JJF/JGUO)  use nolock hint to avoid blocking due to potential index scan on legheader table
--FROM 	orderheader o
--	INNER JOIN legheader l ON o.mov_number = l.mov_number 
FROM 	orderheader o with(nolock)
	INNER JOIN legheader l with(nolock) ON o.mov_number = l.mov_number 
--END 11/28/06 - 36257 - (JJF/JGUO)  use nolock hint to avoid blocking due to potential index scan on legheader table
WHERE o.ord_invoicestatus <> 'PPD' AND
	((l.lgh_tractor = @tractor_id OR @tractor_id = 'UNKNOWN') AND 
	(l.lgh_driver1 = @driver_id OR @driver_id = 'UNKNOWN') AND
	(l.lgh_primary_trailer = @trailer_id OR @trailer_id = 'UNKNOWN') AND
	(l.lgh_carrier = @carrier_id OR @carrier_id = 'UNKNOWN')) AND
	Case @StartDateCompare WHEN 'C' THEN o.ord_completiondate 
			WHEN 'L' THEN l.lgh_startdate 
			WHEN 'E' THEN l.lgh_enddate
			ELSE o.ord_startdate END >= @start_date AND
	Case @EndDateCompare WHEN 'C' THEN o.ord_completiondate 
			WHEN 'L' THEN l.lgh_startdate 
			WHEN 'E' THEN l.lgh_enddate
			ELSE o.ord_startdate END <= @end_date
*/
SET @Debug = 'N'
SET @Crlf = char(10) 

SET @SQLString = 
'INSERT INTO #legassets' + @Crlf + 
' SELECT 	l.lgh_tractor,' + @Crlf + 
	'l.lgh_driver1,' + @Crlf + 
	'l.lgh_primary_trailer,' + @Crlf + 
	'l.lgh_carrier,' + @Crlf + 
	'o.ord_number,' + @Crlf + 
	'o.cmd_code' + @Crlf + 
' FROM 	orderheader o' + @Crlf + 
	' INNER JOIN legheader l ON o.mov_number = l.mov_number' + @Crlf + 
' WHERE o.ord_invoicestatus <> ''PPD'' ' + @Crlf

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
--jg, dynamic sql end

SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.lgh_driver1 and n.ntb_table = 'manpowerprofile')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

UNION 
SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.lgh_tractor and n.ntb_table = 'tractorprofile')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

UNION

SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.lgh_primary_trailer and n.ntb_table = 'trailerprofile')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

UNION
SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.lgh_carrier and n.ntb_table = 'carrier')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

UNION
SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.ord_number and n.ntb_table = 'orderheader')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

UNION
SELECT DISTINCT n.not_number, 
		n.not_text, 
		n.not_type, 
		n.not_urgent, 
		n.not_expires, 
		n.ntb_table, 
		n.nre_tablekey, 
		n.not_sequence, 
		n.last_updatedby,
		n.last_updatedatetime,
		n.not_viewlevel
FROM 	#legassets l 
	INNER JOIN notes n ON (n.nre_tablekey = l.cmd_code and n.ntb_table = 'commodity')
	--PTS 36939 JJF 20070911
	and	IsNull(DATEADD(day, @grace, not_expires), getdate()) >= 
			case @showexpired 
				when 'N' then getdate()
				else  IsNull(DATEADD(day, @grace, not_expires), getdate()) 
			end
	--END PTS 36939 JJF 20070911

GO
GRANT EXECUTE ON  [dbo].[d_notes_by_parms_sp] TO [public]
GO
