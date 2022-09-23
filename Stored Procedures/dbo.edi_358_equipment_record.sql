SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_358_equipment_record] 
	@p_trlid varchar(13),
	@p_iit_code	varchar(2),
	@p_trlispup	char(1),
	@p_trl_wgt	int,
	@p_trl_count	int,
	@p_e358batch 	int,
	@p_mov_number	int
as

/**
 * 
 * NAME:
 * dbo.edi_358_equipment_record
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #4 or equipment record in the EDI 358 document.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @p_trlid, varchar(8), input, not null;
 *       TMWSUITE ID of the trailer associated with the current trip. 
 * 002 - @p_iit_code varchar(2) input not null;
 *	  indicates if there are instruments of international traffic on the trip and who's bond they are.
 * 003 - @e309batch, int, input, not null
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
 * 03/09/2006.01 ? PTS31886 - A.Rossman ? Initial Release
 * 04/14/2006.02   PTS32601 - A.Rossman   Do not include weight and count information for unassociated trip messages.
 *					  check for existing 309 messages to determine status.
 * 06/27/2006.03 - PTS33469 - A.Rossman - Remove embedded spaces from license plates.
 *09/19/2006.04 - PTS34551 - A.Rossman - Remove and dashes from the license plate information as they are not valid. Use trl_id versus number
 * 06/29/2007.05 -PTS38123 - A. Rossman - Always include weights on 358 to allow for association of 358 with 309 sent by broker/shipper
 * 09/18/2007.06 -PTS39448 - A. Rossman - Always include equipment type identifier.
 **/
 
DECLARE @v_seal1 varchar(15),@v_seal2 varchar(15),@v_seal3 varchar(15),@v_seal4 varchar(15)
DECLARE @v_ord_hdrnumber int,@v_preliminary char(1)
 
DECLARE @v_gitype varchar(8),@v_trltype varchar(6)
DECLARE @v_allowintlcity CHAR(1)

 --declare the temp table variable
 CREATE TABLE #358_trldata 
 (
 	trl_id		varchar(13)  NULL,
 	trl_number varchar(8) NULL,
 	aceid_type	varchar(6)  NULL,
 	aceid		varchar(20) NULL,
 	equip_type	varchar(6)  NULL,
 	lic_num		varchar(12) NULL,
 	lic_state	varchar(6)  NULL,
 	lic_country	varchar(2)  NULL,
 	iit_flg		varchar(2)  NULL,
 	seal1		varchar(15) NULL,
 	seal2		varchar(15) NULL,
 	seal3		varchar(15) NULL,
 	seal4		varchar(15) NULL,
 	trlweight	int	    NULL,
 	trlcount	int	    NULL
 )	
  
 
SELECT @v_gitype = ISNULL(LEFT(UPPER(gi_string1),8),'TL') FROM generalinfo WHERE gi_name = 'ACE:TrailerType'

 --34551
 SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'

/* PTS 38123 Removed Preliminary flag status.  Always should be set to N*/
--PTS 32601
--F (SELECT COUNT(*) FROM ace_edidocument_archive WHERE mov_number = @p_mov_number AND aea_doctype = '309') <> 0
--	SET @v_preliminary = 'N'
--ELSE
--	SET @v_preliminary = 'Y'
	
--END PTS 32601

SET @v_preliminary = 'N'			--PTS38123 Always set to N

  
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
  		WHERE trl_id = @p_trlid
				AND labelfile.[labeldefinition] = @v_gitype
				
		IF @v_trltype = ''
		SELECT @v_trltype = CASE @v_gitype
								WHEN 'TRLTYPE1' Then LEFT(trl_type1,2)
								WHEN 'TRLTYPE2' Then LEFT(trl_type2,2)
								WHEN 'TRLTYPE3' Then LEFT(trl_type3,2)
								WHEN 'TRLTYPE4' Then LEFT(trl_type4,2)
								ELSE	'TL'
	 			     			END
		FROM	trailerprofile
		WHERE   trl_id = @p_trlid			
				
  END
  
  
  /*	SELECT @v_trltype = CASE @v_gitype
  				WHEN 'TRLTYPE1' Then trl_type1
  				WHEN 'TRLTYPE2' Then trl_type2
  				WHEN 'TRLTYPE3' Then trl_type3
  				WHEN 'TRLTYPE4' Then trl_type4
  				ELSE	'TL'
  			     END
 	FROM	trailerprofile
	WHERE   trl_id = @p_trlid
	*/
 
 --condition for a default
 IF @v_gitype = 'UNK'
 	SET @v_gitype = 'TL'
 
 SELECT @v_ord_hdrnumber = min(ord_hdrnumber) 
 FROM orderheader 
 WHERE mov_number = @p_mov_number
 	--AND (Select count(*) from referencenumber where ref_tablekey =ord_hdrnumber and ref_table = 'orderheader' and ref_type in('TLSEAL','TLSL2')) > 0
 
 
 INSERT INTO #358_trldata
 	SELECT	@p_trlid,
 		trl_number,
 		ISNULL(l.edicode,abbr),
 		ISNULL(t.trl_aceid,'UNK'),
 		@v_trltype,
 		ISNULL(REPLACE(t.trl_licnum,'',''),'UNK'),
 		ISNULL(t.trl_licstate,'UNK'),
 		ISNULL(t.trl_liccountry,''),
 		@p_iit_code,
 		'',
 		'',
 		'',
 		'',
 		@p_trl_wgt,
 		@p_trl_count
 	FROM	trailerprofile t
 		JOIN labelfile l
 			ON t.trl_aceidtype = l.abbr
 	WHERE	t.trl_id = @p_trlid
 		AND l.labeldefinition = 'AceIDType'
 		
 	--PTS 34551 Remove dashes from license plate data
 	UPDATE #358_trldata
 	SET		lic_num = REPLACE(lic_num,'-','')
 	WHERE trl_id is not null
 
 
 --Get the seal numbers
		SELECT @v_seal1 = ISNULL(MIN(ref_number),'') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number) 
			and ref_table = 'stops' 
			AND edicode = CASE @p_trlispup
 					WHEN 'N' Then 'TLSEAL'
 					WHEN 'Y' Then 'TLSL2'
 				        END
			AND labeldefinition = 'ReferenceNumbers'
				
		SELECT @v_seal2 = ISNULL(MIN(ref_number),'') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode =  CASE @p_trlispup
 					WHEN 'N' Then 'TLSEAL'
 					WHEN 'Y' Then 'TLSL2'
 				        END
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <> @v_seal1
		
		SELECT @v_seal3 = ISNULL(MIN(ref_number),'') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey  in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode = CASE @p_trlispup
 					WHEN 'N' Then 'TLSEAL'
 					WHEN 'Y' Then 'TLSL2'
 				        END
			AND labeldefinition = 'ReferenceNumbers'
			AND ref_number <>@v_seal1 AND ref_number <> @v_seal2	
	
		SELECT @v_seal4 = ISNULL(MIN(ref_number),'') 
		FROM	referencenumber	r
			INNER JOIN labelfile l
				ON l.abbr = r.ref_type
		WHERE	ref_tablekey in(SELECT stp_number FROM stops WHERE mov_number =@p_mov_number)
			and ref_table = 'stops' 
			AND edicode =  CASE @p_trlispup
 					WHEN 'N' Then 'TLSEAL'
 					WHEN 'Y' Then 'TLSL2'
 				        END
			AND labeldefinition = 'ReferenceNumbers'
		AND ref_number <> @v_seal3 AND ref_number <> @v_seal2 AND ref_number <> @v_seal1 
 

 
 	UPDATE #358_trldata
 	SET	seal1 = @v_seal1,
 		seal2 = @v_seal2,
 		seal3 = @v_seal3,
 		seal4 = @v_seal4
 	WHERE	trl_id = @p_trlid

IF @v_allowintlcity = 'Y'
	UPDATE #358_trldata
	SET		lic_country = ISNULL(isocode,'')
	FROM	country cc
		JOIN trailerprofile tl
			ON tl.trl_liccountry = cc.name
	WHERE tl.trl_id = @p_trlid		


IF @v_preliminary = 'N'
    BEGIN
	 IF (SELECT aceid_type FROM #358_trldata) = 'A7'
		 BEGIN
			INSERT INTO edi_358(data_col,batch_number,mov_number)
				SELECT '4|10|'+ trl_number + '|' +
					aceid_type + '|' +
					aceid + '|' + 
					ISNULL(equip_type,'TL') +'| | | |' +
					iit_flg + '|' +
					seal1 + '|' +
					seal2 + '|' +
					seal3 + '|' +
					seal4 + '|' +
					CAST(trlweight as Varchar(10)) +'|'+
					CAST(trlcount as varchar(10)) + '|' ,
					@p_e358batch,
					@p_mov_number
				FROM	#358_trldata
				WHERE	trl_id = @p_trlid
		 END		
	ELSE
		BEGIN
			INSERT INTO edi_358(data_col,batch_number,mov_number)
				SELECT '4|10|' + trl_number + '|' +
					aceid_type + '|' +
					aceid + '|' +
					equip_type + '|' +
					lic_num + '|' +
					lic_state + '|' +
					lic_country + '|' +
					iit_flg + '|' +
					seal1 + '|' +
					seal2 + '|' +
					seal3 + '|' +
					seal4 + '|' +
					CAST(trlweight as varchar(10))+ '|' +
					CAST(trlcount as varchar(10))+ '|',
					@p_e358batch,
					@p_mov_number
				FROM	#358_trldata
				WHERE	trl_id = @p_trlid
		END
     END
ELSE
     BEGIN
     	 IF (SELECT aceid_type FROM #358_trldata) = 'A7'
     		 BEGIN
     			INSERT INTO edi_358(data_col,batch_number,mov_number)
     				SELECT '4|10|'+ trl_number + '|' +
     					aceid_type + '|' +
     					aceid + '|' +
     					ISNULL(equip_type,'TL') +'| | | |' +
     					iit_flg + '|' +
     					seal1 + '|' +
     					seal2 + '|' +
     					seal3 + '|' +
     					seal4 + '|' +
     					' |'+
     					' |' ,
     					@p_e358batch,
     					@p_mov_number
     				FROM	#358_trldata
     				WHERE	trl_id = @p_trlid
     		 END		
     	ELSE
     		BEGIN
     			INSERT INTO edi_358(data_col,batch_number,mov_number)
     				SELECT '4|10|' +trl_number + '|' +
     					aceid_type + '|' +
     					aceid + '|' +
     					equip_type + '|' +
     					lic_num + '|' +
     					lic_state + '|' +
     					lic_country + '|' +
     					iit_flg + '|' +
     					seal1 + '|' +
     					seal2 + '|' +
     					seal3 + '|' +
     					seal4 + '|' +
     					' |' +
     					' |',
     					@p_e358batch,
     					@p_mov_number
     				FROM	#358_trldata
     				WHERE	trl_id = @p_trlid
		END
     END		
     
	

GO
GRANT EXECUTE ON  [dbo].[edi_358_equipment_record] TO [public]
GO
