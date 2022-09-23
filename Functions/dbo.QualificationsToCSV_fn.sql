SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE  FUNCTION [dbo].[QualificationsToCSV_fn]	(	@mpp_id1 varchar(8), 
												@mpp_id2 varchar(8), 
												@trc_id varchar(8), 
												@trl_number1 varchar(8), 
												@trl_number2 varchar(8), 
												@car_id varchar(8), 
												@car_id_drv varchar(8), 
												@car_id_trc varchar(8), 
												@car_id_trl varchar(8), 
												@startdate datetime, 
												@enddate datetime, 
												@IncludeAssetPrefix integer, 
												@IncludeLabelName integer,
												@Delimiter varchar(1)
											)
RETURNS  VARCHAR(255)

--For carriers, in order to return qualifications for the carrier asset types, repeat the car_id in @car_id_drv, @car_id_trc, @car_id_trl
AS BEGIN
	DECLARE	@csvlist varchar(257)
	
	SELECT	@csvlist = ''
	
	SELECT @startdate = ISNULL(@startdate, '01-01-1950')
	SELECT @enddate = ISNULL(@enddate, '12-31-2049')
	
	IF ISNULL(@mpp_id1, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'DRV1-' ELSE '' END) + @Delimiter + drvq.drq_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	driverqualifications drvq 
				LEFT OUTER JOIN labelfile lbl on (drvq.drq_type = lbl.abbr and lbl.labeldefinition = 'DrvAcc')
		WHERE	(drvq.drq_id = ISNULL(@mpp_id1, 'UNKNOWN'))
				AND drvq.drq_source = 'DRV' 
				AND ISNULL(drvq.drq_date, '01-01-1950') <= @startdate
				AND ISNULL(drq_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(drq_expire_flag, 'N') <> 'Y'
		ORDER BY drq_type
	END
	
	IF ISNULL(@mpp_id2, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'DRV2-' ELSE '' END) + @Delimiter + drvq.drq_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	driverqualifications drvq 
				LEFT OUTER JOIN labelfile lbl on (drvq.drq_type = lbl.abbr and lbl.labeldefinition = 'DrvAcc')
		WHERE	(drvq.drq_id = ISNULL(@mpp_id2, 'UNKNOWN'))
				AND drvq.drq_source = 'DRV' 
				AND ISNULL(drvq.drq_date, '01-01-1950') <= @startdate
				AND ISNULL(drq_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(drq_expire_flag, 'N') <> 'Y'
		ORDER BY drq_type
	END 
	
	IF ISNULL(@trc_id, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'TRC-' ELSE '' END) + @Delimiter + tca.tca_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	tractoraccesories tca 
				LEFT OUTER JOIN labelfile lbl on (tca.tca_type = lbl.abbr and lbl.labeldefinition = 'TrcAcc')
		WHERE	(tca.tca_tractor = ISNULL(@trc_id, 'UNKNOWN'))
				AND tca.tca_source = 'TRC' 
				AND ISNULL(tca.tca_dateaquired, '01-01-1950') <= @startdate
				AND ISNULL(tca.tca_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(tca.tca_expire_flag, 'N') <> 'Y'
		ORDER BY tca.tca_type
	END
	
	IF ISNULL(@trl_number1, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'TRL1-' ELSE '' END) + @Delimiter + ta.ta_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	trlaccessories ta 
				LEFT OUTER JOIN labelfile lbl on (ta.ta_type = lbl.abbr and lbl.labeldefinition = 'TrlAcc')
		WHERE	(ta.ta_trailer = ISNULL(@trl_number1, 'UNKNOWN'))
				AND ta.ta_source = 'TRL' 
				AND ISNULL(ta.ta_dateacquired, '01-01-1950') <= @startdate
				AND ISNULL(ta.ta_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(ta.ta_expire_flag, 'N') <> 'Y'
		ORDER BY ta.ta_type
	END
	
	IF ISNULL(@trl_number2, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'TRL2-' ELSE '' END) + @Delimiter + ta.ta_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	trlaccessories ta 
				LEFT OUTER JOIN labelfile lbl on (ta.ta_type = lbl.abbr and lbl.labeldefinition = 'TrlAcc')
		WHERE	(ta.ta_trailer = ISNULL(@trl_number2, 'UNKNOWN'))
				AND ta.ta_source = 'TRL' 
				AND ISNULL(ta.ta_dateacquired, '01-01-1950') <= @startdate
				AND ISNULL(ta.ta_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(ta.ta_expire_flag, 'N') <> 'Y'
		ORDER BY ta.ta_type
	END

	IF ISNULL(@car_id, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'CAR-' ELSE '' END) + @Delimiter + ta.caq_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	carrierqualifications ta 
				LEFT OUTER JOIN labelfile lbl on (ta.caq_type = lbl.abbr and lbl.labeldefinition = 'CarQual')
		WHERE	(ta.caq_id = ISNULL(@car_id, 'UNKNOWN'))
				AND ISNULL(ta.caq_date, '01-01-1950') <= @startdate
				AND ISNULL(ta.caq_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(ta.caq_expire_flag, 'N') <> 'Y'
		ORDER BY ta.caq_type
	END

	IF ISNULL(@car_id_drv, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'CAR(DRV)-' ELSE '' END) + @Delimiter + drvq.drq_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	driverqualifications drvq 
				LEFT OUTER JOIN labelfile lbl on (drvq.drq_type = lbl.abbr and lbl.labeldefinition = 'DrvAcc')
		WHERE	(drvq.drq_id = ISNULL(@car_id_drv, 'UNKNOWN'))
				AND drvq.drq_source = 'CAR' 
				AND ISNULL(drvq.drq_date, '01-01-1950') <= @startdate
				AND ISNULL(drq_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(drq_expire_flag, 'N') <> 'Y'
		ORDER BY drq_type
	END

	IF ISNULL(@car_id_trc, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'CAR(TRC)-' ELSE '' END) + @Delimiter + tca.tca_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	tractoraccesories tca 
				LEFT OUTER JOIN labelfile lbl on (tca.tca_type = lbl.abbr and lbl.labeldefinition = 'TrcAcc')
		WHERE	(tca.tca_tractor = ISNULL(@car_id_trc, 'UNKNOWN'))
				AND tca.tca_source = 'CAR' 
				AND ISNULL(tca.tca_dateaquired, '01-01-1950') <= @startdate
				AND ISNULL(tca.tca_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(tca.tca_expire_flag, 'N') <> 'Y'
		ORDER BY tca.tca_type
	END

	IF ISNULL(@car_id_trl, 'UNKNOWN') <> 'UNKNOWN' BEGIN
		SELECT	@csvlist = @csvlist + ', ' + (CASE @IncludeAssetPrefix WHEN 1 THEN 'CAR(TRL)-' ELSE '' END) + @Delimiter + ta.ta_type + @Delimiter + (CASE @IncludeLabelName WHEN 1 THEN ':' + ISNULL(lbl.name, '(No label)') ELSE '' END)
		FROM	trlaccessories ta 
				LEFT OUTER JOIN labelfile lbl on (ta.ta_type = lbl.abbr and lbl.labeldefinition = 'TrlAcc')
		WHERE	(ta.ta_trailer = ISNULL(@car_id_trl, 'UNKNOWN'))
				AND ta.ta_source = 'CAR' 
				AND ISNULL(ta.ta_dateacquired, '01-01-1950') <= @startdate
				AND ISNULL(ta.ta_expire_date, '12-31-2049') >= @enddate
				AND ISNULL(ta.ta_expire_flag, 'N') <> 'Y'
		ORDER BY ta.ta_type
	END
		
	SELECT @csvlist = SUBSTRING(@csvlist, 3, 255)			
	RETURN @csvlist
END
GO
GRANT EXECUTE ON  [dbo].[QualificationsToCSV_fn] TO [public]
GO
