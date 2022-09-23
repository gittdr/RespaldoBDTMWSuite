SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 46342 JJF 20090823

CREATE PROC [dbo].[MatchingAssetsForOrder_sp] (
				@ord_hdrnumber int,
				@earliest_start_date datetime,
				@origin_cty_code int,
				@destination_cty_code int
			 )
AS

	DECLARE @DEBUG char(1)

	SET @DEBUG = 'N'


	DECLARE
		@origin_state varchar(6),
		@origin_latitude decimal(8, 4), 
		@origin_longitude decimal(8, 4), 
		@destination_state varchar(6),
		@destination_latitude decimal(8, 4),
		@destination_longitude decimal(8, 4) 


	DECLARE	@proc_to_call	varchar(50)
	DECLARE @proc_additional_filter	varchar(50)
	
	--Get procedure to call to retrieve qualifying orders.  Parameters will match parameter list for this procedure.
	SELECT	@proc_to_call = isnull(ltrim(rtrim(gi_string1)), ''),
			@proc_additional_filter = isnull(ltrim(rtrim(gi_string4)), '')
	FROM	generalinfo 
	WHERE	gi_name = 'OrderAutoMatchProc'



	IF isnull(@proc_to_call, '') = '' BEGIN
		SELECT @proc_to_call = 'AssetsAutoMatch_sp'
	END
			

CREATE TABLE #matching_assets(
		ma_id					int				NOT NULL IDENTITY (1, 1),
		source_id				int				NULL,
		car_id					varchar(8)		NULL,
		ete_id					int				NULL,
		distance_to_origin		int				NULL,
		distance_to_destination	int				NULL
)
	
DECLARE @FinalResult table(
	ete_id					int			NULL,
	car_id					varchar(8)	NULL,
	car_name				varchar(64)	NULL,
	car_scac				char(4)		NULL,
	car_fedid				varchar(10)	NULL,
	car_type1				char(6)		NULL,
	car_type2				char(6)		NULL,
	car_type3				char(6)		NULL,
	car_type4				char(6)		NULL,
	car_iccnum				varchar(12)	NULL,
	car_otherid				varchar(8)	NULL,
	ord_number				char(12)	NULL,
	ord_hdrnumber			int			NULL,
	lgh_number				int			NULL,
	mov_number				int			NULL,
	lgh_endcity				int			NULL,
	lgh_endcty_nmstct		varchar(25)	NULL,
	lgh_enddate				datetime	NULL,
	distance_to_origin		int			NULL,
	distance_to_destination	int			NULL
)	


IF @proc_to_call <> '' BEGIN
	IF @DEBUG = 'Y' BEGIN
		PRINT 'Using OrderAutoMatchProc: ' + @proc_to_call
	END

	SELECT	@origin_latitude = cty_latitude, 
			@origin_longitude = cty_longitude,  
			@origin_state = cty_state
	FROM	city
	WHERE   cty_code = @origin_cty_code
		
	SELECT	@destination_latitude = cty_latitude, 
			@destination_longitude = cty_longitude,
			@destination_state = cty_state
	FROM	city
	WHERE   cty_code = @destination_cty_code
	

	
	

	IF @DEBUG = 'Y' BEGIN
		PRINT 'Resolved Parm list'
		PRINT '@ord_hdrnumber = ' + isnull(convert(varchar(30), @ord_hdrnumber), 'null')
		PRINT '@origin_state = ' + isnull(convert(varchar(30), @origin_state), 'null')
		PRINT '@origin_latitude = ' + isnull(convert(varchar(30), @origin_latitude), 'null')
		PRINT '@origin_longitude = ' + isnull(convert(varchar(30), @origin_longitude), 'null')
		PRINT '@destination_state = ' + isnull(convert(varchar(30), @destination_state), 'null')
		PRINT '@destination_latitude = ' + isnull(convert(varchar(30), isnull(@destination_latitude, 0)), 'null')
		PRINT '@destination_longitude = ' + isnull(convert(varchar(30), isnull(@destination_longitude, 0)), 'null')
		PRINT '@earliest_start_date = ' + convert(varchar(30), @earliest_start_date)
		PRINT ''
	END
	
	exec @proc_to_call 
			@ord_hdrnumber,
			@earliest_start_date,
			'9999-01-01',
			@origin_state,
			@origin_latitude,
			@origin_longitude,
			@destination_state,
			@destination_latitude,
			@destination_longitude
			
	IF @DEBUG = 'Y' BEGIN
		PRINT 'Return from trip retrieval proc:'
		SELECT * FROM #matching_assets
	END


	IF ISNULL(@proc_additional_filter, '') <> '' BEGIN
		IF @debug = 'Y' BEGIN
			PRINT ''
			PRINT 'additional filtering...'
		END

		exec @proc_additional_filter
			@ord_hdrnumber
		

		IF @DEBUG = 'Y' BEGIN
			PRINT 'trips remaining after additional filtering:'
			SELECT * 
			FROM #matching_assets
		END
	END
	
	EXEC AssetsAutoMatch_FilterRequirements_sp @ord_hdrnumber = @ord_hdrnumber


END


	--Build final resultset
	INSERT	@FinalResult
	SELECT	massets.ete_id,
			car.car_id,
			car.car_name,
			car.car_scac,
			car.car_fedid,
			car.car_type1,
			car.car_type2,
			car.car_type3,
			car.car_type4,
			car.car_iccnum,
			car.car_otherid,
			'' as ord_number,
			0 as ord_hdrnumber,
			lgh.lgh_number,
			lgh.mov_number,
			lgh.lgh_endcity,
			lgh.lgh_endcty_nmstct,
			lgh.lgh_enddate,
			massets.distance_to_origin,
			massets.distance_to_destination
	FROM	#matching_assets massets
			left outer join external_equipment ete on massets.ete_id = ete.ete_id
			left outer join carrier car on ete.ete_carrierid = car.car_id
			left outer join legheader_brokered lghb on ete.ete_id = lghb.lgh_ete_id
			left outer join legheader lgh on lgh.lgh_number = lghb.lgh_number
	ORDER BY massets.ete_id

--	UPDATE @FinalResult
--	SET ord_number = oh.ord_number,
--		ord_hdrnumber = oh.ord_hdrnumber
--	FROM @FinalResult INNER JOIN orderheader oh on @FinalResult.mov_number = oh.mov_number
	
	
	

SELECT 
	ete_id,
	car_id,
	car_name,
	car_scac,
	car_fedid,
	car_type1,
	car_type2,
	car_type3,
	car_type4,
	car_iccnum,
	car_otherid,
	ord_number,
	ord_hdrnumber,
	lgh_number,
	mov_number,
	lgh_endcity,
	lgh_endcty_nmstct,
	lgh_enddate,
	distance_to_origin,
	distance_to_destination
FROM @FinalResult



GO
GRANT EXECUTE ON  [dbo].[MatchingAssetsForOrder_sp] TO [public]
GO
