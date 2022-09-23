SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_aggregate_tripconfirm_sequence] (@ref_type varchar(6), @start_date datetime, @end_date datetime, @tractor_id varchar(8), @driver_id varchar(8), @trailer_id varchar(13), @carrier_id varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_aggregate_tripconfirm_sequence
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves trips for sequencing purposes
 *
 *

 * RESULT SETS: 
 * sequence	placeholder to store re-sequencing order
 * ord_number
 * ord_shipper
 * ord_destpoint
 * mov_number
 * ord_hdrnumber
 * min_ref_sequence
 * ord_startdate
 * ord_completiondate
 * ord_status
 * invoice_flag
 * modified_flag
 * include_flag
 * action
 * actionresult
 * actionresultdescription
 * mfh_number
 * lgh_number
 * shp_cmp_name
 * dest_cmp_name
 * cmd_code
 * cmd_name
 * ord_remark
 * shp_cty_nmstct
 * dest_cty_nmstct
 * lgh_tractor
 * lgh_driver1
 * lgh_primary_trailer
 * lgh_carrier
 * lgh_startdate
 * lgh_enddate
 * ord_origin_earliestdate
 * ord_origin_latestdate    
 * ord_dest_earliestdate     
 * ord_dest_latestdate
 *
 * PARAMETERS:

 * 001 - @ref_type		varchar(6)	Reference type
 * 002 - @start_date            datetime       	Starting date to determine what legs to include
 * 003 - @end_date            	datetime	Ending date to determine what legs to include
 * 004 - @tractor               varchar(8)     	Tractor id
 * 005 - @driver_id             varchar(8)     	driver id
 * 006 - @trailer_id           	varchar(13)	trailer id
 * 007 - @carrier_id            varchar(8)    	carrier id
 * 
 * 
 * REVISION HISTORY:
 * 12/14/2006 ? PTS35005 - JJF ? Original Release
 *
 36257 1-9-07, jg, rewrite using dynamic sql to avoid the multiple index scans on legheader table, and make it possible 
            for optimizer to use index seek on datetime column.
*/
DECLARE @StartDateCompare char(1), @EndDateCompare char(1)
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
	SELECT DISTINCT	0 as sequence, 
			o.ord_number,   
			o.ord_shipper,   
			o.ord_destpoint,   
			o.mov_number,   
			o.ord_hdrnumber,
			(SELECT MAX(ref_number)
				FROM
				(select ref_tablekey, min (ref_sequence) as min_ref_sequence
					from referencenumber
					where ref_table = 'orderheader'
					and ref_type = @ref_type
					group by ref_tablekey) ra,
				(select * from referencenumber
					where ref_table = 'orderheader'
					and ref_type = @ref_type) rb
			WHERE ra.ref_tablekey = rb.ref_tablekey 
				AND ra.min_ref_sequence = rb.ref_sequence 
				AND ra.ref_tablekey = o.ord_hdrnumber) as fuel_ref_number,
			o.ord_startdate,
			o.ord_completiondate,
			o.ord_status,
			'N' as invoice_flag,
			'N' as modified_flag,
			'N' as include_flag,
			'N' as action,
			'N' as actionresult,
			SPACE(254) as actionresultdescription,
			l.mfh_number,
			l.lgh_number,
		  	shpcmp.cmp_name AS shp_cmp_name, 
			destcmp.cmp_name AS dest_cmp_name,
			o.cmd_code, 
			cmd.cmd_name,
			o.ord_remark,
			shpcmp.cty_nmstct as shp_cty_nmstct, 
			destcmp.cty_nmstct as dest_cty_nmstct,
			l.lgh_tractor,
			l.lgh_driver1,
			l.lgh_primary_trailer,
			l.lgh_carrier,
			l.lgh_startdate,
			l.lgh_enddate,
			o.ord_origin_earliestdate,     
			o.ord_origin_latestdate,     
			o.ord_dest_earliestdate,     
			o.ord_dest_latestdate
	FROM 	--assetassignment a
		legheader l 
		--INNER JOIN stops s ON a.mov_number = s.mov_number 
		INNER JOIN orderheader o ON l.mov_number = o.mov_number AND o.ord_invoicestatus <> 'PPD' 
		INNER JOIN company shpcmp ON o.ord_shipper = shpcmp.cmp_id 
		INNER JOIN company destcmp ON o.ord_destpoint = destcmp.cmp_id
		LEFT OUTER JOIN commodity cmd ON o.cmd_code = cmd.cmd_code
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

*/

SET @SQLString = 
	'SELECT DISTINCT	0 as sequence, ' + @Crlf +
			'o.ord_number, ' + @Crlf + 
			'o.ord_shipper, ' + @Crlf +
			'o.ord_destpoint, ' + @Crlf +
			'o.mov_number, ' + @Crlf +
			'o.ord_hdrnumber, ' + @Crlf +
			'(SELECT MAX(ref_number) ' + @Crlf +
				' FROM ' + @Crlf +
				'(select ref_tablekey, min (ref_sequence) as min_ref_sequence ' + @Crlf +
					'from referencenumber ' + @Crlf +
					'where ref_table = ''orderheader''' + @Crlf +
					'and ref_type = @v_ref_type ' + @Crlf +
					'group by ref_tablekey) ra, ' + @Crlf +
				'(select * from referencenumber' + @Crlf +
					'where ref_table = ''orderheader''' + @Crlf +
					'and ref_type = @v_ref_type) rb ' + @Crlf +
			'WHERE ra.ref_tablekey = rb.ref_tablekey' + @Crlf +
				'AND ra.min_ref_sequence = rb.ref_sequence ' + @Crlf +
				'AND ra.ref_tablekey = o.ord_hdrnumber) as fuel_ref_number, ' + @Crlf +
			'o.ord_startdate, ' + @Crlf +
			'o.ord_completiondate,' + @Crlf +
			'o.ord_status, ' + @Crlf +
			'''N'' as invoice_flag, ' + @Crlf +
			'''N'' as modified_flag, ' + @Crlf +
			'''N'' as include_flag, ' + @Crlf +
			'''N'' as action, ' + @Crlf +
			'''N'' as actionresult, ' + @Crlf +
			'SPACE(254) as actionresultdescription,' + @Crlf +
			'l.mfh_number,' + @Crlf +
			'l.lgh_number,' + @Crlf +
		  	'shpcmp.cmp_name AS shp_cmp_name,' + @Crlf +
			'destcmp.cmp_name AS dest_cmp_name,' + @Crlf +
			'o.cmd_code, ' + @Crlf +
			'cmd.cmd_name, ' + @Crlf +
			'o.ord_remark, '+ @Crlf +
			'shpcmp.cty_nmstct as shp_cty_nmstct, ' + @Crlf +
			'destcmp.cty_nmstct as dest_cty_nmstct,' + @Crlf +
			'l.lgh_tractor,' + @Crlf +
			'l.lgh_driver1,' + @Crlf +
			'l.lgh_primary_trailer,' + @Crlf +
			'l.lgh_carrier,' + @Crlf +
			'l.lgh_startdate,' + @Crlf +
			'l.lgh_enddate,' + @Crlf +
			'o.ord_origin_earliestdate,' + @Crlf +
			'o.ord_origin_latestdate,' + @Crlf +
			'o.ord_dest_earliestdate,' + @Crlf  + 
			'o.ord_dest_latestdate,' + @Crlf +
			--PTS 57328 JJF 20110927
			'''N'' as tm_retransmit,' + @Crlf + 
			'l.lgh_tm_status ' + @Crlf +
			--END PTS 57328 JJF 20110927
	'FROM 	--assetassignment a' + @Crlf +
		'legheader l ' + @Crlf +
		'--INNER JOIN stops s ON a.mov_number = s.mov_number' + @Crlf +
		' INNER JOIN orderheader o ON l.mov_number = o.mov_number AND o.ord_invoicestatus <> ''PPD''' + @Crlf +
		' INNER JOIN company shpcmp ON o.ord_shipper = shpcmp.cmp_id' + @Crlf +
		' INNER JOIN company destcmp ON o.ord_destpoint = destcmp.cmp_id' + @Crlf +
		' LEFT OUTER JOIN commodity cmd ON o.cmd_code = cmd.cmd_code' + @crlf +
		' where 1 = 1 ' + @Crlf

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

SET @ParmDefinition = N'@v_ref_type varchar(6), @v_start_date datetime, @v_end_date datetime, @v_tractor_id varchar(8), @v_driver_id varchar(8), @v_trailer_id varchar(13), @v_carrier_id varchar(8)'

--denug generated sql stmt
if @Debug = 'Y' PRINT @SQLString

EXECUTE sp_executesql @SQLString, @ParmDefinition,
                     @v_ref_type = @ref_type, 
			@v_start_date = @start_date, 
			@v_end_date = @end_date,
			@v_tractor_id = @tractor_id , 
			@v_driver_id = @driver_id, 
			@v_trailer_id = @trailer_id,
			@v_carrier_id = @carrier_id


GO
GRANT EXECUTE ON  [dbo].[d_aggregate_tripconfirm_sequence] TO [public]
GO
