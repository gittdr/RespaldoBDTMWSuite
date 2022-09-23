SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[d_edi_214_viewstatus] @ord_num varchar(13)

AS 
/**
 * 
 * NAME:
 * dbo.d_edi_214_viewstatus
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure returns the result set to the view edi statuses sent for an order in Visual Dispatch
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * 
 *
 * PARAMETERS:
 * 001 - @p_reg_number, varchar(10), input, null;
 *       This parameter indicates the number of the registration 
 *       to which the note data is associated. The value must be 
 *       non-null and non-empty.
 * 002 - @p_note_type, varchar(6), input, null;
 *       This parameter indicates the type of note for which 
 *       deletion is requested. The value must be non-null and 
 *       non-empty.
 * 003 - @p_ntb_table, varchar(18), input, null;
 *       This parameter indicates the table to which the note 
 *       data is associated. The value must be non-null and 
 *       non-empty.
 *
 * REFERENCES: (called by and calling references only, don't 
 * 
 * REVISION HISTORY:
 * 03/1/2005.01 ? PTSnnnnn - AuthorName ? Revision Description
 * 07/05/2005.01  PTS28715 -A.Rossman | Retrieve all archived 214 statuses and all of those in the 214 table for the current order
 * 02/21/2006.02  PTS30241 -A.Rossman | Added the Status Reason Code,997 and 824 flags to the result set.
 *
 **/

declare @docid varchar(30)





CREATE TABLE #214_temp
	(	
		tp_id		varchar(20) NULL,
		status		varchar(6)  NULL,
		status_date	varchar(8) NULL,
		status_time	varchar(4)  NULL,
		city_state	varchar(20) NULL,
		stp_seq		varchar(3)  NULL,
		extr_date	datetime    NULL,
		pending		char(1)	    NULL,
		sr_code		varchar(6)  NULL,
		flg_997		varchar(6)  NULL,
		flg_824		varchar(6)  NULL,
		docid		varchar(50) NULL
	)	
		
--Insert all records from the archive table for the current order.		
INSERT INTO #214_temp
    SELECT tp_id  = edi_document_tracking.trp_id,
    	   status = SUBSTRING(edi_document_tracking.edt_image,4,2),
	   status_date = SUBSTRING(edi_document_tracking.edt_image,6,8),
	   status_time = SUBSTRING(edi_document_tracking.edt_image,14,4),
	   city_state = RTRIM(SUBSTRING(edi_document_tracking.edt_image,20,18))+ ','+SUBSTRING(edi_document_tracking.edt_image,38,2),
	   stp_seq = SUBSTRING(edi_document_tracking.edt_image,85,3),
	   extr_date = edt_extract_dttm,
	   pending = 'F',
	   sr_code = SUBSTRING(edi_document_tracking.edt_image,82,3),
	   null,
	   null,
	   docid = edi_document_tracking.edt_docID
	FROM edi_document_tracking   
	WHERE ord_number = @ord_num
			AND edi_document_tracking.edt_doctype = 214
			AND LEFT(edi_document_tracking.edt_image,3) = '339'
	ORDER BY edt_extract_dttm
	
--Update the 997 and 824 flags
UPDATE	#214_temp
SET 	flg_997 = ISNULL(edt_997_flag,''),
	flg_824 = ISNULL(edt_ack_flag,'')
FROM	edi_document_tracking
WHERE	edt_DocID = docid
	 and edt_batch_image_seq = 1
	
--If there are any records pending for the current order loop through and insert into the temp table
IF (SELECT count(*) FROM edi_214 where data_col Like '139%' and RTRIM(SUBSTRING(data_col,8,15)) = @ord_num) > 0
    BEGIN
  	DECLARE cur_docid CURSOR FOR
  	SELECT Distinct(doc_id) FROM edi_214 
  	where data_col Like '139%' and RTRIM(SUBSTRING(data_col,8,15)) = @ord_num
  	
  	OPEN cur_docid
  	FETCH NEXT FROM cur_docid INTO @docid
  	
  	WHILE @@FETCH_STATUS = 0
  	   BEGIN
  	   	INSERT INTO #214_temp
  	   	SELECT	tp_id = trp_id,
  	   		status = SUBSTRING(data_col,4,2),
  	   		status_date = SUBSTRING(data_col,6,8),
  	   		status_time = SUBSTRING(data_col,14,4),
  	   		city_state = RTRIM(SUBSTRING(data_col,20,18))+ ','+SUBSTRING(data_col,38,2),
  	   		stp_seq = SUBSTRING(data_col,85,3),
  	   		extr_date = ' ',
  	   		pending = 'T',
  	   		sr_code = SUBSTRING(data_col,82,3),
  	   		null,
  	   		null,
  	   		@docid
  	   	FROM EDI_214
  	   	WHERE data_col like '339%' AND doc_id = @docid
  	   	
  	   	FETCH NEXT FROM cur_docid INTO @docid
  	   END
  	   
  	  CLOSE cur_docid
  	DEALLOCATE cur_docid
  	
  END	

--final select	
Select 		tp_id,		
		status,		
		status_date,	
		status_time,	
		city_state,	
		stp_seq	,	
		extr_date,	
		pending,		
		sr_code,		
		flg_997,		
		flg_824
FROM	#214_temp		

GO
GRANT EXECUTE ON  [dbo].[d_edi_214_viewstatus] TO [public]
GO
