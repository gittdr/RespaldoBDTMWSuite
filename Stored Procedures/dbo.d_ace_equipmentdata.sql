SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ace_equipmentdata]	@p_ordnum varchar(13),@p_mov_number int

AS
/**
 * 
 * NAME:
 * dbo.d_ace_equipmentdata
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves trailer detail information for the ace 309/358 creation window in  dispatch.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * All columns in #trailerdata temp table.
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 * 002 - @p_mov_number int input not null;
 *	  Move number currently being retrieved.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/1/2006.01 ? PTS31886  - A. Rossman ? Initial Release
 * 04/23/2006.02 - PTS 32601 - A. Rossman - Added move number to input parameter.
 * 07/06/2006.03 - PTS33469 - A.Rossman - Use trailer from border crossing event versus legheader trailer.
 * 10/05/2006.04 - PTS34451 -A.Rossman - User trl_id instead of trl_number from profile.  Add handling for AllowInternationalCity GI Setting for Country.
 * 11/27/2007.05 - PTS39885 - A.Rossman - Updated retrieval of the trailertype indicator when using labelfile for source.
 *
 **/

DECLARE @v_trlone  varchar(13), @v_trltwo  varchar(13),@v_seal1 varchar(15),@v_seal2 varchar(15),@v_seal3 varchar(15)
DECLARE @v_seal4 varchar(15),@v_mov_number int, @v_lgh_number int
DECLARE @v_gitype varchar(8),@v_trltype varchar(6),@v_cbp_stop int
DECLARE @v_allowintlcity CHAR(1),@v_isocode VARCHAR(2)

 

CREATE TABLE #trailerdata (
			     trl_id		varchar(13)	NULL,
			     trl_number	varchar(13) 	NULL,
			     trl_type   varchar(6)  	NULL,
			     trl_licnum varchar(12) 	NULL,
			     trl_licstate varchar(6) 	NULL,
			     trl_country varchar(2) 	NULL,
			     trl_aceidtype varchar(6)	 NULL,
			     trl_aceid	 varchar(30) 	NULL,
			     trl_seal1	varchar(15)	NULL,
			     trl_seal2	varchar(15)	NULL,
			     trl_seal3	varchar(15)	NULL,
			     trl_seal4	varchar(15)	NULL
			    )

 SELECT @v_gitype = ISNULL(LEFT(UPPER(gi_string1),8),'TL') FROM generalinfo WHERE gi_name = 'ACE:TrailerType'
 
 --34551
 SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'

IF @p_mov_number >  0 
	SET @v_mov_number = @p_mov_number
ELSE	
	SELECT @v_mov_number =  mov_number FROM orderheader where ord_number = @p_ordnum

--Get the legheader for the first border crossing event
SELECT 	@v_lgh_number = lgh_number,
	@v_cbp_stop   = stp_number
FROM	stops
WHERE	mov_number = @v_mov_number
	AND stp_event in ('BCST','NBCST')
	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST')
				AND stp_state IN (SELECT stc_state_c FROM statecountry WHERE stc_country_c ='USA'))




SELECT	@v_trlone = ISNULL(evt_trailer1,'UNKNOWN'),
	@v_trltwo   = ISNULL(evt_trailer2,'UNKNOWN')
FROM	event
WHERE	stp_number = @v_cbp_stop
	
/*SELECT @v_trlone = ISNULL(lgh_primary_trailer,'UNKNOWN'),
	@v_trltwo = ISNULL(lgh_primary_pup,'UNKNOWN')
FROM	legheader
WHERE	lgh_number = @v_lgh_number	*/


IF @v_trlone <> 'UNKNOWN'
BEGIN
	IF LEFT(@v_gitype,7) <> 'TRLTYPE'
 		SELECT @v_trltype = UPPER(LEFT(@v_gitype,2))
 	ELSE	
 	BEGIN
 		SELECT @v_trltype =  UPPER(SUBSTRING(ISNULL(edicode,abbr),1,2)) FROM labelfile 
			join trailerprofile 
				on	[abbr] =  CASE @v_gitype
								WHEN 'TRLTYPE1' THEN trl_type1
								WHEN 'TRLTYPE2' THEN trl_type2
								WHEN 'TRLTYPE3' Then trl_type3
								WHEN 'TRLTYPE4' Then trl_type4
								ELSE	'TRLTYPE1'
		  					 END
		WHERE trl_id = @v_trlone
				AND labelfile.[labeldefinition] = @v_gitype
		
		--special condition to handle edicode with empty string.
		IF @v_trltype = ''
  		SELECT @v_trltype = CASE @v_gitype
								WHEN 'TRLTYPE1' THEN LEFT(trl_type1,2)
								WHEN 'TRLTYPE2' THEN LEFT(trl_type2,2)
								WHEN 'TRLTYPE3' Then LEFT(trl_type3,2)
								WHEN 'TRLTYPE4' Then LEFT(trl_type4,2)
								ELSE	'TL'
  			     				  END
 		FROM	trailerprofile
		WHERE   trl_id = @v_trlone
--add an additional check for invalid setting parameter				
		IF @v_trltype = 'TR'
			SET @v_trltype = 'TL'
			
	 END	
	  

	
	INSERT INTO #trailerdata
	SELECT @v_trlone,
		trl_number,
		@v_trltype,
		trl_licnum,
		trl_licstate,
		LEFT(trl_liccountry,2),
		trl_aceidtype,
		trl_aceid,
		'',
		'',
		'',
		''
	FROM	trailerprofile
	WHERE trl_id = @v_trlone

	--Update with the seal numbers
		SELECT @v_seal1 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number) 
			and ref_table = 'stops' 
			AND edicode = 'TLSEAL'
			AND labeldefinition = 'ReferenceNumbers'
				
		SELECT @v_seal2 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TLSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <> @v_seal1
		
		SELECT @v_seal3 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey  in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TLSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <>@v_seal1 AND ref_number <> @v_seal2	
	
		SELECT @v_seal4 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TLSEAL'
			AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal3 AND ref_number <> @v_seal2 AND ref_number <> @v_seal1

	UPDATE #trailerdata
	SET	trl_seal1 = @v_seal1,
		trl_seal2 = @v_seal2,
		trl_seal3 = @v_seal3,
		trl_seal4 = @v_seal4
	WHERE	trl_id= @v_trlone
	
	
		--PTS34551 Use ISO code from country Profile for trailer.
		IF @v_allowintlcity = 'Y'
		BEGIN
			SELECT @v_isocode = ISNULL(isocode,'')
			FROM	country
					JOIN trailerprofile
						ON 	trl_liccountry = name
			WHERE	trl_id = @v_trlone			
			
			UPDATE #trailerdata
			SET		trl_country = ISNULL(@v_isocode,'')
			WHERE	trl_id = @v_trlone
		END	
	

	
END

--Add the second trailer if applicable
IF @v_trltwo <> 'UNKNOWN'
BEGIN
	
	 IF LEFT(@v_gitype,7) <> 'TRLTYPE'
 		SELECT @v_trltype = UPPER(LEFT(@v_gitype,2))
	  ELSE	
	  	SELECT @v_trltype = CASE @v_gitype
	  				WHEN 'TRLTYPE1' Then trl_type1
	  				WHEN 'TRLTYPE2' Then trl_type2
	  				WHEN 'TRLTYPE3' Then trl_type3
	  				WHEN 'TRLTYPE4' Then trl_type4
	  				ELSE	'TL'
	  			     END
	 	FROM	trailerprofile
	WHERE   trl_id = @v_trltwo
	
	INSERT INTO #trailerdata
	SELECT @v_trltwo,
		trl_number,
		@v_trltype,
		trl_licnum,
		trl_licstate,
		LEFT(trl_liccountry,2),
		trl_aceidtype,
		trl_aceid,
		'',
		'',
		'',
		''
	FROM	trailerprofile
	WHERE trl_id = @v_trltwo

	--Update with the seal numbers
	
	SELECT @v_seal1 = ISNULL(MIN(ref_number),' ') 
	FROM	referencenumber	r
		INNER JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
		and ref_table = 'stops' 
		AND edicode = 'TLSL2'
		AND labeldefinition = 'ReferenceNumbers'
			
	SELECT @v_seal2 = ISNULL(MIN(ref_number),' ') 
	FROM	referencenumber	r
		INNER JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
		and ref_table = 'stops' 
		AND edicode = 'TLSL2'
		AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal1
	
	SELECT @v_seal3 = ISNULL(MIN(ref_number),' ') 
	FROM	referencenumber	r
		INNER JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number) 
		and ref_table = 'stops' 
		AND edicode = 'TLSL2'
		AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <>@v_seal1 AND ref_number <> @v_seal2	

	SELECT @v_seal4 = ISNULL(MIN(ref_number),' ') 
	FROM	referencenumber	r
		INNER JOIN labelfile l
			ON l.abbr = r.ref_type
	WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number) 
		and ref_table = 'stops' 
		AND edicode = 'TLSL2'
		AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal3 AND ref_number <> @v_seal2 AND ref_number <> @v_seal1

	UPDATE #trailerdata
	SET	trl_seal1 = @v_seal1,
		trl_seal2 = @v_seal2,
		trl_seal3 = @v_seal3,
		trl_seal4 = @v_seal4
	WHERE	trl_id = @v_trltwo
	
		--PTS34551 Use ISO code from country Profile for trailer.
		IF @v_allowintlcity = 'Y'
		BEGIN
			SELECT @v_isocode = ISNULL(isocode,'')
			FROM	country
					JOIN trailerprofile 
						ON 	trl_liccountry = name
			WHERE	trl_id = @v_trltwo			

			UPDATE #trailerdata
			SET		trl_country = ISNULL(@v_isocode,'')
			WHERE	trl_id = @v_trltwo
		END

END



--final select
SELECT 		trl_number,
		trl_type,
		trl_licnum,
		trl_licstate,
		trl_country,
		trl_aceidtype,
		trl_aceid,
		trl_seal1,
		trl_seal2,
		trl_seal3,
		trl_seal4
FROM #trailerdata	

GO
GRANT EXECUTE ON  [dbo].[d_ace_equipmentdata] TO [public]
GO
