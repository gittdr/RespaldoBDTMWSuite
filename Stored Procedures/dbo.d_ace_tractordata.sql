SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_ace_tractordata]	@p_ordnum varchar(13),@p_mov_number int

AS
/**
 * 
 * NAME:
 * dbo.d_ace_tractordata
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Retrieves tractor detail information for the ace 309/358 creation window in visual dispatch.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * All columns in #tractordata temp table
 *
 * PARAMETERS:
 * 001 - @p_ordnum, varchar(13), input;
 *       This parameter indicates the order number in which related data is being retrieved
 * 002 - @p_mov_number int input not null;
 *	  Move number for which data is being retrieved.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? Name of Proc / Function Called
 * 
 * REVISION HISTORY:
 * 03/1/2006.01 ? PTS31886 - A. Rossman ? Initial Release
 * 10/09/2006.02 - PTS 34551 -A. Rossman -  Handle AllowIntenational City setting for country codes
 * 01/28/2007.03 - PTS 39885 - A. Rossman - Updated data retrieval for tractor identifier type
 *
 **/

DECLARE @tractor  varchar(8),@v_seal1 varchar(15),@v_seal2 varchar(15),@v_seal3 varchar(15),@v_seal4 varchar(15)
DECLARE @v_lgh_number int,@v_mov_number int,@v_ord_hdrnumber int
DECLARE @v_gitype varchar(8),@v_trctype varchar(6)
DECLARE @v_allowintlcity CHAR(1), @v_isocode varchar(2)
  
CREATE TABLE #tractordata (
			    trc_number	varchar(8)	NULL,	--TMWSUITE ID
			    trc_serial	varchar(20)	NULL,	--VIN Number
			    trc_licnum	varchar(12)	NULL,	--License Plate
			    trc_licstate varchar(6)	NULL,	--State of license plate issue
			    trc_liccountry varchar(2)	NULL,	
			    trc_type4	varchar(6)	NULL,	--Conveyance Type code
			    trc_aceidtype varchar(6)	NULL,	--Ace or FAST ID qualifier
			    trc_aceid	varchar(15)	NULL,	--ID number for Ace or Fast
			    trc_transponder  varchar(20) NULL,	
			    trc_dotnumber varchar(20)	NULL,
			    trc_ins_company varchar(50) NULL,
			    trc_ins_policyno varchar(50) NULL,
			    trc_ins_policyamt int	NULL,
			    trc_policyyear   varchar(4) NULL,
			    trc_seal1	varchar(15)	NULL,	--From reference numbers with EDI code of TRSEAL
			    trc_seal2	varchar(15)	NULL,	-- attached to the orderheader
			    trc_seal3	varchar(15)	NULL,
			    trc_seal4	varchar(15)	NULL
			    )



 SELECT @v_gitype = ISNULL(LEFT(UPPER(gi_string1),8),'TR') FROM generalinfo WHERE gi_name = 'ACE:TractorType'
  
   --34551
   SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'


IF @p_mov_number > 0
	SET @v_mov_number = @p_mov_number
ELSE
	SELECT 	@v_ord_hdrnumber = ord_hdrnumber,	--determine ord_hdrnumber and mov_number
		@v_mov_number = mov_number
	FROM 	orderheader WHERE ord_number = @p_ordnum


--Get the legheader for the first border crossing event
SELECT 	@v_lgh_number = lgh_number 
FROM	stops
WHERE	mov_number = @v_mov_number
	AND stp_event in ('BCST','NBCST')
	and stp_mfh_sequence = (SELECT MIN(stp_mfh_sequence) FROM stops WHERE mov_number = @v_mov_number AND stp_event in ('BCST','NBCST'))


--get the tractor ID from the border crossing leg
SELECT	@tractor = lgh_tractor
FROM	legheader
WHERE	lgh_number = @v_lgh_number
  
  
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
  		WHERE   trc_number = @tractor
				AND labelfile.[labeldefinition] = @v_gitype
			
		--special case for bad edicode	
		IF @v_trctype = ''		
  			SELECT @v_trctype = CASE @v_gitype
									WHEN 'TRCTYPE1' Then LEFT(trc_type1,2)
									WHEN 'TRCTYPE2' Then LEFT(trc_type2,2)
									WHEN 'TRCTYPE3' Then LEFT(trc_type3,2)
									WHEN 'TRCTYPE4' Then LEFT(trc_type4,2)
									ELSE	'TR'
								     END
 			FROM	tractorprofile
			WHERE   trc_number = @tractor
   END --PTS 39885			




INSERT INTO #tractordata
SELECT  @tractor,
	t.trc_serial,
	t.trc_licnum,
	t.trc_licstate,
	LEFT(t.trc_liccountry,2),
	@v_trctype,
	t.trc_aceidtype,
	t.trc_aceid,
	t.trc_transponder,
	t.trc_dotnumber,
	t.trc_insurance_co,
	t.trc_insurance_policy,
	t.trc_insurance_amt,
	t.trc_insurance_year,
	'',
	'',
	'',
	''
FROM tractorprofile t 
WHERE	trc_number = @tractor



--Update with the seal numbers
		SELECT @v_seal1 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number) 
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
				
		SELECT @v_seal2 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <> @v_seal1
		
		SELECT @v_seal3 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey  in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <>@v_seal1 AND ref_number <> @v_seal2	
	
		SELECT @v_seal4 = ISNULL(MIN(ref_number),' ') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@v_mov_number)
			and ref_table = 'stops' 
			AND edicode = 'TRSEAL'
			AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal3 AND ref_number <> @v_seal2 AND ref_number <> @v_seal1
		
UPDATE #tractordata
SET	trc_seal1 = @v_seal1,
	trc_seal2 = @v_seal2,
	trc_seal3 = @v_seal3,
	trc_seal4 = @v_seal4
WHERE	trc_number = @tractor

IF  @v_allowintlcity = 'Y'
	UPDATE #tractordata
	SET		trc_liccountry =  ISNULL(isocode,'')
	FROM	country cc
		JOIN	tractorprofile tr
		ON	cc.name = tr.trc_liccountry
	WHERE	tr.trc_number = @tractor	


--final select statement
SELECT 	    trc_number,
	    trc_serial,
	    trc_licnum,
	    trc_licstate,
	    trc_liccountry, 
	    trc_type4,
	    trc_aceidtype, 
	    trc_aceid,	
	    trc_transponder,
	    trc_dotnumber, 
	    trc_ins_company, 
	    trc_ins_policyno, 
	    trc_ins_policyamt,
	    trc_policyyear,
	    trc_seal1,	
	    trc_seal2,	
	    trc_seal3,	
	    trc_seal4
FROM #tractordata


GO
GRANT EXECUTE ON  [dbo].[d_ace_tractordata] TO [public]
GO
