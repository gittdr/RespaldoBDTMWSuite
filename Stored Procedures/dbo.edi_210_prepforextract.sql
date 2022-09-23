SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_210_prepforextract]
	
AS
/**
 * 
 * NAME:
 * dbo.edi_210_prepfporextract
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Prepares data in the EDI_210 table for extraction to a 210 flat file.  
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * Returns the following columns from the #EDIOUT temp table:
 * data_col, doc_id, control_number,cmp_id
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES:
 * 
 * 
 * REVISION HISTORY:
 *  7/25/00 return id col to allow delete < max id in case rows added  during save 
 *  5/7/01 PTS10835 dpete destination ID on #TMW record can be longer than the 10
 *		positions indicated by the flat file specs, truntcate if necessary
 *	6/12/02 DPETE PTS 14347 add option to wrap each document
 *	12/15/04 DMEEK PTS 25868 expanded data_col columns for EDI temp tables to 255 characters
 *	05/27/05 AROSS PTS 28240 Fix to allow batch numbers to increment when wrap type is set to PART
 *	7/18/05 AROSS PTS 22898 Add company ID to result set.  
 *	9/30/05 AROSS PTS 29996 Handle wraptype Each more efficiently.  Corrected SCAC and Batch number logic.,
 *      2/13/08 A. Rossman - PTS 41393 - Expand TP ID Length to 20 characters in output.
 *	5/06/08 A. Rossman -  PTS 42267 - Correct batch numbers to 99999 to comply with industry standard
 *  2/26/10 A. Rossman - PTS 49961 - Expand dhata_col to 285 characters
 **/

declare @wraptype varchar(20), @partnercount int, @nexttrpid varchar(35),@trpid varchar(20),@nextdocid varchar(40)
declare @SCAC char(4), @batchnbr int, @batch varchar(6), @startrow int
declare  @formatdate char(6), @countrecords int,@doccount int
declare @formattime char(4), @hh varchar(2), @mi varchar(2)
declare @v_cmp_id	varchar(8)	   --PTS22898 Aross  Added.
 
-- run the customer specific code -- DMEEK added for Jim Teubner PTS 26654
exec prepare_for_edi_extract_sp

-- Define a table for output
CREATE TABLE #EDIout (data_col varchar(285),
doc_id  varchar(30), 
id_value int,
eo_identity_col int identity,
scac varchar(4) null,
control_number int null default -1,
cmp_id	varchar(8) null)	--22898

-- Get the record from the edi_210 table 
Create table #EDI (
data_col varchar(285) null,
doc_id varchar(30) null,
trp_id varchar(20) null,
identity_col int null,
scac varchar(4) null) 

CREATE INDEX temp_tmpdoc ON #edi (trp_id,doc_id)

-- determine which wrapper record are required
SELECT @wraptype = 
		CASE UPPER(ISNULL(gi_string1,'FULL'))
			WHEN 'PART' THEN 'PART'
			WHEN 'EACH' Then 'EACH'
			ELSE 'FULL'
		END  
FROM generalinfo
WHERE gi_name = 'EDIWrap'

SELECT @wraptype = ISNULL(@wraptype,'FULL')

--DPH PTS 26581
DELETE FROM edi_210
WHERE trp_id = 'NOVALUE'
--DPH PTS 26581

--Insert data from the edi_210 table into the #edi temp table prior to processing
Insert Into #EDI (data_col, doc_id, trp_id, identity_col)
SELECT  data_col,
	doc_id,
	trp_id,
	identity_col
FROM	edi_210
WHERE   doc_ID in (SELECT doc_id from edi_210 where UPPER(SUBSTRING(data_col,1,3)) = 'END')
and     UPPER (SUBSTRING(data_col,1,3)) <> 'END'
ORDER BY trp_id,doc_id,identity_col

--determine the number of trading partners being processed
SELECT @partnercount = COUNT(DISTINCT(trp_id))
FROM 	#EDI

-- Initialize
SELECT @nexttrpid = ' '

--Begin the trading partner Loop
WHILE @partnercount > 0
     BEGIN /*1*/
     	--get the next trading Partner
     	   SELECT @nexttrpid =  MIN(trp_id) FROM #EDI WHERE trp_id > @nexttrpid
     	   
     	   select @startrow = isnull((max(eo_identity_col)+1),1) from #ediout
     	   
     	   --Get the batch number from the trading partner profile
     	   		-- Get next control number for partner (allow for no records)

	    
	   	-- Convert for output   
	   	
	   	--PTS 41393 AROSS Updated to output 20 characters
	   	SELECT @trpid = Substring(@nexttrpid,1,20)
	 	
	 	--SELECT @trpid = Substring(@nexttrpid,1,10)  -- ouput field is only 10
   		SELECT @v_cmp_id = cmp_id FROM edi_trading_partner WHERE trp_210id = @trpid   --22898 Get cmp_id
   		
		-- format  current date to yymmdd , time to hhmi
		    SELECT @formatdate=CONVERT( VARCHAR(8),GETDATE(),12)
		    SELECT @formatdate = REPLICATE('0', 6 - DATALENGTH(@formatdate)) +
			@formatdate
		    SELECT @mi=CONVERT( VARCHAR(2),DATEPART(mi,GETDATE()))
		    SELECT @hh=CONVERT( VARCHAR(2),DATEPART(hh,GETDATE()))
		    SELECT @formattime=
			REPLICATE('0',2-DATALENGTH(@hh)) + @hh +
			REPLICATE('0',2-DATALENGTH(@mi)) + @mi


		--Process according to wrap type
		IF @wraptype = 'FULL'
	  		BEGIN /*3*/
	  			IF ( SELECT COUNT(*) FROM edi_trading_partner WHERE trp_210id = @nexttrpid) > 0
	   			BEGIN /*2*/
	                		SELECT @batchnbr = max(ISNULL(trp_NxtCtlNbr,1))
	   				FROM   edi_trading_partner
	   				WHERE  trp_210id = @nexttrpid
	   				
	   				IF @batchnbr = 99999		--PTS 42267; reset the batch number to 1 after it reaches 99999
	   					UPDATE edi_trading_partner
	   					SET		trp_NxtCtlNbr = 1
	   					WHERE  trp_210id = @nexttrpid
	   				ELSE
						UPDATE edi_trading_partner
						SET	  trp_NxtCtlNbr = (@batchnbr + 1)
						WHERE  trp_210id = @nexttrpid
	   			END /*2*/
	   			ELSE
	   			SELECT @batchnbr = 1		--AROSS  END 28240.  Moved for all wrap types.
	  			SELECT @batch=CONVERT(varchar(6),@batchnbr)  -- for output   
				--Get record count for TP
	  			SELECT @countrecords = COUNT(*) FROM #EDI  WHERE trp_id = @nexttrpid
		  	     
	  			--Get the SCAC code  	  	     
	  			SELECT @scac = substring(data_col,136,4) FROM #edi WHERE LEFT(data_col,1) = '1' and trp_id = @nexttrpid
	  			
	  			UPDATE #EDI SET scac = @scac WHERE trp_id = @nexttrpid
			   
				--Insert the #TMW record
				INSERT INTO #EDIout (data_col,doc_id, id_value)
						VALUES ('#TMW210 FROM ' +
								 @SCAC           +
								 replicate(' ',4 - datalength(@SCAC)) +
								 ' TO '          +
								 @trpid       +
								 replicate(' ',20 - datalength(@trpid))  +		--PTS41393 Updated to 20
								 ' ' +
								 @formatdate     +
								 ' '             +
								 @formattime     +
								 ' '             +
								 replicate('0',6-datalength(@batch))   +
								 @batch,'/',0)
			    -- Insert \\p record
				INSERT INTO #EDIout (data_col, doc_id, id_value)
						VALUES ('\\P:' +
								 @trpid     +
								 replicate(' ',20 - datalength(@trpid)),'/',0)			--PTS 41393 Updated to 20
								 
				-- Insert detail records
				INSERT INTO #Ediout (data_col, doc_id,id_value,cmp_id)
						SELECT data_col,doc_id,identity_col,@v_cmp_id
						FROM   #EDI
						WHERE   trp_id = @nexttrpid  	  
						--DPH PTS 22368 4/14/04
						--order by trp_id, identity_col
						order by  scac, doc_id, identity_col
						--DPH PTS 22368 4/14/04			
						
				--Insert the EOT Record
				INSERT INTO #EDIout (data_col,doc_id, id_value)
						VALUES ( '#EOT '+
								  replicate('0',6-datalength(@batch))   +
								  @batch     +
								  ' ' +
								  replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords))) +
								  CONVERT(varchar(6),@countrecords),'/', 0)	
				UPDATE #ediout SET control_number = @batch WHERE cmp_id = @v_cmp_id	
			END /*3*/
		IF @wraptype = 'EACH'
			BEGIN /*4*/	
				--Initialize
				SELECT @nextdocid = ''
				WHILE (SELECT COUNT(*) FROM #EDI WHERE trp_id = @nexttrpid and doc_id > @nextdocid) > 0
					BEGIN  /*5*/
						SELECT @nextdocid = MIN(doc_id) FROM #EDI WHERE trp_id = @nexttrpid and doc_id > @nextdocid	
						IF ( SELECT COUNT(*) FROM edi_trading_partner WHERE trp_210id = @nexttrpid) > 0
	   					 BEGIN /*2*/
							SELECT @batchnbr = max(ISNULL(trp_NxtCtlNbr,1))
	   						FROM   edi_trading_partner
	   						WHERE  trp_210id = @nexttrpid
	   						
	   						IF @batchnbr = 99999		--PTS 42267; reset the batch number to 1 after it reaches 99999
								UPDATE edi_trading_partner
								SET		trp_NxtCtlNbr = 1
	   							WHERE  trp_210id = @nexttrpid
	   						ELSE
								UPDATE edi_trading_partner
								SET	  trp_NxtCtlNbr = (@batchnbr + 1)
								WHERE  trp_210id = @nexttrpid
	   					END /*2*/
	   					ELSE
	   					SELECT @batchnbr = 1		--AROSS  END 28240.  Moved for all wrap types.
						SELECT @batch=CONVERT(varchar(6),@batchnbr)  -- for output   
						-- Get the record count for the EOT
						SELECT @countrecords = COUNT(*)FROM #EDI WHERE doc_id = @nextdocid
						                   			--Get the SCAC code  	  	     
	  					SELECT	@scac = SUBSTRING(data_col,136,4) 
	  					FROM	#edi 
	  					WHERE	LEFT(data_col,1) = '1' 
	  							and trp_id = @nexttrpid
	  							and doc_id = @nextdocid
	  							
	  					--Update the temp table with scac code data
	  					UPDATE #EDI SET scac =  @scac WHERE trp_id = @nexttrpid AND doc_id = @nextdocid		
	  				
	  				--insert the #TMW record			
	  				INSERT INTO #EDIout (data_col,doc_id,id_value)
						VALUES ('#TMW210 FROM ' +
								 @SCAC           +
								 REPLICATE(' ',4 - datalength(@SCAC)) +
								 ' TO '          +
								 @trpid       +
								 REPLICATE(' ',20 - datalength(@trpid))  +		--PTS41393 Updated to 20
								 ' ' +
								 @formatdate     +
								 ' '             +
								 @formattime     +
								 ' '             +
								 REPLICATE('0',6-datalength(@batch))   +
								 @batch, '/',0)			
					
					--insert the //P: record			 
                    			INSERT INTO #EDIout (data_col, doc_id,id_value)
						VALUES ('\\P:' +
								@trpid     +
								REPLICATE(' ',20 - datalength(@trpid)),'/',0)			--PTS 41393 Updated to 20
					
					--insert detail records for one doc id
					INSERT INTO #Ediout (data_col, doc_id,id_value,cmp_id)
					SELECT data_col,doc_id,identity_col,@v_cmp_id
					FROM   #EDI
					WHERE   trp_id = @nexttrpid and doc_id = @nextdocid
					order by scac, identity_col		
					
					--Add the EOT record
					INSERT INTO #EDIout (data_col,doc_id,id_value)
						VALUES ( '#EOT '+
								 REPLICATE('0',6-datalength(@batch))   +
								 @batch     +
								 ' ' +
								 REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR(6),@countrecords))) +
								 CONVERT(VARCHAR(6),@countrecords),'/',0)	
					UPDATE #ediout SET control_number = @batch WHERE doc_id = @nextdocid		 			
					END /*5*/
			END /*4*/
		IF @wraptype = 'PART'
	  		BEGIN /*6*/
	  			--Get the SCAC code  	  	     
	  			SELECT @scac = substring(data_col,4,4) FROM #edi WHERE LEFT(data_col,1) = '1' and trp_id = @nexttrpid
	  	     
	  			--update scac code
	  			UPDATE #EDI SET scac = @scac WHERE trp_id = @nexttrpid
	  			
	  			-- Insert \\p record
				INSERT INTO #EDIout (data_col,doc_id,id_value)
				VALUES ('\\P:' +
		     			@trpid       +
		     			replicate(' ',20 - datalength(@trpid)),'/',0)			--PTS 41393 Updated to 20
		     	     
				-- Insert detail records
				INSERT INTO #Ediout (data_col,doc_id,id_value,cmp_id)
				SELECT 	data_col,doc_id,identity_col,@v_cmp_id
				FROM   #EDI
				WHERE   trp_id = @nexttrpid
					ORDER BY  trp_id, doc_id, identity_col
			
			END /*6*/   
	   
	   --UPDATE #ediout SET control_number = @batch WHERE eo_identity_col > @startrow	
	   --decremcent partner count
	   SELECT @partnercount = @partnercount - 1
	 END /*1*/ --end partner loop	 

  --FINAL SELECT
SELECT data_col,doc_id,control_number,id_value,cmp_id FROM #EDIout
	ORDER BY eo_identity_col


GO
GRANT EXECUTE ON  [dbo].[edi_210_prepforextract] TO [public]
GO
