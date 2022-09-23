SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_extractfromarchive]
	@docType varchar( 12 ),
	@ordnumber varchar(12),
	@controlnumber varchar(10),
	@batchdatestart varchar(12),
	@batchdateend varchar(12),
	@trpid varchar(30),
	@docid varchar(50),
	@ackyn char(1),
	@ackFatalYN char(2),
	@useOriginalControl char(1) = 'N',
	@ack997yn char(1) = '?',
	@ack997flag char(2) = null
as
	 /**
 * 
 * NAME:
 * dbo.edi_extractfromarchive
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns a result set of archived edi data to be re-extracted to flat file.
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @docType, varchar(12), input, null;
 *       This parameter indicates the type of edi document being re-extracted. 210 or 214. 
 * 002 - @ordnumber, varchar(12), input, null;
 *       This parameter indicates a specific order number that archived data is being extracted for. (optional) 
 * 003 - @controlnumber, varchar(10), input, null;
 *       This parameter indicates the edi document controlnumber that archives are being extracted for.(optional) 
 * 004 - @batchdatestart, varchar(12), input, null;
 *		 Starting date in a range for data to be retrieved.
 * 005 - @batchdateend varchar(12), input, null;
 *		 Ending date in a  range for data to  be retrieved.
 * 006 - @trpid, varchar(30), input null;
 *		 Trading partner ID that data is being retrieved based on.(optional)
 * 007 - @useOriginalControl, char(1);
 *		 Determines whether the original control number will be used when re-extracting edi data or if a new
 *		 control number will be generated.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 *  NONE
 * 
 * REVISION HISTORY:
 *  AROSS PTS27889  Added to where clause in count to fix performance hit on larger databases
 *  8/11/2005.02 PTS29304 A. Rossman populate the scac code based on the one record of either the 210 or 214 data being extracted.
 *  9/30/2005.03 PTS 29996 -  A. Rossman - Modified to handle re-extract for wraptype EACH.
 * 08/03/2007.04 PTS 38720 - A. Rossman - Correction to re-extraction logic for SCACs
 * 01/07/2009.05 PTS 45617 - A. Rossman - Expanded trading partner length to 20 characters in wrappers
 * 09/21/2009 PRS 49169 - D.Wilks add company id for re-extract to trp_id specific locations
 **/
 
   
-- Create a dummy value for docid, ordnumber and controlnumber if necessary.
IF LEN(RTRIM(isnull(@docid,''))) = 0 SELECT @docID = '##'
IF LEN(RTRIM(isnull(@ordnumber,''))) = 0 SELECT @ordnumber = '##'
IF LEN(RTRIM(isnull(@controlnumber,''))) = 0 SELECT @controlnumber= '##'

DECLARE @wraptype varchar(20), @partnercount int, @nexttrpid varchar(35)
DECLARE @SCAC char(4), @batchnbr int, @batch varchar(6)
DECLARE @formatdate char(6), @countrecords int
DECLARE @formattime char(4), @hh varchar(2), @mi varchar(2)
DECLARE @control_number int, @doc_sequence int
DECLARE @nextdocid varchar(40)
DECLARE @v_cmp_id varchar(8)	--PTS 49169 DWilk

-- Initialize
SELECT @nexttrpid = ' '

-- determine which wrapper record are required

SELECT @wraptype = 
	CASE UPPER(ISNULL(gi_string1,'FULL'))
		WHEN 'PART' THEN 'PART'
		WHEN 'EACH' THEN 'EACH'		--9.30.2005 AR
		ELSE 'FULL'
	END  
FROM generalinfo
WHERE gi_name = 'EDIWrap'

SELECT @wraptype = ISNULL(@wraptype,'FULL')

-- get the SCAC code 
--SELECT @SCAC=UPPER(CONVERT(CHAR(4),ISNULL(gi_string1,'SCAC')))
--FROM generalinfo 
--WHERE gi_name='SCAC'					 --Removed PTS 29304 

SELECT @scac = ISNULL(@scac,'SCAC')
	
/*   Collect the data to dump  */
CREATE TABLE #ediextract (
	edt_image varchar(800),
	trp_id varchar(20),
	edt_docid varchar(50),
	edt_batch_image_seq int,
	edt_control_number int null,
	edt_batch_doc_seq int,
	edt_id int null) 

IF ((select count(*) from edi_document_Tracking where edt_selected ='Y'
		AND edt_doctype = @doctype and edt_batch_datetime_id BETWEEN  @batchdatestart and @batchdateend) = 0) --AROSS PTS 27889 added to where clause
	IF  @ackYn = '?' and @ack997yn = '?'
		INSERT INTO #ediextract
		SELECT edt_image, trp_id,edt_docid, edt_batch_image_seq,edt_batch_control,edt_batch_doc_seq,edt_id
		FROM edi_document_tracking 
		WHERE 	edt_doctype = @Doctype and
			edt_batch_datetime_id BETWEEN  @batchdatestart and @batchdateend and
			@trpid in (edi_document_tracking.trp_id,'UNKNOWN') and
			@docid in (edt_docid,'##') and
			@ordnumber in (ord_number,'##') and
			@controlnumber in (convert(varchar(10),edt_batch_control),'##')
		ORDER BY trp_id, edt_docid, edt_batch_image_seq
	ELSE
		INSERT INTO #ediextract
		SELECT edt_image, trp_id,edt_docid, edt_batch_image_seq,edt_batch_control,edt_batch_doc_seq,edt_id
		FROM edi_document_tracking 
		WHERE 	edt_doctype = @Doctype and
			edt_batch_datetime_id BETWEEN  @batchdatestart and @batchdateend and
			@trpid in (edi_document_tracking.trp_id,'UNKNOWN') and
			@docid in (edt_docid,'##') and
			@ordnumber in (ord_number,'##') and
			@controlnumber in (convert(varchar(10),edt_batch_control),'##') and
			((@ackyn = 'Y' and @ackFatalYN = 'Y' and edt_ack_flag = 'IR')
			or
			(@ackyn = 'Y' and @ackFatalYN = 'N' and edt_ack_flag <> 'IR')
			or
			(@ackyn = 'N' and edt_ack_flag IS NULL) ) 
		ORDER BY trp_id, edt_docid, edt_batch_image_seq
ELSE
BEGIN
	INSERT INTO #ediextract
	SELECT edt_image, trp_id, edt_docid, edt_batch_image_seq,edt_batch_control,edt_batch_doc_seq,edt_id
	FROM edi_document_tracking 
	WHERE 	edt_doctype = @Doctype and
		edt_selected = 'Y'
	ORDER BY edt_docid, edt_batch_image_seq

	-- This update is performed by the application, too, so I might remove it from there.**	
	UPDATE edi_document_tracking set edt_selected = 'N' where IsNull(edt_selected,'Y') <> 'N'
END

SELECT @partnerCount = COUNT(DISTINCT(trp_id)) FROM #ediextract

/* Define a table for output */
CREATE TABLE #edioutx (data_col varchar(800),control_number int null,eo_identity_col int identity, cmp_id varchar(8) null) --PTS 49169 added cmp_id

/* Loop thru and process by partner */
While @partnercount > 0
BEGIN --#1
	SELECT @nexttrpid = MIN(trp_id)	FROM #ediextract WHERE trp_id > @nexttrpid
	SELECT @v_cmp_id = cmp_id FROM edi_trading_partner WHERE @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end  --49169 Get cmp_id
	IF @wraptype = 'FULL' 
	BEGIN --#2
	/* Format current date to yymmdd, time to hhmm.*/
		select @formatdate=convert( char(6),Getdate(),12)
		select @mi=convert( varchar(2),datepart(mi,Getdate()))
		select @hh=convert(varchar(2),datepart(hh,Getdate()))
		select @formattime=	replicate('0',2-datalength(@hh)) + @hh + replicate('0',2-datalength(@mi)) + @mi
	  	IF @useOriginalControl = 'Y'
	  	BEGIN --#3
			-- Use the original control numbers from the archive.
			select @batchnbr = min(edt_control_number) from #ediextract where trp_id = @nexttrpid
			WHILE @batchnbr is not null
	        BEGIN --#4
	        
	        			/* AROSS PTS 29304 Get the SCAC code from the one record.*/
			  IF @doctype ='214'
				BEGIN --#5
					SELECT @SCAC = SUBSTRING(edt_image,4,8) 
					FROM #ediextract 
					WHERE	trp_id = @nexttrpid and 
						LEFT(edt_image,3) = '139'
						AND edt_control_number = @batchnbr
						AND edt_id = (Select min(edt_id) from #ediextract where trp_id = @nexttrpid and edt_control_number = @batchnbr) 
				END --#5		

			IF @doctype ='210'
				BEGIN --#6
					SELECT @SCAC = SUBSTRING(edt_image,136,4) 
					FROM #ediextract 
					WHERE	trp_id = @nexttrpid and 
						LEFT(edt_image,3) = '139'
						AND edt_control_number = @batchnbr
						AND edt_id = (Select min(edt_id) from #ediextract where trp_id = @nexttrpid and edt_control_number = @batchnbr)
				END 	--#6		
					
				
				-- Get record count.
				SELECT @countrecords = COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid and @batchnbr = edt_control_number
				-- Convert batch to varchar6.
				SELECT @batch = CONVERT(varchar(6),@batchnbr)      		
				INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
				-- Insert full header records.
				VALUES ('#TMW'+LEFT(@docType,3)+' FROM '+
					@SCAC+replicate(' ',4 - datalength(@SCAC))+' TO '+
					@nexttrpid+replicate(' ',20 - datalength(@nexttrpid))+' '+		--45617 AR
					@formatdate+' '+
					@formattime+' '+
					replicate('0',6-datalength(@batch))+@batch,@batchnbr,@v_cmp_id)
				INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
				VALUES ('\\P:' + @nexttrpid + replicate(' ',20 - datalength(@nexttrpid)),@batchnbr,@v_cmp_id)	--45617 AR

				-- Insert detail records for this partner and batch number.
				INSERT INTO #Edioutx (data_col,control_number,cmp_id)
				SELECT edt_image, @batchnbr, @v_cmp_id
				FROM   #ediextract
				WHERE   trp_id = @nexttrpid and edt_control_number = @batchnbr
				order by edt_docid, edt_control_number, edt_batch_doc_seq, edt_batch_image_seq
				-- Insert full trailer record.
				INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
				VALUES ( '#EOT '+
				replicate('0',6-datalength(@batch))+@batch+' '+
				replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords)))+CONVERT(varchar(6),@countrecords),@batchnbr,@v_cmp_id)

				-- Get next batch number greater than current batch number for this partner.
				select @batchnbr = min(edt_control_number) from #ediextract where edt_control_number > @batchnbr and trp_id = @nexttrpid
			END --#4
		END --#3
		ELSE -- They are not using the original control numbers, so recreate as a new batch.
		BEGIN --#7
		-- Get next control number for partner (allow for no records.)
		-- Need to use etp.trp_id for 214s and .trp210id for 210s.
			IF ( SELECT COUNT(*) FROM edi_trading_partner WHERE @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end ) > 0
			BEGIN --#8
				SELECT @batchnbr = ISNULL(trp_NxtCtlNbr,1)
				FROM   edi_trading_partner
				WHERE  @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end
				
				IF @batchnbr = 99999		--PTS 45617 reset control number to 1
					UPDATE edi_trading_partner
					SET		trp_NxtCtlNbr = 1
					WHERE @nexttrpid = CASE @doctype WHEN '214' THEN trp_id WHEN '210' THEN trp_210id END
				ELSE
					UPDATE edi_trading_partner
					SET	trp_NxtCtlNbr = (@batchnbr + 1)
					WHERE  @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end
			END--#8
			ELSE -- Oops, no current trading partner defined for this archived data. Use batchnbr = 1.
				SELECT @batchnbr = 1
			-- Convert batchnbr to varchar6.
			SELECT @batch = CONVERT(varchar(6),@batchnbr)  
			-- Get record count.
			SELECT @countrecords = COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid
			--AROSS PTS 29304 Get the SCAC code
				   IF @doctype ='214'
				   BEGIN --#9
						SELECT	@SCAC = SUBSTRING(edt_image,4,8) 
						FROM	#ediextract 
						WHERE	trp_id = @nexttrpid 
						    AND	LEFT(edt_image,3) = '139'
							AND edt_id = (SELECT MIN(edt_id) FROM #ediextract WHERE trp_id = @nexttrpid) 
				    END--#9		

					IF @doctype ='210'
					BEGIN  --#10
						SELECT	@SCAC = SUBSTRING(edt_image,136,4) 
						FROM	#ediextract 
						WHERE	trp_id = @nexttrpid 
						    AND	LEFT(edt_image,3) = '139'
							AND edt_id = (SELECT MIN(edt_id) FROM #ediextract WHERE trp_id = @nexttrpid)
					END			--#10
			              			
			-- Insert header records.
			INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
			VALUES ('#TMW'+LEFT(@docType,3)+' FROM '+
			@SCAC+
			replicate(' ',4 - datalength(@SCAC))+
			' TO '+
			@nexttrpid+
			replicate(' ',20 - datalength(@nexttrpid))+' '+		--45617 AR
			@formatdate+' '+
			@formattime+' '+
			replicate('0',6-datalength(@batch))+@batch,@batchnbr,@v_cmp_id)
			INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
			VALUES ('\\P:'+@nexttrpid+replicate(' ',20 - datalength(@nexttrpid)),@batchnbr,@v_cmp_id)	--45617 AR

			-- Insert detail records.
			INSERT INTO #Edioutx (data_col,control_number, cmp_id)
			SELECT edt_image, @batchnbr, @v_cmp_id
			FROM   #ediextract
			WHERE   trp_id = @nexttrpid
			order by edt_docid, edt_control_number, edt_batch_doc_seq, edt_batch_image_seq

			INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
			VALUES ( '#EOT '+
				replicate('0',6-datalength(@batch))+@batch+' '+
				replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords))) +
			CONVERT(varchar(6),@countrecords),@batchnbr,@v_cmp_id)				
		END --#7
	END --#2			
	
	--9.30.2005 AR Start EACH Wrapping
	IF @wraptype = 'EACH'
	BEGIN --#EACH 1
			/* Format current date to yymmdd, time to hhmm.*/
	        SELECT @formatdate=CONVERT( CHAR(6),GETDATE(),12)
		SELECT @mi=CONVERT( VARCHAR(2),DATEPART(mi,GETDATE()))
		SELECT @hh=CONVERT(VARCHAR(2),DATEPART(hh,GETDATE()))
		SELECT @formattime=	REPLICATE('0',2-DATALENGTH(@hh)) + @hh + REPLICATE('0',2-DATALENGTH(@mi)) + @mi
	  	IF @useOriginalControl = 'Y'
	  	BEGIN --#EACH2
	  		SELECT @nextdocid = ''
	  		WHILE (SELECT COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid and edt_docid > @nextdocid) > 0
	  		BEGIN  --#EACH3
	  			SELECT @nextdocid = MIN(EDT_docid) FROM #ediextract WHERE trp_id = @nexttrpid and edt_docid > @nextdocid	

				BEGIN --#EACH 4
					
					-- Use the original control numbers from the archive.
					SELECT @batchnbr = MIN(edt_control_number) FROM #ediextract WHERE trp_id = @nexttrpid AND edt_docid = @nextdocid
					SELECT @batch = CONVERT(varchar(6),@batchnbr)  --convert for output
		        
	        		/* AROSS PTS 29304 Get the SCAC code from the one record.*/
					IF @doctype ='214'
					BEGIN
						SELECT	@SCAC = SUBSTRING(edt_image,4,8) 
						FROM	#ediextract 
						WHERE	trp_id = @nexttrpid 
							AND LEFT(edt_image,3) = '139'
							AND edt_docid = @nextdocid
						END		

					IF @doctype ='210'
					BEGIN
						SELECT @SCAC = SUBSTRING(edt_image,136,4) 
						FROM #ediextract 
						WHERE	trp_id = @nexttrpid 
							AND LEFT(edt_image,3) = '139'
							AND edt_docid = @nextdocid
							--AND edt_control_number = @batchnbr
							--AND edt_id = (Select min(edt_id) from #ediextract where trp_id = @nexttrpid and edt_control_number = @batchnbr)
					END 	
					
								-- Insert header records.
					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ('#TMW'+LEFT(@docType,3)+' FROM '+
					@SCAC+
					replicate(' ',4 - datalength(@SCAC))+
					' TO '+
					@nexttrpid+
					replicate(' ',20 - datalength(@nexttrpid))+' '+		--45617 AR
					@formatdate+' '+
					@formattime+' '+
					replicate('0',6-datalength(@batch))+@batch,@batchnbr,@v_cmp_id)
					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ('\\P:'+@nexttrpid+replicate(' ',20 - datalength(@nexttrpid)),@batchnbr,@v_cmp_id)		--45617 AR

					-- Insert detail records.
					INSERT INTO #Edioutx (data_col,control_number, cmp_id)
					SELECT edt_image, @batchnbr, @v_cmp_id
					FROM   #ediextract
					WHERE   trp_id = @nexttrpid
					    AND edt_docid  = @nextdocid
					order by edt_docid, edt_control_number, edt_batch_doc_seq, edt_batch_image_seq

				-- Get record count.
				SELECT @countrecords = COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid AND edt_docid  = @nextdocid
			
					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ( '#EOT '+
						replicate('0',6-datalength(@batch))+@batch+' '+
						replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords))) +
					CONVERT(varchar(6),@countrecords),@batchnbr,@v_cmp_id)	
					
				END	 -- EACH 4
			END --EACH 3
		END --EACH 2	
		ELSE	--Generate new batch numbers 
			SELECT @nextdocid = ''
	  		WHILE (SELECT COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid and edt_docid > @nextdocid) > 0
	  		BEGIN  --#EACH New Batch
	  			SELECT @nextdocid = MIN(EDT_docid) FROM #ediextract WHERE trp_id = @nexttrpid and edt_docid > @nextdocid
				IF ( SELECT COUNT(*) FROM edi_trading_partner WHERE @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end ) > 0
				BEGIN --#8
					SELECT @batchnbr = ISNULL(trp_NxtCtlNbr,1)
					FROM   edi_trading_partner
					WHERE  @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end

					IF @batchnbr = 99999				--45617 Reset batch control to 1
						UPDATE edi_trading_partner
						SET		trp_NxtCtlNbr = 1
						WHERE	@nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end
					ELSE
						UPDATE edi_trading_partner
						SET	trp_NxtCtlNbr = (@batchnbr + 1)
						WHERE  @nexttrpid = CASE @doctype when '214' then trp_id when '210' then trp_210id end
						
				END--#8
				ELSE -- Oops, no current trading partner defined for this archived data. Use batchnbr = 1.
				SELECT @batchnbr = 1
					-- Convert batchnbr to varchar6.
				SELECT @batch = CONVERT(varchar(6),@batchnbr) 
				SELECT @countrecords = COUNT(*) FROM #ediextract WHERE trp_id = @nexttrpid and edt_docid = @nextdocid
				        		/* AROSS PTS 29304 Get the SCAC code from the one record.*/
					IF @doctype ='214'
					BEGIN
						SELECT	@SCAC = SUBSTRING(edt_image,4,8) 
						FROM	#ediextract 
						WHERE	trp_id = @nexttrpid 
							AND LEFT(edt_image,3) = '139'
							AND edt_docid = @nextdocid
						END		

					IF @doctype ='210'
					BEGIN
						SELECT @SCAC = SUBSTRING(edt_image,136,4) 
						FROM #ediextract 
						WHERE	trp_id = @nexttrpid 
							AND LEFT(edt_image,3) = '139'
							AND edt_docid = @nextdocid
							--AND edt_control_number = @batchnbr
							--AND edt_id = (Select min(edt_id) from #ediextract where trp_id = @nexttrpid and edt_control_number = @batchnbr)
					END 	
					
								-- Insert header records.
					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ('#TMW'+LEFT(@docType,3)+' FROM '+
					@SCAC+
					replicate(' ',4 - datalength(@SCAC))+
					' TO '+
					@nexttrpid+
					replicate(' ',20 - datalength(@nexttrpid))+' '+		--45617 AR
					@formatdate+' '+
					@formattime+' '+
					replicate('0',6-datalength(@batch))+@batch,@batchnbr,@v_cmp_id)
					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ('\\P:'+@nexttrpid+replicate(' ',20 - datalength(@nexttrpid)),@batchnbr,@v_cmp_id)	--45617 AR

					-- Insert detail records.
					INSERT INTO #Edioutx (data_col,control_number, cmp_id)
					SELECT edt_image, @batchnbr, @v_cmp_id
					FROM   #ediextract
					WHERE   trp_id = @nexttrpid
					    AND edt_docid  = @nextdocid
					order by edt_docid, edt_control_number, edt_batch_doc_seq, edt_batch_image_seq

					INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
					VALUES ( '#EOT '+
						replicate('0',6-datalength(@batch))+@batch+' '+
						replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords))) +
					CONVERT(varchar(6),@countrecords),@batchnbr,@v_cmp_id)	
			 END
	
	
	END --#EACH 1 
	
	
	--ELSE -- Don't use full wrapping.	9.30.2005 AR Commented Out Else and added IF statements for PART and EACH
	
	IF @wraptype = 'PART'
	BEGIN -- Insert the \\P header and the detail records only.
		-- Header.
		INSERT INTO #EDIoutx (data_col,control_number,cmp_id)
		VALUES ('\\P:'+@nexttrpid+replicate(' ',20 - datalength(@nexttrpid)),@batchnbr,@v_cmp_id)	--45617 AR

		-- Insert detail records.
		INSERT INTO #Edioutx (data_col,control_number,cmp_id)
		SELECT edt_image, edt_control_number,@v_cmp_id
		FROM   #ediextract
		WHERE   trp_id = @nexttrpid
		order by edt_docid, edt_control_number, edt_batch_doc_seq, edt_batch_image_seq
	END
	SELECT @partnercount = @partnercount - 1
END --#1

SELECT data_col,control_number, cmp_id FROM #EDIoutx
order by eo_identity_col
GO
GRANT EXECUTE ON  [dbo].[edi_extractfromarchive] TO [public]
GO
