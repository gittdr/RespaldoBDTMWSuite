SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_358_archive_delete] @mov_number int
/**
 * 
 * NAME:
 * dbo.edi_358_archive_delete
 *
 * TYPE:
 * Stored Procedure
 *
 * DESCRIPTION:
 * This procedure archives 358 data and deletes records from the edi_358 table.
 *
 * RETURNS:
 * A return value of zero indicates success. A non-zero return value
 * indicates a failure of some type
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * NONE
 * REFERENCES:
 * NONE
 * 
 * REVISION HISTORY:
 * 03/09/2006.01 - A.Rossman - Initial release.
 * 02/13/2008.02 - A. Rossman -PTS41385 - Added mov_number to input parms
 * 07/25/2013.03 - A.Rossman - updated to add context for inserted records.
 *
 **/
 
 AS
 
 DECLARE @v_userid varchar(30),@v_date datetime,@v_batchseq int,@v_batchcount int,@v_nextbatch int
 DECLARE @Counter int
 
  --Move the data from the edi_358 table into a temp table and then archive
  CREATE TABLE #temp_358 
  (
  	batch_seq	int 		NULL,
  	doctype		varchar(3)	NULL,
  	batch		int		NULL,
  	data_col	varchar(255)	NULL,
  	mov_number	int		NULL,
  	archive_date	datetime	NULL,
  	userid		varchar(30)	NULL
  )
  
 
 
 
 --determine the number of batches to be archived; 99.99% of the time this should be one
 SELECT @v_batchcount = COUNT(DISTINCT(batch_number)) FROM edi_358 WHERE mov_number = @mov_number
 
  exec gettmwuser @v_userid output
 
 SET @v_date = GETDATE()
 
 
 SELECT @v_nextbatch = 0
 
 
 WHILE @v_batchcount >= 1
 	BEGIN
 	SELECT @v_nextbatch = MIN(batch_number) FROM edi_358 WHERE batch_number > @v_nextbatch AND mov_number = @mov_number
 	SET @counter =0 
 	
 	     --Put the records into the temp table and then remove from the edi_358 table
 	     INSERT INTO #temp_358(doctype,batch,data_col,mov_number,archive_date,userid)
 	     SELECT
 	     		'358',
 	     		batch_number,
 	     		data_col,
 	     		mov_number,
 	     		@v_date,
 	     		@v_userid
	    FROM	edi_358
	    WHERE	batch_number = @v_nextbatch
	    		AND mov_number = @mov_number
	    	ORDER BY record_id ASC
	    	
 	    DELETE FROM edi_358 WHERE batch_number = @v_nextbatch AND mov_number = @mov_number
 	    
 	    UPDATE #temp_358
 	    SET @Counter = batch_seq = @Counter + 1
 	    
 	    
 	    --Move the records from the temp table to the archive table
 	    INSERT INTO ace_edidocument_archive(aea_doctype,aea_batch,aea_batch_seq,aea_datacol,mov_number,aea_archivedate,aea_tmwuser,aea_context)
 	    SELECT	doctype,
 	    		batch,
 	    		batch_seq,
 	    		data_col,
 	    		mov_number,
 	    		archive_date,
 	    		userid,
 	    		'ACE'
 	    FROM	#temp_358
 	    WHERE	batch = @v_nextbatch
 	    		AND mov_number = @mov_number
 	    	ORDER BY batch_seq
 	    	
 	     INSERT INTO emanifest_transaction_log(mov_number,etl_trans_doctype,etl_trans_sender,etl_trans_date,etl_trans_text,etl_trans_user)
		 SELECT 	 mov_number,
					 doctype,
					 'Dispatch',
					 archive_date,
					 'ACE 358 message created for move:'+ casT(@mov_number as varchar(30))+ ' Batch: ' + CAST(batch as VARCHAR(30)),
					 userid
		 FROM		 #temp_358
		 WHERE	     batch = @v_nextbatch
					AND mov_number = @mov_number
					AND batch_seq = 1 	    	

 	    SELECT @v_batchcount = @v_batchcount -1
 	    
 	    DELETE FROM #temp_358 WHERE batch =  @v_nextbatch AND mov_number = @mov_number
 	    
 	END    
 
GO
GRANT EXECUTE ON  [dbo].[edi_358_archive_delete] TO [public]
GO
