SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[edi_214_prepforextract_dotnet] 
/*
 * 
 * NAME:
 * dbo.edi_214_prepfporextract
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * Prepares data in the EDI_214 table for extraction to a 214 flat file.  
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
 * DPETE  PTS 14347 Add new wrap option EACH to wrap a #TMW,//p,#EOT around each transaction
 * AROSS  PTS 27612 Add indexes to temp tables for performance enhancement
 * AROSS  PTS 28240 Moved batch number logic outside of wraptype loop
 * AROSS  PTS 22898 Added company id to the result set
 * 7.27.2005 AROSS PTS 29093. Stored Proc re-written to handle multi-scacs more efficirently
 * 11.16.2005 AROSS PTS 30597. Re-added call to customer specific proc.
 * 12/06/05 - PTS 30839 - ARoss - Correct batch number issue for 'EACH' wraptype.
  * 02/13/08 - PTS 41393 - A. Rossman - Updated output length for trading partner to 20 characters
 * 05/06/08 - PTS 42267 - A.Rossman - Correct batch control to 99999 max
 * 11/04/10 - PTS 54663 - M.Curnutt - change how indexes are created (clustered) get rid of unnecessary indexes on temp tables, change cursor to set based.
 * 06/16/11 - PTS 56542 - M Curnutt -- Fix duplicates coming through when DocID is not unique (USA Truck)
 * 06/16/11 - PTS 61114 - C Thomas -- Fix issue with batch control. change from Equals to Greater Than or Equals
 * 02/17/14 - PTS 70732 - A.Rossman - fix for recompile issues. 
 */
	
	
AS

DECLARE @wraptype varchar(20), @partnercount int, @nexttrpid varchar(20),@nextdocid varchar(50)
DECLARE @SCAC Varchar(4), @batchnbr int, @batch varchar(6),@trpid varchar(20), @startrow int
DECLARE  @formatdate char(6), @countrecords int
DECLARE @formattime char(4), @hh varchar(2), @mi varchar(2)
DECLARE @purge_data_col varchar(200), @delete_nextdocid varchar(30)
DECLARE @v_cmp_id varchar(8)	--PTS 22898 Aross 

-- run customer specific updates.
exec prepare_for_edi_extract_sp

-- Define a table for output    
--AROSS 27612 Moved creation of temp table and added indexes  
DECLARE @EDIout   TABLE
 (data_col varchar(200),   
  doc_id varchar(30),  
  eo_identity_col int identity,   
  identity_col int,
  control_number int null default -1,  
  SCAC varchar(4) null,  
  cmp_id varchar(8) null)   --PTS 22898 added cmp_id  
  
--CREATE UNIQUE CLUSTERED INDEX temp_tmpdoc2 ON #EDIout (eo_identity_col )
  
--Create a temp table to hold data from edi_214 table  
DECLARE @EDI TABLE(  
data_col varchar(200) null,  
trp_id varchar(20) null,  
doc_id varchar(30) null,  
identity_col int null,  
scac varchar(4) null) 
  
--CREATE CLUSTERED INDEX temp_tmpdoc  ON #EDI (trp_id,doc_id)  

DECLARE  @docs_to_keep TABLE (doc_id varchar(30))
--create unique clustered index temp_temp3 on #docs_to_keep(doc_id)

	--Determine the wrap type that is to be used for extracting the files

	SELECT @wraptype = 
		CASE gi_string1
			WHEN 'PART' THEN 'PART'
			WHEN 'EACH' THEN 'EACH'
			WHEN  NULL  THEN 'FULL'
			ELSE 'FULL'
		END  
	FROM	generalinfo
	WHERE	gi_name = 'EDIWrap'

	SELECT @wraptype=UPPER(ISNULL(@wraptype,'FULL'))
	

--MTC PTS 54663 11/04/2010
insert @docs_to_keep
select distinct doc_id from edi_214  --56542
                  where data_col like 'END%'  
          and doc_id in (
select distinct doc_id FROM edi_214 WHERE doc_id > '' and doc_id <>'/')
order by doc_id

INSERT into edi_214_purge (data_col, doc_id)  
select data_col, doc_id from edi_214 where data_col like '139%' and doc_id not in (
select doc_id from @docs_to_keep)

delete from edi_214 where doc_id not in (select doc_id from @docs_to_keep)
--MTC PTS 54663 11/04/2010
 

--Move data from the EDI_214 table to the temp Table
INSERT INTO @EDI (data_col, doc_id, trp_id, identity_col)
SELECT	data_col,
	doc_id,
	trp_id,
	identity_col
FROM	edi_214
WHERE   doc_ID in (SELECT doc_id FROM edi_214 WHERE UPPER(SUBSTRING(data_col,1,3)) = 'END')
and     UPPER (SUBSTRING(data_col,1,3)) <> 'END' and trp_id <> ''
ORDER BY trp_id,doc_id,identity_col


-- format  current date to yymmdd , time to hhmi
	SELECT @formatdate=CONVERT( VARCHAR(8),GETDATE(),12)
	SELECT @formatdate = REPLICATE('0', 6 - DATALENGTH(@formatdate)) +
	@formatdate
	SELECT @mi=CONVERT( VARCHAR(2),DATEPART(mi,GETDATE()))
	SELECT @hh=CONVERT( VARCHAR(2),DATEPART(hh,GETDATE()))
	SELECT @formattime=
	REPLICATE('0',2-DATALENGTH(@hh)) + @hh +
	REPLICATE('0',2-DATALENGTH(@mi)) + @mi

	DECLARE EDI_CURSOR CURSOR FAST_FORWARD FOR
	select trp_id from @EDI group by trp_id order by trp_id

	OPEN EDI_CURSOR

	FETCH NEXT FROM EDI_CURSOR INTO @nexttrpid

	WHILE @@FETCH_STATUS = 0
     BEGIN /*1*/
     	     	   
     	   select @startrow = isnull((max(eo_identity_col)+1),1) from @ediout
     	   
     	   --PTS 41393 Updated output length for TP ID to 20
     	   SELECT @trpid = Substring(@nexttrpid,1,20)  

	 	SELECT @v_cmp_id = cmp_id FROM edi_trading_partner with(nolock)
		WHERE trp_id = @trpid   --22898 Get cmp_id
   		

			
	  --Process records according to wraptype
	  IF @wraptype = 'FULL'
	  	BEGIN /*3*/
	  	    --Get record count for TP
	  	     SELECT @countrecords = COUNT(*) FROM @EDI  WHERE trp_id = @nexttrpid
	  	     --Get the batch number from the trading partner profile
     	   	-- Get next control number for partner (allow for no records)
	   	    IF ( SELECT COUNT(*) FROM edi_trading_partner with(nolock)
			WHERE trp_id = @nexttrpid) > 0
	   	     BEGIN /*2*/
	                SELECT @batchnbr = max(ISNULL(trp_NxtCtlNbr,1))
					FROM   edi_trading_partner with(nolock)
					WHERE  trp_id = @nexttrpid
	   			
	   			IF @batchnbr >= 99999		--PTS 42267; Reset the batch control number to 1; PTS 61114: Added Greater Than
	   				UPDATE	edi_trading_partner
	   				SET		trp_NxtCtlnbr = 1
	   				WHERE	trp_id = @nexttrpid
	   			ELSE	
	        		        UPDATE edi_trading_partner
				       SET	  trp_NxtCtlNbr = (@batchnbr + 1)
				      WHERE  trp_id = @nexttrpid
	   	    END /*2*/
	   	  ELSE
	   	   SELECT @batchnbr = 1		--AROSS  END 28240.  Moved for all wrap types.
	    
	   	-- Convert for output   
	 	SELECT @batch=CONVERT(varchar(6),@batchnbr)  -- for output   
	  	     
	  	     --Get the SCAC code  	  	     
	  	     SELECT @scac = substring(data_col,4,4) FROM @edi WHERE LEFT(data_col,1) = '1' and trp_id = @nexttrpid
	  	     
	  	     	    INSERT INTO @EDIout (data_col,doc_id)
		     	    VALUES ('#TMW214 FROM ' +
		     	   	@SCAC           +
		     		 replicate(' ',4 - datalength(@SCAC)) +
		     		 ' TO '          +
		     		 @trpid      +
		     		 replicate(' ',20 - datalength(@trpid))  +			--41393 Updated to 20
		                 ' ' +
		     		 @formatdate     +
		     		 ' '             +
		     		 @formattime     +
		     		 ' '             +
		     		 replicate('0',6-datalength(@batch))   +
		     		 @batch, '/')
		     
		     	-- Insert \\p record
		     	    INSERT INTO @EDIout (data_col,doc_id)
		     	    VALUES ('\\P:' +
		     		  @trpid       +
		     		  replicate(' ',20 - datalength(@trpid)),'/')			--PTS 41393 Updated to 20
		     
		     	-- Insert detail records
		     	    INSERT INTO @Ediout (data_col,doc_id,cmp_id, identity_col)
		     	    SELECT 	data_col,doc_id,@v_cmp_id, identity_col
		     	    FROM   @EDI
		     	    WHERE   trp_id = @nexttrpid
	   			 ORDER BY  trp_id, doc_id, identity_col
	   			 
	   		--Insert EOT record
	   		
			     INSERT INTO @EDIout (data_col,doc_id)
			     VALUES ( '#EOT '+
				  replicate('0',6-datalength(@batch))   +
				  @batch     +
				  ' ' +
				  replicate('0', 6 - datalength(CONVERT(varchar(6),@countrecords))) +
			    CONVERT(varchar(6),@countrecords),'/')
			    
			    update @ediout set control_number = @batch where eo_identity_col > @startrow
	   	END /*3*/
	  IF @wraptype = 'EACH'
		BEGIN /*4*/
			--Initialize
			SELECT @nextdocid = ''
			WHILE (SELECT COUNT(*) FROM @EDI WHERE trp_id = @nexttrpid and doc_id > @nextdocid) > 0
				BEGIN  /*5*/
					SELECT @nextdocid = MIN(doc_id) FROM @EDI WHERE trp_id = @nexttrpid and doc_id > @nextdocid 	
					--Get the batch number from the trading partner profile
     	   			-- Get next control number for partner (allow for no records)
	   				 IF ( SELECT COUNT(*) FROM edi_trading_partner with(nolock)
					 WHERE trp_id = @nexttrpid) > 0
	   					 BEGIN /*2*/
							SELECT @batchnbr = max(ISNULL(trp_NxtCtlNbr,1))
	   						FROM   edi_trading_partner with(nolock)
	   						WHERE  trp_id = @nexttrpid
	   						
	   						       IF @batchnbr >= 99999		--PTS 42267; Reset the batch control number to 1 ; PTS 61114: Added Greater Than
									UPDATE	edi_trading_partner
									SET		trp_NxtCtlnbr = 1
									WHERE	trp_id = @nexttrpid
	   							ELSE
	   
									  UPDATE edi_trading_partner
									  SET	  trp_NxtCtlNbr = (@batchnbr + 1)
									  WHERE  trp_id = @nexttrpid
	   					END /*2*/
	   				ELSE
	   					SELECT @batchnbr = 1		--AROSS  END 28240.  Moved for all wrap types.
	    
				 	-- Convert for output   
	 				SELECT @batch=CONVERT(varchar(6),@batchnbr)  -- for output   
					-- Get the record count for the EOT
                    SELECT @countrecords = COUNT(*)FROM @EDI WHERE doc_id = @nextdocid
                    
                   			--Get the SCAC code  	  	     
	  				SELECT	@scac = SUBSTRING(data_col,4,4) 
	  				FROM	@edi 
	  				WHERE	LEFT(data_col,1) = '1' 
	  							and trp_id = @nexttrpid
	  							and doc_id = @nextdocid
	  				
	  				--insert the #TMW record			
	  				INSERT INTO @EDIout (data_col,doc_id)
						VALUES ('#TMW214 FROM ' +
								 @SCAC           +
								 REPLICATE(' ',4 - datalength(@SCAC)) +
								 ' TO '          +
								 @trpid       +
								 REPLICATE(' ',20 - datalength(@trpid))  +			--41393 Updated to 20
								 ' ' +
								 @formatdate     +
								 ' '             +
								 @formattime     +
								 ' '             +
								 REPLICATE('0',6-datalength(@batch))   +
								 @batch, '/')			
					
					--insert the //P: record			 
                    			INSERT INTO @EDIout (data_col, doc_id)
						VALUES ('\\P:' +
								@trpid     +
								REPLICATE(' ',20 - datalength(@trpid)),'/')			--41393 Expanded to 20
					
					--insert detail records for one doc id
					INSERT INTO @Ediout (data_col, doc_id,cmp_id,identity_col)
							SELECT data_col,doc_id,@v_cmp_id, identity_col
							FROM   @EDI
							WHERE   trp_id = @nexttrpid and doc_id = @nextdocid
									ORDER BY  identity_col			
					
					--Add the EOT record
					INSERT INTO @EDIout (data_col,doc_id)
						VALUES ( '#EOT '+
								 REPLICATE('0',6-datalength(@batch))   +
								 @batch     +
								 ' ' +
								 REPLICATE('0', 6 - DATALENGTH(CONVERT(VARCHAR(6),@countrecords))) +
								 CONVERT(VARCHAR(6),@countrecords),'/')	
				update @ediout set control_number = @batch where doc_id = @nextdocid				 			
				END /*5*/
		END /*4*/
	  IF @wraptype = 'PART'
	  	BEGIN /*6*/
	  		--Get the SCAC code  	  	     
	  	     SELECT @scac = substring(data_col,4,4) FROM @edi WHERE LEFT(data_col,1) = '1' and trp_id = @nexttrpid
	  	     
	  	     -- Insert \\p record
		     INSERT INTO @EDIout (data_col,doc_id)
		     VALUES ('\\P:' +
		     	     @trpid       +
		     	     replicate(' ',20 - datalength(@trpid)),'/')				--41393 Expanded to 20
		     	     
		     -- Insert detail records
		     INSERT INTO @Ediout (data_col,doc_id,cmp_id,identity_col)
		     SELECT 	data_col,doc_id,@v_cmp_id, identity_col
		     FROM   @EDI
		     WHERE   trp_id = @nexttrpid
			ORDER BY  trp_id, doc_id, identity_col
			
		END /*6*/   
	   FETCH NEXT FROM EDI_CURSOR INTO @nexttrpid
	   		
	 END /*1*/ --end partner loop
	 	CLOSE EDI_CURSOR
	    DEALLOCATE EDI_CURSOR
	 
	 
--Final Select
SELECT data_col, doc_id, control_number,cmp_id, IsNull(identity_col,0) as identity_col FROM @EDIout
order by eo_identity_col 	 
     

GO
GRANT EXECUTE ON  [dbo].[edi_214_prepforextract_dotnet] TO [public]
GO
