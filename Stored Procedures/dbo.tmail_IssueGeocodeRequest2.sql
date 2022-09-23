SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_IssueGeocodeRequest2]
	@TMFormId int, 
	@TMTruckName varchar(15), -- dummy truck for addressing geocode messages
	@cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
	@stp_number varchar(15)

AS

SET NOCOUNT ON 

	DECLARE @msg_id int,
			@v_cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
			@v_stp_cmp_id varchar(25), --PTS 61189 CMP_ID INCREASE LENGTH TO 25
			@v_stp_number int,
			@v_address varchar(40),		-- TODO check lengths
			@v_city varchar(18),
			@v_state varchar(6),
			@v_zip varchar(10),
			@v_GeoCodedDate datetime,
			@v_city_code int, 
			@v_IssueRequest int,
			@v_GeoCodeRequested as datetime,
			@v_sRequestCode as varchar(251)



	SET @v_cmp_id = ISNULL(@cmp_id,'UNKNOWN')
	if (@v_cmp_id = '')
		SET @v_cmp_id = 'UNKNOWN'

	IF ISNULL(@stp_number,0) = 0 AND (@cmp_id = 'UNKNOWN') RETURN

	SET @v_stp_number = CONVERT(int, ISNULL(@stp_number,0))
	SET @v_IssueRequest = 0		-- 0 do not send geoGodeRequest, 1 set cmp_GeoCodeRequested on company table, 2 set stp_GeoCodeRequested on stops table, 3 set cty_GeoCodeRequested on city table

	IF (@v_cmp_id = 'UNKNOWN')
		BEGIN
			SELECT @v_city_code = stp_city, @v_state = stp_state, @v_zip = stp_zipcode, @v_address = stp_address, @v_GeoCodeRequested = stp_GeoCodeRequested 
			FROM stops (NOLOCK)
			WHERE stp_number = @v_stp_number
			IF ISNULL(@v_address,'') = '' 
				BEGIN		-- Need to go against city table
					SELECT @v_address = '', @v_city = cty_name, @v_state = ISNULL(cty_state, 'UN'), @v_zip = cty_zip, @v_GeoCodeRequested = cty_GeoCodeRequested 
					FROM city (NOLOCK)
					WHERE cty_code = @v_city_code
					
					IF (@v_city = 'UNKNOWN') and (@v_state = 'UN') RETURN			-- Unknow city record - do not GeoCodeRequest
					IF (ISNULL(@v_GeoCodeRequested,'') = '')
						SET @v_IssueRequest = 3			-- Set cty_GeoCodeRequested field on city table
				END
			ELSE		-- Need to get city name from code
				BEGIN
					SELECT @v_city = cty_name FROM city WHERE cty_code = @v_city_code
					IF (ISNULL(@v_GeoCodeRequested,'') = '')
						SET @v_IssueRequest = 2			-- Set stp_GeoCodeRequested field on stops table
				END
		END
	ELSE  -- Look at company table
		BEGIN
			SELECT @v_address = cmp_address1, @v_city_code = cmp_city, @v_zip = cmp_zip, @v_state = cmp_state, @v_GeoCodeRequested = cmp_GeoCodeRequested 
			FROM company (NOLOCK)
			WHERE cmp_id = @v_cmp_id
			IF ISNULL(@v_address,'') = ''		-- Validate that we have a good address
				BEGIN
					SELECT @v_city_code = stp_city, @v_state = stp_state, @v_zip = stp_zipcode, @v_address = stp_address, @v_GeoCodeRequested = stp_GeoCodeRequested 
					FROM stops (NOLOCK)
					WHERE stp_number = @v_stp_number
					IF ISNULL(@v_address,'') = '' 
						BEGIN		-- Need to go against city table
							SELECT @v_address = '', @v_city = cty_name, @v_state = cty_state, @v_zip = cty_zip, @v_GeoCodeRequested = cty_GeoCodeRequested 
							FROM city (NOLOCK)
							WHERE cty_code = @v_city_code
							IF (ISNULL(@v_GeoCodeRequested,'') = '')
								SET @v_IssueRequest = 3				-- Set cty_GeoCodeRequested field on city table
						END
					ELSE		-- Need to get city name from code
						BEGIN
							SELECT @v_city = cty_name 
							FROM city (NOLOCK)
							WHERE cty_code = @v_city_code
							IF (ISNULL(@v_GeoCodeRequested,'') = '')
								SET @v_IssueRequest = 2				-- Set stp_GeoCodeRequested field on stops table
						END
				END
			ELSE	-- Found all info on Company Table
				BEGIN
					SELECT @v_city = cty_name 
					FROM city (NOLOCK)
					WHERE cty_code = @v_city_code			-- Get City name from cty_code
					IF (@v_city = 'UNKNOWN') and (@v_state = 'UN') RETURN					
					IF (ISNULL(@v_GeoCodeRequested,'') = '')
						SET @v_IssueRequest = 1					-- Set cmp_GeoCodeRequested field on company table
				END
		END

		-- PTS 79339 - AB - Early exit if the company id is UNKNOWN and the city is either null or empty.
		IF (ISNULL(@v_city,'')='') AND (ISNULL(@v_cmp_id, 'UNKNOWN')='UNKNOWN')
		BEGIN
			RETURN
		END

IF (@v_IssueRequest > 0)
	BEGIN
		IF (@v_IssueRequest = 1)
			set @v_sRequestCode = convert(varchar, @v_cmp_id)
		ELSE IF (@v_IssueRequest = 2)
			set @v_sRequestCode = 'STP:' + convert(varchar, @v_stp_number)
		ELSE IF (@v_IssueRequest = 3)
			set @v_sRequestCode = 'CTY:' + ISNULL(convert(varchar, @v_city_code), '')
		ELSE
			set @v_sRequestCode = 'UNKNOWN'

		INSERT TMSQLMessage (
			msg_date, 
			msg_FormID, 
			msg_To, 
			msg_ToType, 
			msg_FilterData,
			msg_FilterDataDupWaitSeconds, 
			msg_From, 
			msg_FromType, 
			msg_Subject)
			VALUES (
				GETDATE(), 
				@TMFormId, 
				@TMTruckName,
				0,			
				'tmail_IssueGeoCodeRequest:' + convert(varchar(5),@TMFormId) + @v_sRequestCode, --filter duplicate rows
				5, 			--wait 5 seconds
				'Admin',
				0, 				
				'GEOCODE REQUEST for ' + @v_sRequestCode)
	
		SET @msg_id = @@IDENTITY

		INSERT TMSQLMessageData (
			msg_ID, 
			msd_Seq, 
			msd_FieldName, 
		 	msd_FieldValue)
			VALUES (
				@msg_id, 
				1, 
				'Field01',   -- CompanyID
				ISNULL(@v_sRequestCode,''))
	
		INSERT TMSQLMessageData (
			msg_ID, 
			msd_Seq, 
			msd_FieldName, 
		 	msd_FieldValue)
			VALUES (
				@msg_id, 
				1, 
				'Field02',   -- Address
				ISNULL(@v_address,''))	 
	
		INSERT TMSQLMessageData (
			msg_ID, 
			msd_Seq, 
			msd_FieldName, 
		 	msd_FieldValue)
			VALUES (
				@msg_id, 
				1, 
				'Field03',   -- City
				ISNULL(@v_city,''))     
	
		INSERT TMSQLMessageData (
			msg_ID, 
			msd_Seq, 
			msd_FieldName, 
		 	msd_FieldValue)
			VALUES (
				@msg_id, 
				1, 
				'Field04',   -- State
				ISNULL(@v_state,''))     
	
		INSERT TMSQLMessageData (
			msg_ID, 
			msd_Seq, 
			msd_FieldName, 
		 	msd_FieldValue)
			VALUES (
				@msg_id, 
				1, 
				'Field05',   -- Zip
				ISNULL(@v_zip,''))
	END
		
GO
GRANT EXECUTE ON  [dbo].[tmail_IssueGeocodeRequest2] TO [public]
GO
