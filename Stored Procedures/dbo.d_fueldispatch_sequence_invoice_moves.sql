SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_fueldispatch_sequence_invoice_moves] (@ref_type varchar(6), @start_date datetime, @end_date datetime, @tractor_id varchar(8), @driver_id varchar(8), @trailer_id varchar(13), @trailer2_id varchar(8), @carrier_id varchar(8))
AS
/**
 * 
 * NAME:
 * dbo.d_fueldispatch_sequence_invoice_moves
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves invoices movements for use in trip completion.
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
 * 11-20-06, jguo, patch for beelman to improve performance. Add index hint on ordhdr_ordstartdate*
 * 03-05-07, jguo, split the sql into two phases to avoid index scan on legheader table *
 * 07-11-07, jguo, try dynamic sql approach to avoid occasional wrong query plan when different parameters are passed in
*/

/*
	SELECT DISTINCT	0 as sequence, 
			orderheader.ord_number,   
			orderheader.ord_shipper,   
			orderheader.ord_destpoint,
			orderheader.mov_number,   
			orderheader.ord_hdrnumber,
			(SELECT Max (ref_number)
			FROM
				(select ref_tablekey, min (ref_sequence) as min_ref_sequence
				from referencenumber
				where ref_table = 'orderheader'
					and ref_type = @ref_type
				group by ref_tablekey) A,
				(select * 
				from referencenumber
				where ref_table = 'orderheader'
					and ref_type = @ref_type) B
			WHERE A.ref_tablekey = B.ref_tablekey 
				AND A.min_ref_sequence = B.ref_sequence 
				AND A.ref_tablekey = orderheader.ord_hdrnumber) as fuel_ref_number,
			orderheader.ord_startdate,
			orderheader.ord_completiondate,
			orderheader.ord_status,
			'Y' as invoice_flag,
			'N' as modified_flag,
			'N' as include_flag
	FROM	legheader,   
         	stops,   
         	orderheader with(index(ordhdr_ordstartdate))
	WHERE	(legheader.mov_number = stops.mov_number)
         	AND (legheader.mov_number = orderheader.mov_number)
		AND ((lgh_tractor = @tractor_id OR @tractor_id = 'UNKNOWN')
		AND (lgh_driver1 = @driver_id OR @driver_id = 'UNKNOWN')
		AND (lgh_primary_trailer = @trailer_id OR @trailer_id = 'UNKNOWN') 
		AND (lgh_carrier = @carrier_id OR @carrier_id = 'UNKNOWN'))
		AND (orderheader.ord_invoicestatus = 'PPD' )
		AND (orderheader.ord_startdate >= @start_date)
		AND (orderheader.ord_startdate <= @end_date) 
*/
SET NOCOUNT ON
DECLARE @SQLString NVARCHAR(4000)
DECLARE @ParmDefinition NVARCHAR(1000)
DECLARE @Crlf as CHAR(1)
DECLARE @Debug as CHAR(1)

SET @Debug = 'N'
SET @Crlf = char(10) 

	CREATE TABLE #order 
	( 	ord_number char(12),   
		ord_shipper varchar(8),   
		ord_destpoint varchar(8),
		mov_number int,   
		ord_hdrnumber int,
		ord_startdate datetime,
		ord_completiondate datetime,
		ord_status varchar(6)
	)

	INSERT INTO #order (ord_number,  ord_shipper, ord_destpoint, mov_number, ord_hdrnumber, ord_startdate, ord_completiondate, ord_status)
	SELECT ord_number,  ord_shipper, ord_destpoint, mov_number, ord_hdrnumber, ord_startdate, ord_completiondate, ord_status
	FROM orderheader with(index(ordhdr_ordstartdate))
	WHERE orderheader.ord_invoicestatus = 'PPD'
 		AND orderheader.ord_startdate >= @start_date
		AND orderheader.ord_startdate <= @end_date 

	SET @SQLString = 
		'SELECT DISTINCT	0 as sequence,' + @Crlf +
			'orderheader.ord_number,' + @Crlf + 
			'orderheader.ord_shipper,' + @Crlf +   
			'orderheader.ord_destpoint,' + @Crlf +
			'orderheader.mov_number,' + @Crlf +  
			'orderheader.ord_hdrnumber,' + @Crlf +
			'(SELECT Max (ref_number)' + @Crlf +
			'FROM' + @Crlf + 
				'(select ref_tablekey, min (ref_sequence) as min_ref_sequence' + @Crlf +
				'from referencenumber' + @Crlf +
				'where ref_table = ''orderheader''' + @Crlf +
					'and ref_type = @v_ref_type' + @Crlf +
				'group by ref_tablekey) A,' + @Crlf +
				'(select *' + @Crlf +
				'from referencenumber' + @Crlf +
				'where ref_table = ''orderheader''' + @Crlf +
					'and ref_type = @v_ref_type) B' + @Crlf +
			'WHERE A.ref_tablekey = B.ref_tablekey' + @Crlf +
				'AND A.min_ref_sequence = B.ref_sequence' + @Crlf +
				'AND A.ref_tablekey = orderheader.ord_hdrnumber) as fuel_ref_number,' + @Crlf +
			'orderheader.ord_startdate,' + @Crlf +
			'orderheader.ord_completiondate,' + @Crlf +
			'orderheader.ord_status,' + @Crlf +
			'''Y'' as invoice_flag,' + @Crlf +
			'''N'' as modified_flag,' + @Crlf +
			'''N'' as include_flag' + @Crlf +
	'FROM	legheader,' + @Crlf +  
         	'stops,' + @Crlf +  
         	'#order orderheader' + @Crlf +
	'WHERE	(legheader.mov_number = orderheader.mov_number)' + @Crlf +
		'AND (legheader.mov_number = stops.mov_number)' + @Crlf +
         	'AND (legheader.mov_number = orderheader.mov_number)' + @Crlf

 
	if @tractor_id <> 'UNKNOWN' 
	begin
		set @SQLString = @SQLString + 'AND lgh_tractor = @v_tractor_id' + @Crlf
	end
 
	if @driver_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND lgh_driver1 = @v_driver_id' + @Crlf
	end

	if @trailer_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND lgh_primary_trailer = @v_trailer_id' + @Crlf
	end

	if @carrier_id <> 'UNKNOWN'
	begin
		set @SQLString = @SQLString + 'AND lgh_carrier = @v_carrier_id' + @Crlf
	end
--		AND ((lgh_tractor = @tractor_id OR @tractor_id = 'UNKNOWN')
--		AND (lgh_driver1 = @driver_id OR @driver_id = 'UNKNOWN')
--		AND (lgh_primary_trailer = @trailer_id OR @trailer_id = 'UNKNOWN') 
--		AND (lgh_carrier = @carrier_id OR @carrier_id = 'UNKNOWN'))

SET @ParmDefinition = N'@v_ref_type varchar(6), @v_tractor_id varchar(8), @v_driver_id varchar(8), @v_trailer_id varchar(13), @v_carrier_id varchar(8)'

--denug generated sql stmt
if @Debug = 'Y' PRINT @SQLString

EXECUTE sp_executesql @SQLString, @ParmDefinition,
                        @v_ref_type = @ref_type, 
			@v_tractor_id = @tractor_id , 
			@v_driver_id = @driver_id, 
			@v_trailer_id = @trailer_id,
			@v_carrier_id = @carrier_id

GO
GRANT EXECUTE ON  [dbo].[d_fueldispatch_sequence_invoice_moves] TO [public]
GO
