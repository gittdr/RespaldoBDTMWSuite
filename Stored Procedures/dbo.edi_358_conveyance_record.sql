SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_358_conveyance_record] 
	@p_trcid varchar( 8 ),
	@p_iit_code	varchar(2),
	@p_e358batch int,
	@p_mov_number	int
as

/**
 * 
 * NAME:
 * dbo.edi_358_conveyance_record
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #3 or conveyance record in the EDI 358 document.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_trcid, varchar(8), input, not null;
 *       TMWSUITE ID of the tractor associated with the current trip. 
 * 002 - @p_iit_code varchar(2) input not null;
 *	  indicates if there are instruments of international traffic on the trip and who's bond they are.
 * 003 - @e358batch, int, input, not null
 *		 This parameter indocates the EDI document ID
 * 004 - @p_mov_number int input not null
 *		Indicates the current move number.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_358_manifest_header
 * CalledBy002 ? 

 * 
 * REVISION HISTORY:
 * 02/28/2006.01 ? PTS31886 - A.Rossman ? Initial Release
 * 06/27/2006.02 - PTS33469 - A.Rossman - Removed embedded spaces from license plates, updated to only send required information
 *				based on tractors registration status and load type(hazmat/non-hazmat).
 * 09/19/2006.03 -PTS34551 -A.Rossman - added additional edit to prevent dash characters to be included in license number.
 * 01/23/2007.04 - PTS35931 - A. Rossman - Updated to include conveyance type along with ace ID
 * 01/28/2008.05 - PTS39885 - A. Rossman - Updated retrieval of tractor type data.
 **/
 DECLARE @v_seal1 varchar(15),@v_seal2 varchar(15),@v_seal3 varchar(15),@v_seal4 varchar(15)
 DECLARE @v_aceid_edi varchar(3), @v_ord_hdrnumber int,@v_aceid varchar(30)
 DECLARE @v_gitype varchar(8),@v_trctype varchar(6),@v_hazmat_flg char(1)
 DECLARE @v_allowintlcity CHAR(1)
  
  
  CREATE TABLE #358_trcdata 
 (
 	trc_number	varchar(8)	NULL,
 	trc_aceidtype	varchar(6) 	NULL,
 	trc_aceid	varchar(30)	NULL,
 	vin		varchar(20)	NULL,
 	license		varchar(12)	NULL,
 	licstate	varchar(6)	NULL,
 	lic_country	varchar(2)	NULL,
 	type		varchar(6)	NULL,
 	dot_number	varchar(18)	NULL,
 	transponder	varchar(20)	NULL,
 	Insurance_co	varchar(50)	NULL,
 	policy_no	varchar(50)	NULL,
 	policy_year	varchar(4)	NULL,
 	policy_amt	int		NULL,
 	seal1		varchar(15)	NULL,
 	seal2		varchar(15)	NULL,
 	seal3		varchar(15)	NULL,
 	seal4		varchar(15)	NULL,
 	iit_flg		varchar(2)	NULL

 ) 
  
 SELECT @v_gitype = ISNULL(LEFT(UPPER(gi_string1),8),'TR') FROM generalinfo WHERE gi_name = 'ACE:TractorType'
  
   --34551
   SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'

  


IF LEFT(@v_gitype,7) <> 'TRCTYPE'
 	SELECT @v_trctype = UPPER(LEFT(@v_gitype,2))
  ELSE	
  BEGIN
  	SELECT @v_trctype =  UPPER(SUBSTRING(ISNULL(edicode,abbr),1,2)) FROM labelfile 
  			join tractorprofile 
  				on	[abbr] =  CASE @v_gitype
  								WHEN 'TRCTYPE1' THEN trc_type1
  								WHEN 'TRCTYPE2' THEN trc_type2
  								WHEN 'TRCTYPE3' Then trc_type3
  								WHEN 'TRCTYPE4' Then trc_type4
  								ELSE	'TRCTYPE1'
  		  					 END
  		WHERE   trc_number = @p_trcid
				AND labelfile.[labeldefinition] = @v_gitype
				
	IF @v_trctype = ''		
		SELECT @v_trctype = CASE @v_gitype
								WHEN 'TRCTYPE1' Then LEFT(trc_type1,2)
								WHEN 'TRCTYPE2' Then LEFT(trc_type2,2)
								WHEN 'TRCTYPE3' Then LEFT(trc_type3,2)
								WHEN 'TRCTYPE4' Then LEFT(trc_type4,2)
								ELSE	'TR'
							     END
		FROM	tractorprofile
		WHERE   trc_number = @p_trcid	
  END --PTS 39885		


 /* set the value for the hazardous flag	*/
IF(select count(*) from freightdetail f
	join commodity c 
		on c.cmd_code = f.cmd_code
    where c.cmd_hazardous = 1 and f.stp_number in (select stp_number from stops where mov_number =  @p_mov_number)) > 0

   SET @v_hazmat_flg =  'Y'
ELSE
   SET @v_hazmat_flg = 'N'	
 

 
 
 --initial insert into the temp table
 INSERT INTO #358_trcdata
 	SELECT	@p_trcid,
 		ISNULL(trc_aceidtype,' '),
 		ISNULL(trc_aceid,' '),
 		ISNULL(trc_serial,' '),
 		ISNULL(REPLACE(trc_licnum,' ',''),' '),
 		ISNULL(trc_licstate,' '),
 		ISNULL(trc_liccountry,' '),
 		@v_trctype,
 		ISNULL(trc_dotnumber,' '),
 		ISNULL(trc_transponder,' '),
 		ISNULL(trc_insurance_co,' '),
 		ISNULL(trc_insurance_policy,' '),
 		ISNULL(trc_insurance_year,' '),
 		ISNULL(trc_insurance_amt,' '),
 		' ',
 		' ',
 		' ',
 		' ',
 		@p_iit_code
 	FROM	tractorprofile
 	WHERE trc_number = @p_trcid
 	
--PTS 34551 remove any dash charcters from the license plate number
UPDATE #358_trcdata
SET		license = REPLACE(license,'-','')
WHERE trc_number is not null

--END 34551


--Update with the seal numbers
		SELECT @v_seal1 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number) 
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
				
		SELECT @v_seal2 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <> @v_seal1
		
		SELECT @v_seal3 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey  in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <>@v_seal1 AND ref_number <> @v_seal2	
	
		SELECT @v_seal4 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal3 AND ref_number <> @v_seal2 AND ref_number <> @v_seal1


UPDATE #358_trcdata
SET	seal1 = @v_seal1,
	seal2 = @v_seal2,
	seal3 = @v_seal3,
	seal4 = @v_seal4
WHERE	trc_number = @p_trcid

--update license country

UPDATE #358_trcdata
SET	lic_country = ISNULL(UPPER(LEFT(stc_country_c,2)),' ')
FROM	statecountry
WHERE	licstate = stc_state_c	

--PTS 34551
IF @v_allowintlcity = 'Y'
	UPDATE	#358_trcdata
	SET		lic_country = ISNULL(isocode,'')
	FROM	country cc
		JOIN tractorprofile tr
			ON tr.trc_liccountry = cc.name
	WHERE	tr.trc_number = @p_trcid		


SELECT @v_aceid = trc_aceid FROM #358_trcdata

SELECT @v_aceid_edi = ISNULL(edicode,'XX')
FROM	labelfile
	Join	#358_trcdata
	ON abbr = trc_aceidtype
WHERE	labeldefinition = 'AceIDType'

IF @v_aceid_edi = 'A7'
	    SET @v_aceid_edi = 'AID'
	    
/*insert record into the edi_358_table; if there is an Ace ID present not all data is required */
IF @v_aceid_edi =  'AID' AND @v_hazmat_flg = 'Y' 	/* Pre-registered conveyance and Hazmat load */
    BEGIN
    	
	INSERT INTO edi_358(data_col,batch_number,mov_number)
	SELECT '3|10|'+@p_trcid+'|'+@v_aceid_edi+'|'+@v_aceid+'|||||'+ type + '|||'+
		insurance_co + '|' +
		policy_no + '|' +
		policy_year + '|' +
		CONVERT(varchar(8),policy_amt) + '|' +
		seal1 + '|' +
		seal2 + '|' +
		seal3 + '|' +
		seal4 + '|' +
		iit_flg + '|',
		@p_e358batch,
		@p_mov_number
	FROM	#358_trcdata
    END
    

IF @v_aceid_edi <> 'AID' AND  @v_hazmat_flg = 'Y'	/* Conveyance not registered - Hazmat load */
    BEGIN
    	
	INSERT INTO edi_358(data_col,batch_number,mov_number)
	SELECT '3|10|'+@p_trcid+'|'+
		trc_aceidtype	+ '|' +
		trc_aceid	+ '|' +
		vin	+ '|' +	
		license	+ '|' +	
		licstate + '|' +	
		lic_country + '|' +	 
		type	+ '|' +	
		dot_number + '|' +	
		transponder + '|' +	
		Insurance_co + '|' +	
		policy_no + '|' +	
		policy_year + '|' +	
		CONVERT(varchar(8),policy_amt) + '|' +	
		seal1	+ '|' +	
		seal2	+ '|' +	
		seal3	+ '|' +	
		seal4	+ '|' +	
		iit_flg	+ '|',	
		@p_e358batch,
		@p_mov_number
	FROM	#358_trcdata
	
     END

IF @v_aceid_edi = 'AID' and @v_hazmat_flg = 'N'	/*Pre-registered conveyance  Non-Hazmat load */
    BEGIN
	
	INSERT INTO edi_358(data_col,batch_number,mov_number)
	SELECT '3|10|'+@p_trcid+'|'+@v_aceid_edi+'|'+@v_aceid+'|||||' + type + '|||'+
		 + '|' +
		 + '|' +
		 + '|' +
		 + '|' +
		seal1 + '|' +
		seal2 + '|' +
		seal3 + '|' +
		seal4 + '|' +
		iit_flg + '|',
		@p_e358batch,
		@p_mov_number
	FROM	#358_trcdata    	
     END
IF @v_aceid_edi  <> 'AID' AND @v_hazmat_flg = 'N'		/*non registered conveyance and non-hazmat load */  
    BEGIN    	

 	INSERT INTO edi_358(data_col,batch_number,mov_number)
    	SELECT '3|10|'+@p_trcid+'|'+
		trc_aceidtype	+ '|' +
		trc_aceid	+ '|' +
		vin	+ '|' +	
		license	+ '|' +	
		licstate + '|' +	
		lic_country + '|' +	 
		type	+ '|' +	
		dot_number + '|' +	
		transponder + '|' +	
		'|' +	
		'|' +	
		'|' +	
		'|' +	
		seal1	+ '|' +	
		seal2	+ '|' +	
		seal3	+ '|' +	
		seal4	+ '|' +	
		iit_flg	+ '|',	
		@p_e358batch,
		@p_mov_number
	FROM	#358_trcdata
    END
    


GO
GRANT EXECUTE ON  [dbo].[edi_358_conveyance_record] TO [public]
GO
