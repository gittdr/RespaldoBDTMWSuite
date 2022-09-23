SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[edi_214_record_id_6_39_sp] 
	@p_trpid varchar(20),
	@p_docid varchar(30),
	@p_fgt_number int
 as
 /**
 * 
 * NAME:
 * dbo.edi_214_record_id_6_39_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates the OS&D or "6" record in the 214 flat file
 *
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * 001 - @p_trpid, varchar(20), input, not null;
 *       This parameter indicates the trading partner ID 
 *       for which the 214 is being created . Must be
 *       non-null and non-empty.
 * 002 - @p_docid, varchar(30), input, notnull;
 *       This parameter indicates the document id 
 *       for the current 214 transaction. The value must be non-null and 
 *       non-empty.
 * 003 - @p_fgt_number, integer not null;
 *		 Parameter identifies the freight detail for which the OS&D record is being created.
 *		 Must be non-null and non-empty.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? NONE
 * CalledBy001 ? edi_214_record_id_3_39_sp 
 * 
 * REVISION HISTORY:
 * 08/8/2005.01 ? PTS27619 - A. Rossman ? Changed procedure from a stub to implement new OS&D functionality in TMWSuite
 * 09/13/2005.02 - PTS 29718 - A.Rossman - Allow user to define a list of reference types to be appended to the end of the 
 *											record.  Only the first 15 characters of each ref. number will be used.
 * 02/12/2007.03 - PTS 36210 - A.Rossman - Correct Output for OSD records.
 *
 **/



declare @osdcode		varchar(6),
		@osd_unit		varchar(6),
		@osd_comment	varchar(30),
		@osd_qty		int,
		@v_reflist		varchar(60),
		@v_NextRefType	varchar(6),
		@v_refnum		varchar(30),
		@v_refstring	varchar(255),
		@startpos		int,
		@nextpos		int,
		@osdrefcount		int

		

SELECT	@osdcode = ISNULL(fgt_osdreason,'UNK'),
		@osd_unit = ISNULL(fgt_osdunit,'UNK'),
		@osd_qty = ISNULL(fgt_osdquantity,0),
		@osd_comment = ISNULL(fgt_osdcomment,' ')
FROM	freightdetail
WHERE	fgt_number = @p_fgt_number	

 --PTS 29718 Start Aross
SELECT @v_refstring = ''	--initialize var
SELECT @v_reflist = gi_string1, @startpos = 1, @nextpos = 1 FROM generalinfo WHERE gi_name = 'EDI214_AddOSDRef'
IF LEN(@v_reflist) > 0
    BEGIN  /*1*/ 
    
    SET @osdrefcount = 1

		WHILE @nextpos > 0 AND @osdrefcount <=5
			BEGIN /*2*/  
				SELECT @nextpos = CHARINDEX(',',@v_reflist,@startpos)
					IF @nextpos > 0
					BEGIN  /*3*/ 
						SELECT @v_NextRefType = SUBSTRING(@v_reflist,@startpos,@nextpos - @startpos), @startpos = @nextpos + 1
							IF LEN(@v_NextRefType) > 0
							  BEGIN /*4*/
									IF (SELECT COUNT(*) FROM referencenumber WHERE ref_tablekey = @p_fgt_number AND ref_type = @v_NextRefType
							  			AND ref_table = 'freightdetail'	) > 0
							  			BEGIN /*6*/
							  				SELECT @v_refnum = MAX(LEFT(ISNULL(ref_number,''),30))
							  				FROM	referencenumber
							  				WHERE 	ref_tablekey = @p_fgt_number 
							  					AND ref_type = @v_NextRefType
							  					AND ref_table = 'freightdetail'
										  	
							  				SELECT @v_refstring = @v_refstring  + @v_NextRefType  + replicate(' ',6 - datalength(@v_NextRefType)) + @v_refnum	+ replicate(' ',30 - datalength(@v_refnum))
							  				SET @osdrefcount = @osdrefcount + 1
							  			END/*6*/	
							  END /*4*/	
			
					END/*3*/	
			ELSE
				BEGIN	/*5*/ 
					SELECT @v_NextRefType = SUBSTRING(@v_reflist,@startpos,LEN(@v_reflist) +1 - @startpos), @startpos = @nextpos + 1
						IF LEN(@v_NextRefType) > 0
							BEGIN /*7*/
								IF (SELECT COUNT(*) FROM referencenumber WHERE ref_tablekey = @p_fgt_number AND ref_type = @v_NextRefType
							  			AND ref_table = 'freightdetail'	) > 0
							  		BEGIN /*8*/	
										SELECT @v_refnum = MAX(LEFT(ISNULL(ref_number,''),30))
							  			FROM	referencenumber
							  			WHERE 	ref_tablekey = @p_fgt_number 
							  					AND ref_type = @v_NextRefType
							  					AND ref_table = 'freightdetail'
									  	
							  			SELECT @v_refstring = @v_refstring  + @v_NextRefType  + replicate(' ',6 - datalength(@v_NextRefType)) + @v_refnum	+ replicate(' ',30 - datalength(@v_refnum))
							  			SET @osdrefcount = @osdrefcount + 1
							  		END /*8*/
							  END /*7*/							
				END	/*5*/ 
			END/*2*/	
    	 
    END	/*1*/		  --END PTS29718 AROSS 	
		
  If @osdcode <> 'UNK'
	BEGIN
		INSERT edi_214 (data_col,trp_id,doc_id)
		SELECT 
		data_col = '6' +				-- Record ID
		'39' +						-- Record Version
		@osdcode +	replicate(' ',1-datalength(@osdcode)) +	-- OSD code
		@osd_unit +	replicate(' ',3-datalength(@osd_unit)) +	-- quantity qualifier
		replicate('0',6-datalength(rtrim(@osd_qty)))+ CONVERT(varchar(6),(RIGHT(@osd_qty,6)))  +	--quantity
		@osd_comment + replicate(' ',30-datalength(@osd_comment)) + 	--comment
		@v_refstring,
		trp_id=@p_trpid, doc_id = @p_docid
	END	



GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_6_39_sp] TO [public]
GO
