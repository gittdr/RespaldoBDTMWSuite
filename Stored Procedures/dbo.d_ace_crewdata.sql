SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ace_crewdata] @p_ordnum varchar(13),@p_mov_number int
AS
/**
 * 
 * NAME:
 * dbo.d_ace_crewdata
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves driver,co-driver and passenger detail information for the ace 309/358 creation window in  dispatch.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * All columns in the #crewdata temp table.
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 * 002 - @p_mov_number int input not null;
 *	  Mov number being retrieved for.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/01/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 04/23/2006.02 - PTS32601 - A. Rossman - Added mov number input parameter.
 * 06/27/2006.03 - PTS33469 - A. Rossman - Added isnull wrapper to the middle initial for drivers and passengers correcting display problem.
 * 08/08/2006.04-  PTS33485 - B. Hanson	 - Added driverqualifications.drq_source = 'DRV' to distinguish between drivers and carriers.
 * 06/12/2009.05 - PTS47650 - A. Rossman - Added Enhanced Drivers License Handling
 **/

DECLARE @v_drv_one varchar(8), @v_drv_two varchar(8),@v_mov_number int,@v_lgh_number int
DECLARE @v_doctype varchar(6),@v_docnum varchar(30),@v_first_stop varchar(8),@v_doccountry varchar(50),@v_docstate varchar(6),@v_liccountry varchar(2)
DECLARE @v_address1 varchar(30),@v_address2 varchar(30),@v_city varchar(18),@v_state varchar(6),@v_zip varchar(10),@v_country varchar(50)
DECLARE @v_customs_stop int	/*41019*/
			
CREATE TABLE #crewdata(
			mpp_id	 	varchar(8)	NULL,
			role	 	varchar(3)	NULL,
			mpp_lastname 	varchar(40)	NULL,
			mpp_firstname 	varchar(40)	NULL,
			mpp_middlename 	char(1)		NULL,
			mpp_dateofbirth datetime 	NULL,
			mpp_gender	char(1)		NULL,
			mpp_citizenship varchar(15)	NULL,
			mpp_citzen_country varchar(50)  NULL,
			address1	varchar(30)	NULL,
			address2	varchar(30)	NULL,
			cty_name	varchar(18)	NULL,
			state		varchar(6)	NULL,
			zip		varchar(10)	NULL,
			country		varchar(6)	NULL,
			mpp_licensenumber varchar(25)	NULL,
			mpp_licensestate varchar(25)	NULL,
			mpp_aceidtype	varchar(6)	NULL,
			mpp_aceid	varchar(30)	NULL,
			doc1_type	varchar(6)	NULL,
			doc1_data	varchar(30)	NULL,
			doc2_type	varchar(6)	NULL,
			doc2_data	varchar(30)	NULL,
			doc3_type	varchar(6)	NULL,
			doc3_data	varchar(30)	NULL,
			doc4_type	varchar(6)	NULL,
			doc4_data	varchar(30)	NULL,
			doc1_ctry	varchar(50)	NULL,	--added country column for docs 35539
			doc2_ctry	varchar(50)	NULL,
			doc1_state	varchar(6)	NULL,
			doc2_state	varchar(6)	NULL,
			license_ctry     varchar(2)        NULL	
		       )

IF @p_mov_number > 0 
   SET @v_mov_number = @p_mov_number
ELSE
	SELECT @v_mov_number = mov_number 
	FROM	orderheader 
	WHERE	ord_number = @p_ordnum

--get the legheader number
SELECT 	@v_lgh_number = lgh_number 
FROM	stops
WHERE	mov_number = @v_mov_number
	AND stp_event in ('BCST','NBCST')
	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST'))
	
/*PTS 41019 AROSS 2.18.08 */
	SELECT @v_customs_stop = stp_number
	FROM	stops
	WHERE	stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number and stp_event in ('BCST','NBCST'))
		AND stops.stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
		AND mov_number = @v_mov_number	

--PTS 35970 Updated logic to get the address information from the stop versus the company profile.	
SELECT @v_first_stop = cmp_id,	
		@v_address1 = stp_address,
		@v_address2 = stp_address2,
		@v_state    = stp_state,
		@v_zip      = stp_zipcode,
		@v_city     = cty_name
FROM	stops 
	INNER JOIN city
		ON stp_city = cty_code
WHERE	[stp_mfh_sequence] = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE [mov_number] =@v_mov_number AND stp_mfh_sequence > 
		(SELECT stp_mfh_sequence FROM stops WHERE stp_number = @v_customs_stop) AND stops.cmp_id <> 'UNKNOWN'
		AND stops.stp_event NOT IN('RTP','TRP','FUL','CHK'))
		AND stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
		AND [mov_number] = @v_mov_number


/*lgh_number = @v_lgh_number
	AND stops.stp_state in (SELECT stc_state_c FROM statecountry WHERE stc_country_c  = 'USA')
	AND stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE lgh_number = @v_lgh_number 
				AND stp_mfh_sequence > (SELECT MIN(stp_mfh_sequence) 
				FROM stops WHERE lgh_number = @v_lgh_number AND stp_event in ('BCST','NBCST'))) */

--get the country code from the company profile.  stp_country is not reliable.			
SELECT	@v_country  = LEFT(cmp_country,2)
FROM	company c
WHERE	cmp_id = @v_first_stop			
	

--get the driver id's from the legheader
SELECT	@v_drv_one = ISNULL(lgh_driver1,'UNKNOWN'),
	@v_drv_two = ISNULL(lgh_driver2,'UNKNOWN')
FROM	legheader
WHERE	lgh_number = @v_lgh_number

IF @v_drv_one <> 'UNKNOWN'
BEGIN 	--driver one
	INSERT INTO 	#crewdata
	SELECT 		@v_drv_one,
			'EJ',		--person in charge
			mpp_lastname,
			mpp_firstname,
			ISNULL(mpp_middlename,' '),
			mpp_dateofbirth,
			mpp_gender,
			CASE mpp_citizenship_status
				WHEN 10 THEN '8'
				ELSE ' '
			END	,
			mpp_citizenship_country,
			@v_address1,
			@v_address2,
			@v_city,
			@v_state,
			@v_zip,
			@v_country,
			mpp_licensenumber,
			mpp_licensestate,
			mpp_aceidtype,
			mpp_aceid,
			'',		--doc 1 type
			'',		--doc 1
			'',		--doc 2 type	
			'',		--up to four
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			''
	FROM	manpowerprofile
	WHERE	mpp_id = @v_drv_one
	

	--Update the driver documents
	IF EXISTS(SELECT 1 FROM driverdocument WHERE mpp_id = @v_drv_one)
		BEGIN
			SELECT	@v_doctype = l.edicode,
				@v_docnum = d.drd_docnumber,
				@v_doccountry = d.drd_countryofissue,
				@v_docstate = d.drd_stateofissue
			FROM	labelfile l
				JOIN	driverdocument d
				ON d.drd_doctype =  l.abbr
			WHERE	d.mpp_id = @v_drv_one
				AND l.labeldefinition = 'DriverDocuments'
				AND d.drd_default = 'Y'
				AND d.drd_type ='D'
			
			UPDATE	#crewdata
			SET	doc1_type = @v_doctype,
				doc1_data = @v_docnum,
				doc1_ctry = @v_doccountry,
				doc1_state = @v_docstate
			WHERE	mpp_id = @v_drv_one				
		END
	--update for Enhanced Drivers License PTS47650
	IF EXISTS(SELECT 1 FROM driverdocument WHERE mpp_id = @v_drv_one and drd_type = 'D' and drd_doctype = 'EDL')
		BEGIN
			UPDATE #crewdata
			SET	mpp_licensenumber = d.drd_docnumber
			FROM	driverdocument d
			WHERE	d.mpp_id = @v_drv_one
				 AND d.drd_type = 'D'
				 AND d.drd_doctype = 'EDL'
				 AND #crewdata.mpp_id = @v_drv_one
		
		
		END
		
	IF EXISTS(SELECT 1 FROM driverqualifications where drq_driver = @v_drv_one and upper(ISNULL(drq_source,'DRV')) = 'DRV' and UPPER(LEFT(drq_type,3)) = 'HAZ' AND drq_expire_date > GETDATE())
		BEGIN
			UPDATE #crewdata
			SET	doc2_type = 'HAZMAT',
				doc2_data = 'Y'
			WHERE	mpp_id = @v_drv_one
		END	
						
	
	
END	--driver one

IF @v_drv_two <> 'UNKNOWN'
BEGIN 	--driver two
	INSERT INTO 	#crewdata
	SELECT 		@v_drv_two,
			'CRW',		--crew member
			mpp_lastname,
			mpp_firstname,
			ISNULL(mpp_middlename,' '),
			mpp_dateofbirth,
			mpp_gender,
			CASE mpp_citizenship_status
				WHEN 10 THEN '8'
				ELSE ' '
			END		,
			mpp_citizenship_country,
			@v_address1,
			@v_address2,
			@v_city,
			@v_state,
			@v_zip,
			@v_country,
			mpp_licensenumber,
			mpp_licensestate,
			mpp_aceidtype,
			mpp_aceid,
			'',		--doc 1 type
			'',		--doc 1
			'',		--doc 2 type	
			'',		--up to four
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			'',
			''
	FROM	manpowerprofile
	WHERE	mpp_id = @v_drv_two
	
	
		--Update the driver documents
		IF EXISTS(SELECT 1 FROM driverdocument WHERE mpp_id = @v_drv_two)
			BEGIN
				SELECT	@v_doctype = l.edicode,
					@v_docnum = d.drd_docnumber,
					@v_doccountry	= ISNULL(d.drd_countryofissue,''),
					@v_docstate = ISNULL(d.drd_stateofissue,'')
				FROM	labelfile l
					JOIN	driverdocument d
					ON d.drd_doctype =  l.abbr
				WHERE	d.mpp_id = @v_drv_two
					AND l.labeldefinition = 'DriverDocuments'
					AND d.drd_default = 'Y'
					AND d.drd_type ='D'
				
				UPDATE	#crewdata
				SET	doc1_type = @v_doctype,
					doc1_data = @v_docnum,
					doc1_ctry = @v_doccountry,
					doc1_state= @v_docstate
				WHERE	mpp_id = @v_drv_two				
			END
			
		--update for Enhanced Drivers License PTS47650
		IF EXISTS(SELECT 1 FROM driverdocument WHERE mpp_id = @v_drv_two and drd_type = 'D' and drd_doctype = 'EDL')
			BEGIN
			UPDATE #crewdata
			SET	mpp_licensenumber = d.drd_docnumber
			FROM	driverdocument d
			WHERE	d.mpp_id = @v_drv_two
				 AND d.drd_type = 'D'
				 AND d.drd_doctype = 'EDL'
				 AND #crewdata.mpp_id = @v_drv_two
		
		
			END	
			
		IF EXISTS(SELECT 1 FROM driverqualifications where drq_driver = @v_drv_two and upper(ISNULL(drq_source,'DRV')) = 'DRV' and UPPER(LEFT(drq_type,3)) = 'HAZ' AND drq_expire_date > GETDATE())
			BEGIN
				UPDATE #crewdata
				SET	doc2_type = 'HAZMAT',
					doc2_data = 'Y'
				WHERE	mpp_id = @v_drv_two
		END
	
END	--driver two

-- Add passenger information
IF EXISTS(SELECT 1 FROM movepassenger WHERE mov_number = @v_mov_number)
BEGIN
INSERT INTO #crewdata
	SELECT 		p.psgr_id,
			'QF',
			p.psgr_lastname,
			p.psgr_firstname,
			ISNULL(p.psgr_middleinitial,' '),
			p.psgr_dateofbirth,
			p.psgr_gender,
			p.psgr_citizenship_status,
			ISNULL(LEFT(p.psgr_citizenship_country,2),'??'),
			@v_address1,
			@v_address2,
			@v_city,
			@v_state,
			@v_zip,
			@v_country,
			p.psgr_driverlicense,
			ISNULL(UPPER(LEFT(p.psgr_license_region,2)),'??'),			--need to add a state column
			ISNULL(p.psgr_aceid_type,'UNK'),
			ISNULL(p.psgr_aceid_number,''),
			' ',			--doc1
			' ',
			' ',			--doc2
			' ',
			' ',			--doc3
			' ',			
			' ',			--doc4
			' ',
			'',
			'',
			'',
			'',
			''		--license_ctry
	FROM	passenger p
		JOIN	movepassenger mp
			ON p.psgr_id = mp.psgr_id
	WHERE	mp.mov_number = @v_mov_number
	
	UPDATE #CREWDATA SET  license_ctry = CASE stc_country_c
										WHEN 'USA' Then 'US'
										WHEN 'CANADA' Then 'CA'
										WHEN 'MEXICO' Then 'MX'
										ELSE ''
									    END
	FROM	statecountry
	WHERE stc_state_c =  mpp_licensestate
			
	
	--update the passengerdocuments
	UPDATE	#crewdata
	SET	doc1_type = ISNULL(l.edicode,'UNK'),
		doc1_data = ISNULL(dd.drd_docnumber,' '),
		doc1_ctry = ISNULL(dd.drd_countryofissue,''),
		doc1_state = ISNULL(dd.drd_stateofissue,'')
	FROM	driverdocument dd
		JOIN	labelfile l
			ON dd.drd_doctype = l.abbr
		JOIN 	#crewdata c
			ON c.mpp_id = dd.mpp_id
	WHERE	c.mpp_id = dd.mpp_id
		AND dd.drd_type ='P'
		AND dd.drd_default = 'Y'
		
END 
	UPDATE #CREWDATA SET  license_ctry = CASE stc_country_c
										WHEN 'USA' Then 'US'
										WHEN 'CANADA' Then 'CA'
										WHEN 'MEXICO' Then 'MX'
										ELSE ''
									    END
	FROM	statecountry
	WHERE stc_state_c =  mpp_licensestate

--final select
	SELECT 	
			mpp_id,
			role,
			mpp_lastname,
			mpp_firstname,
			mpp_middlename,
			mpp_dateofbirth,
			mpp_gender,
			mpp_citizenship,
			mpp_citzen_country,
			address1,
			address2,
			cty_name,
			state,
			zip,
			country,
			mpp_licensenumber,
			mpp_licensestate,
			mpp_aceidtype,
			mpp_aceid,
			doc1_type,
			doc1_data,
			doc2_type,
			doc2_data,
			doc3_type,
			doc3_data,
			doc4_type,
			doc4_data,
			doc1_ctry,
			doc1_state,
			license_ctry
	FROM #crewdata

GO
GRANT EXECUTE ON  [dbo].[d_ace_crewdata] TO [public]
GO
