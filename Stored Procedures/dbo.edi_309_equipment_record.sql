SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_309_equipment_record] 
	@p_trlid varchar(13),
	@p_iit_code	varchar(2),
	@p_trlispup	char(1),
	@p_trl_wgt	int,
	@p_trl_count	int,
	@p_e309batch 	int,
	@p_mov_number	int
as

/**
 * 
 * NAME:
 * dbo.edi_309_equipment_record
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the #4 or conveyance record in the EDI 309 document.
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
 * CalledBy001 ? edi_309_manifest_header
 * CalledBy002 ? 

 * 
 * REVISION HISTORY:
 * 02/28/2006.01 ? PTS31886 - A.Rossman ? Initial Release
 * 06/27/2006.02 - PTS33469 - A.Rossman - Remove embeded spaces from license plate data and limit data sent based on ACE registration
 * 09/19/2006.03 - PTS34551 - A.Rossman - Add additional edit to remove any dashes from the license plate data prior to creating the record .Use trl_id instead of trl_number
 * 09/18/2007.04 - PTS39448 - A.Rossman - Include Equipment type indicator for all records.
 **/
 
DECLARE @v_seal1 varchar(15),@v_seal2 varchar(15),@v_seal3 varchar(15),@v_seal4 varchar(15)
DECLARE @v_ord_hdrnumber int
DECLARE @v_gitype varchar(8),@v_trltype varchar(6)
DECLARE @v_allowintlcity CHAR(1)


 --declare the temp table variable
 CREATE TABLE #309_trldata 
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
 

 --34551
 SELECT @v_allowintlcity = ISNULL(LEFT(UPPER(gi_string1),1),'N') FROM generalinfo WHERE gi_name = 'AllowInternationalCity'


SELECT @v_gitype = ISNULL(LEFT(UPPER(gi_string1),8),'TL') FROM generalinfo WHERE gi_name = 'ACE:TrailerType'
 
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
 
 /*
 		--34451 Use trl_id
*/
 
 SELECT @v_ord_hdrnumber = min(ord_hdrnumber) 
 FROM orderheader 
 WHERE mov_number = @p_mov_number
 	AND (Select count(*) from referencenumber where ref_tablekey =ord_hdrnumber and ref_table = 'orderheader' and ref_type in('TLSEAL','TLSL2')) > 0
 

 
 INSERT INTO #309_trldata
 	SELECT	@p_trlid,	
 		trl_number,
 		ISNULL(l.edicode,abbr),
 		ISNULL(t.trl_aceid,'UNK'),
 		@v_trltype,
 		ISNULL(REPLACE(t.trl_licnum,' ',''),'UNK'),
 		ISNULL(t.trl_licstate,'UNK'),
 		ISNULL(LEFT(t.trl_liccountry,2),' '),
 		@p_iit_code,
 		' ',
 		' ',
 		' ',
 		' ',
 		@p_trl_wgt,
 		@p_trl_count
 	FROM	trailerprofile t
 		JOIN labelfile l
 			ON t.trl_aceidtype = l.abbr
 	WHERE	t.trl_id = @p_trlid			--Use trl_id
 		AND l.labeldefinition = 'AceIDType'
 
 --PTS 34551 remove any dashes from the license plate number.
 UPDATE	#309_trldata
 SET		lic_num = REPLACE(lic_num,'-','')
 WHERE		trl_id is not null
 --END 34551
 
 --Get the seal numbers
 
	--Update with the seal numbers
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
 

 	UPDATE #309_trldata
 	SET	seal1 = @v_seal1,
 		seal2 = @v_seal2,
 		seal3 = @v_seal3,
 		seal4 = @v_seal4
 	WHERE	trl_id = @p_trlid
 	
--PTS 34551
IF @v_allowintlcity = 'Y'
	UPDATE #309_trldata
	SET		lic_country = ISNULL(isocode,'')
	FROM	country cc
		JOIN	trailerprofile tl
			ON cc.name = tl.trl_liccountry
	WHERE	tl.trl_id = @p_trlid		

 IF (SELECT aceid_type FROM #309_trldata) = 'A7'
	 BEGIN
		INSERT INTO edi_309(data_col,batch_number,mov_number)
			SELECT '5|10|'+				--record id; version
				trl_number+ '|' +				--trailer number
				aceid_type + '|' +			--ACE ID qualifier
				aceid + '|' + 					--ACE ID
				equip_type+ '|' +			--equipment type indicator
				'|||' +						--license plate,state & country
				iit_flg + '|' +					--IIT indicator
				seal1 + '|' +					--seal 1-4
				seal2 + '|' +	
				seal3 + '|' +
				seal4 + '|' +
				CAST(trlweight as Varchar(10)) +'|'+		--total weight
				CAST(trlcount as varchar(10)) + '|' ,		--total count
				@p_e309batch,
				@p_mov_number
			FROM	#309_trldata
			WHERE	trl_id = @p_trlid
	 END		
ELSE
	BEGIN
		INSERT INTO edi_309(data_col,batch_number,mov_number)
			SELECT '5|10|' + trl_number + '|' +
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
				@p_e309batch,
				@p_mov_number
			FROM	#309_trldata
			WHERE	trl_id = @p_trlid
	END
	

GO
GRANT EXECUTE ON  [dbo].[edi_309_equipment_record] TO [public]
GO
