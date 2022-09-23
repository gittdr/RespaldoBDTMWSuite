SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_309_crew_record] 
	@p_crewid varchar( 8 ),
	@p_role varchar(3),
	@p_e309batch int,
	@p_mov_number	int
as

/**
 * 
 * NAME:
 * dbo.edi_309_crew_record
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #3 or crew record in the EDI 309 document.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_crewid, varchar(8), input, not null;
 *       TMWSUITE ID of the driver,co-driver or passenger associated with the current trip. 
 * 002 - @p_role, varchar(3), input, not null;
 *       This parameter indicates the role of the current crew member being processed.
 *		 EJ - Person in Charge, CRW - Crew Member ,   - Passenger
 * 003 - @e309batch, int, input, not null
 *		 This parameter indocates the EDI document ID
 * 004 - @p_mov_number int input not null
 *		Indicates the current move number.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_309_manifest_header
 * CalledBy002 ? 

 * 
 * REVISION HISTORY:
 * 02/28/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 06/02/2006.02   PTS33281 - A. Rossman	  Update to driver hazmat data.
 * 06/09/2006.03   PTS33327 - A. Rossman   Only show a 'Y' for hazmat qualifications that have not expired. 
 * 06/29/2006.04   PTS33469 - A. Rossman   Only send required information when an ACE ID or Proximity Card No is present.
 * 08/08/2006.04-  PTS33485 - B. Hanson	   Added driverqualifications.drq_source = 'DRV' to distinguish between drivers and carriers.
 * 08/08/2006.04-  PTS33485 - B. Hanson	   Changed @v_docnum from varchar(6) to varchar(30)			
 * 10/09/2006.05 - PTS34551 - A.Rossman Allow International city changes for the company codes.
 * 01/03/2007.06 - PTS35652 - A.Rossman - Allow for ACE or FAST ID for Passengers
 * 06/12/2009.07 - PTS47650 - A.Rossman - Updates for EDL Requirements.
 **/

DECLARE @v_consignee	varchar(8), @v_addr1 varchar(30), @v_addr2 varchar(30),@v_state	varchar(6),@v_country varchar(2)
DECLARE	@v_ctyname varchar(18), @v_ctynumber int, @v_zip varchar(10)
DECLARE @v_licnum varchar(25), @v_licstate varchar(6), @v_liccountry varchar(2), @v_lictype varchar(6)
DECLARE @v_doctype varchar(6), @v_docnum varchar(30), @v_docstate varchar(6), @v_doccountry varchar(2), @v_docedicode varchar(6)
DECLARE @v_firstusstop varchar(8), @v_aceid_type varchar(6)
DECLARE @v_allowintlcity CHAR(1)
DECLARE @v_customs_stop int
--create the temp table for storing driver,crew data

CREATE TABLE #309_crewdata 
(
		role	varchar(3)	NULL,
		Lname	varchar(30)	NULL,
		Fname	varchar(30)	NULL,
		Middle	varchar(1)	NULL,
		DateofBirth varchar(16)	NULL,
		gender	char(1)		NULL,
		addr1	varchar(30)	NULL,		--from consignee, or first US stop
		addr2	varchar(30)	NULL,		--from consignee, or first US stop
		city	varchar(18)	NULL,		--from consignee, or first US stop
		state	varchar(6)	NULL,		--from consignee, or first US stop
		zip	varchar(10)	NULL,		--from consignee, or first US stop
		country	varchar(2)	NULL,		--from consignee, or first US stop
		citizenship varchar(6)  NULL,
		cit_country varchar(2)  NULL,
		aceidtype varchar(6)	NULL,
		aceid	varchar(20)	NULL
)		
		
	
 --34551
 SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'
	
	
--get the consignee company id
SELECT @v_consignee = cmp_id
FROM stops 
WHERE stp_mfh_sequence = (SELECT MAX(stp_mfh_sequence) FROM stops WHERE mov_number = @p_mov_number and stp_type = 'DRP')
	and mov_number = @p_mov_number
	
/*PTS 41019 AROSS 2.18.08 */
	SELECT @v_customs_stop = stp_number
	FROM	stops
	WHERE	stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @p_mov_number and stp_event in ('BCST','NBCST'))
		AND stops.stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
		AND mov_number = @p_mov_number

--Next do a check to see if the first us stop is different.  If none, default to consignee.
SELECT @v_firstusstop =  ISNULL(stops.cmp_id,@v_consignee),
		@v_addr1 = ISNULL(SUBSTRING(stp_address,1,30),' '),
		@v_addr2 = ISNULL(SUBSTRING(stp_address2,1,30),' '),
		@v_state = ISNULL(stp_state,' '),
		@v_zip   = ISNULL(stp_zipcode,' '),
		@v_country = ISNULL(cmp_country,' '),
		@v_ctynumber = stp_city
FROM	stops
   INNER JOIN company
   	on stops.cmp_id = company.cmp_id
WHERE	[stp_mfh_sequence] = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE [mov_number] =@p_mov_number AND stp_mfh_sequence > 
		(SELECT stp_mfh_sequence FROM stops WHERE stp_number = @v_customs_stop) AND stops.cmp_id <> 'UNKNOWN'
		AND stops.stp_event NOT IN('RTP','TRP','FUL','CHK'))
		AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
		AND [mov_number] = @p_mov_number

/*stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @p_mov_number and stp_event in ('BCST','NBCST'))
 	AND stops.stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
 	AND stops.mov_number = @p_mov_number	*/


/*
SELECT	@v_addr1 = ISNULL(SUBSTRING(cmp_address1,1,30),' '),
	@v_addr2 = ISNULL(SUBSTRING(cmp_address2,1,30),' '),
	@v_state = ISNULL(cmp_state,' '),
	@v_zip   = ISNULL(cmp_zip,' '),
	@v_country = ISNULL(cmp_country,' '),
	@v_ctynumber = cmp_city
FROM	company
WHERE	cmp_id = @v_firstusstop			*/


SELECT	@v_ctyname = cty_name
FROM	city
WHERE	cty_code = @v_ctynumber

IF @p_role = 'EJ' OR @p_role = 'CRW'
BEGIN
	INSERT INTO #309_crewdata
		SELECT	@p_role,
			ISNULL(mpp_lastname,' '),
			ISNULL(mpp_firstname,' '),
			ISNULL(mpp_middlename,' '),
			ISNULL(CONVERT(varchar(16),mpp_dateofbirth,112),' '),
			ISNULL(mpp_gender,' '),
			@v_addr1,
			@v_addr2,
			@v_ctyname,
			@v_state,
			@v_zip,
			@v_country,
			CASE ISNULL(mpp_citizenship_status,' ')
				WHEN 10 Then '8'
				ELSE ' '
			END	,
			ISNULL(mpp_citizenship_country,' '),
			ISNULL(mpp_aceidtype,' '),
			ISNULL(mpp_aceid,' ')
		FROM 	manpowerprofile
		WHERE	mpp_id = @p_crewid

	UPDATE #309_crewdata
	SET	aceidtype = ISNULL(edicode,' ')
	FROM	labelfile
	WHERE	labeldefinition = 'AceIDType'
		AND abbr = aceidtype

	UPDATE	#309_crewdata
	SET	citizenship = ISNULL(edicode,' ')
	FROM	labelfile	
	WHERE	labeldefinition = 'Citizenshipstatus'
		AND abbr = citizenship

--PTS 34551		
	IF @v_allowintlcity = 'Y'
		UPDATE #309_crewdata
		SET		cit_country = ISNULL(isocode,'')
		FROM	country c
			JOIN manpowerprofile m
				ON c.name = m.mpp_citizenship_country
		WHERE m.mpp_id = @p_crewid

	SELECT @v_aceid_type = aceidtype FROM #309_crewdata

	/* Create the record in the edi_309 table */

	IF @v_aceid_type =  'PY'	/* The driver has a FAST card Proximity Number */
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	     SELECT
		  '3|10|' +
		  role + '|'+		--role of individual on trip
		  Lname + '|' +		--Last Name
		   + '|' +		-- First Name
		   + '|' +		--Middle init
		   + '|'+		--D.O.B
		   + '|' +		--gender code
		   + '|' +		--address line 1
		   + '|' +		--address line 2
		   + '|' + 		--city
		   + '|' +		--state
		   + '|' + 		--zip
		   + '|' +		--country
		   + '|' +		--citizenship code
		   + '|' +		--citizenship country
		  aceidtype  + '|' +    --ace id type ACE;FAST etc
		  aceid	+ '|' ,		--ace id number
		  @p_e309batch,
		  @p_mov_number
	      FROM #309_crewdata	
	
	IF @v_aceid_type =  'A7'	/*Driver has been registered for an ACE ID */
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	     SELECT
		  '3|10|' +
		  role + '|'+		--role of individual on trip
		  Lname + '|' +		--Last Name
		   + '|' +		-- First Name
		   + '|' +		--Middle init
		   + '|'+		--D.O.B
		   + '|' +		--gender code
		  addr1 + '|' +		--address line 1
		  addr2 + '|' +		--address line 2
		  city + '|' + 		--city
		  state + '|' +		--state
		  zip + '|' + 		--zip
		  country + '|' +	--country
		   + '|' +		--citizenship code
		   + '|' +		--citizenship country
		  aceidtype  + '|' +    --ace id type ACE;FAST etc
		  aceid	+ '|' ,		--ace id number
		  @p_e309batch,
		  @p_mov_number
	      FROM #309_crewdata	
	

	IF @v_aceid_type Not in ('A7','PY')
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	     SELECT
		  '3|10|' +
		  role + '|'+		--role of individual on trip
		  Lname + '|' +		--Last Name
		  Fname + '|' +		-- First Name
		  Middle + '|' +	--Middle init
		  dateofbirth + '|'+	--D.O.B
		  gender + '|' +	--gender code
		  addr1 + '|' +		--address line 1
		  addr2 + '|' +		--address line 2
		  city + '|' + 		--city
		  state + '|' +		--state
		  zip + '|' + 		--zip
		  country + '|' +	--country
		  citizenship + '|' +	--citizenship code
		  cit_country + '|' +	--citizenship country
		  aceidtype  + '|' +    --ace id type ACE;FAST etc
		  aceid	+ '|' ,		--ace id number
		  @p_e309batch,
		  @p_mov_number
	      FROM #309_crewdata


	/* add driverdocument logic below */  
	--HAZMAT
	IF (SELECT SUM(cmd_hazardous)FROM commodity c
			JOIN	freightdetail f
				ON c.cmd_code = f.cmd_code 
			JOIN 	stops s
				ON s.stp_number = f.stp_number
			WHERE	s.mov_number = @p_mov_number
				And s.stp_type = 'DRP') > 0
		BEGIN
			IF EXISTS ( SELECT 1 FROM driverqualifications WHERE drq_id = @p_crewid and UPPER(drq_source) = 'DRV' and drq_type = 'HAZMAT' and drq_expire_date > GETDATE())
					INSERT INTO edi_309(data_col,batch_number,mov_number)
						VALUES('7|10|DRVDOC|HD|'+'YES'+'| | |',@p_e309batch,@p_mov_number)
			ELSE
					INSERT INTO edi_309(data_col,batch_number,mov_number)
						VALUES('7|10|DRVDOC|HD|'+'No Number'+'| | |',@p_e309batch,@p_mov_number)
	END

	--commercial driver's license
	SELECT	@v_licnum = ISNULL(mpp_licensenumber,' '),
			@v_licstate = ISNULL(mpp_licensestate,'XX')
	FROM	manpowerprofile
	WHERE	mpp_id = @p_crewid


	SELECT @v_liccountry = UPPER(LEFT(stc_country_c,2))
	FROM	statecountry
	WHERE	stc_state_c = @v_licstate

	--insert the driver's license record.
	IF @v_aceid_type Not in ('A7','PY')
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	VALUES('7|10|DRVDOC|5K|'+@v_licnum+'|'+@v_licstate+'|'+@v_liccountry+'|',@p_e309batch,@p_mov_number)

	--Add the default driver document record
	SELECT 	@v_doctype = drd_doctype,
		@v_docnum = drd_docnumber,
		@v_docstate = ISNULL(drd_stateofissue,' '),
		@v_doccountry = ISNULL(drd_countryofissue,' ')
	FROM	driverdocument 
	WHERE	mpp_id = @p_crewid
		AND drd_default = 'Y'

	SELECT @v_docedicode = ISNULL(edicode,abbr)
	FROM	labelfile
	WHERE	labeldefinition = 'DriverDocuments'
		AND abbr = RTRIM(@v_doctype)

	--create the driver document record
	IF @v_aceid_type Not in ('A7','PY') AND ISNULL(@v_doctype,'') <> ''				--IF @v_aceid_type <> 'PY'
	BEGIN
	  INSERT INTO edi_309(data_col,batch_number,mov_number)
	  VALUES('7|10|DRVDOC|'+@v_docedicode+'|'+@v_docnum+'|'+@v_docstate+'|'+@v_doccountry+'|',@p_e309batch,@p_mov_number)

	  --PTS 47650 Remove Drivers License if there is an EDL present 47650
	  IF @v_docedicode = '6W'
		DELETE edi_309
		WHERE data_col LIKE '7|10|DRVDOC|5K|' + @v_licnum+'|%'
			AND batch_number = @p_e309batch
			AND mov_number = @p_mov_number
	--END 47650
	END
END
	/*end of driver document records */
ELSE	--we have a passenger
BEGIN
	INSERT INTO #309_crewdata
		SELECT  @p_role,
			ISNULL(psgr_lastname,' '),
			ISNULL(psgr_firstname,' '),
			ISNULL(psgr_middleinitial,' '),
			ISNULL(CONVERT(varchar(16),psgr_dateofbirth,112),' '),
			ISNULL(psgr_gender,' '),
			@v_addr1,
			@v_addr2,
			@v_ctyname,
			@v_state,
			@v_zip,
			@v_country,
			ISNULL(psgr_citizenship_status,' '),
			LEFT(ISNULL(psgr_citizenship_country,' '),2),
			ISNULL(psgr_aceid_type,''),
			ISNULL(psgr_aceid_number,'')
		FROM	passenger
		WHERE	psgr_id = @p_crewid
		
	UPDATE	#309_crewdata
	SET	citizenship = ISNULL(edicode,' ')
	FROM	labelfile	
	WHERE	labeldefinition = 'Citizenshipstatus'
		AND abbr = citizenship	
		
		--PTS 34551		
			IF @v_allowintlcity = 'Y'
				UPDATE #309_crewdata
				SET		cit_country = ISNULL(isocode,'')
				FROM	country c
					JOIN passenger p
						ON c.name = p.psgr_citizenship_country
				WHERE p.psgr_id  = 	@p_crewid
				
				
	SELECT @v_aceid_type = aceidtype FROM #309_crewdata

	/* Create the record in the edi_309 table */

	IF @v_aceid_type =  'PY'	/* The driver has a FAST card Proximity Number */
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	     SELECT
		  '3|10|' +
		  role + '|'+		--role of individual on trip
		  Lname + '|' +		--Last Name
		   + '|' +		-- First Name
		   + '|' +		--Middle init
		   + '|'+		--D.O.B
		   + '|' +		--gender code
		   + '|' +		--address line 1
		   + '|' +		--address line 2
		   + '|' + 		--city
		   + '|' +		--state
		   + '|' + 		--zip
		   + '|' +		--country
		   + '|' +		--citizenship code
		   + '|' +		--citizenship country
		  aceidtype  + '|' +    --ace id type ACE;FAST etc
		  aceid	+ '|' ,		--ace id number
		  @p_e309batch,
		  @p_mov_number
	      FROM #309_crewdata	
	
	IF @v_aceid_type =  'A7'	/*Driver has been registered for an ACE ID */
	INSERT INTO edi_309(data_col,batch_number,mov_number)
	     SELECT
		  '3|10|' +
		  role + '|'+		--role of individual on trip
		  Lname + '|' +		--Last Name
		   + '|' +		-- First Name
		   + '|' +		--Middle init
		   + '|'+		--D.O.B
		   + '|' +		--gender code
		  addr1 + '|' +		--address line 1
		  addr2 + '|' +		--address line 2
		  city + '|' + 		--city
		  state + '|' +		--state
		  zip + '|' + 		--zip
		  country + '|' +	--country
		   + '|' +		--citizenship code
		   + '|' +		--citizenship country
		  aceidtype  + '|' +    --ace id type ACE;FAST etc
		  aceid	+ '|' ,		--ace id number
		  @p_e309batch,
		  @p_mov_number
	      FROM #309_crewdata				
	
	--create the 309 record for non pre-registered passengers
	IF @v_aceid_type NOT IN ('A7','PY')
		INSERT INTO edi_309(data_col,batch_number,mov_number)
		     SELECT
			  '3|10|' +
			  role + '|'+		--role of individual on trip
			  Lname + '|' +		--Last Name
			  Fname + '|' +		-- First Name
			  Middle + '|' +	--Middle init
			  dateofbirth + '|'+	--D.O.B
			  gender + '|' +	--gender code
			  addr1 + '|' +		--address line 1
			  addr2 + '|' +		--address line 2
			  city + '|' + 		--city
			  state + '|' +		--state
			  zip + '|' + 		--zip
			  country + '|' +	--country
			  citizenship + '|' +	--citizenship code
			  cit_country + '|' +	--citizenship country
			  aceidtype  + '|' +    --ace id type ACE;FAST etc
			  aceid	+ '|' ,		--ace id number
			  @p_e309batch,
			  @p_mov_number
	      FROM #309_crewdata
	      
	      /* add documents for passenger below */
	      
	      	-- driver's license
	      	
	      	SELECT	@v_licnum = ISNULL(psgr_driverlicense,' '),
				@v_licstate = ISNULL(psgr_license_region,'XX'),
				@v_lictype = CASE UPPER(psgr_licenseclass)
						WHEN 'CDL' Then '5K'
						WHEN 'C'   Then '5K'
						WHEN 'COMMERCIAL' Then '5K'
						WHEN 'COM' Then '5K'
						ELSE '5J'
					     END	
		FROM	passenger
		WHERE	psgr_id = @p_crewid
	   
	      
	      	SELECT @v_liccountry = ISNULL(UPPER(LEFT(stc_country_c,2)),' ')
	      	FROM	statecountry
	      	WHERE	stc_state_c = @v_licstate
	      
	      	--insert the driver's license record.
	      	IF @v_licnum <> ' ' AND @v_aceid_type NOT IN('A7','PY')
	      	INSERT INTO edi_309(data_col,batch_number,mov_number)
	      	VALUES('7|10|PASDOC|'+@v_lictype + '|'+@v_licnum+'|'+@v_licstate+'|'+ISNULL(@v_liccountry,' ')+'|',@p_e309batch,@p_mov_number)
	      
	      	--Add the default driver document record
	      	SELECT 	@v_doctype = drd_doctype,
	      		@v_docnum = drd_docnumber,
	      		@v_docstate = ISNULL(drd_stateofissue,' '),
	      		@v_doccountry = ISNULL(drd_countryofissue,' ')
	      	FROM	driverdocument 
	      	WHERE	mpp_id = @p_crewid
	      		AND drd_default = 'Y'
	      		AND drd_type = 'P'
	      
	      	SELECT @v_docedicode = ISNULL(edicode,abbr)
	      	FROM	labelfile
	      	WHERE	labeldefinition = 'DriverDocuments'
	      		AND abbr = RTRIM(@v_doctype)
	      
	      	--create the driver document record
	      	IF @v_aceid_type Not in ('A7','PY') AND ISNULL(@v_doctype,'') <> ''
	      		INSERT INTO edi_309(data_col,batch_number,mov_number)
				VALUES('7|10|PASDOC|'+@v_docedicode+'|'+@v_docnum+'|'+@v_docstate+'|'+@v_doccountry+'|',@p_e309batch,@p_mov_number)
	   
END	      






GO
GRANT EXECUTE ON  [dbo].[edi_309_crew_record] TO [public]
GO
