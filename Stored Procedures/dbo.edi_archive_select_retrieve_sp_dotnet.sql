SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
CREATE PROCEDURE [dbo].[edi_archive_select_retrieve_sp_dotnet]    
 @docType varchar( 12 ),    
 @ordnumber varchar(12),    
 @controlnumber varchar(10),    
 @batchdatestart varchar(12),    
 @batchdateend varchar(12),    
 @trpid varchar(30),    
 @ack824yn char(1),    
 @ack824flag char(2),    
 @ack997yn char(1),    
 @ack997flag char(2),    
 @typeofsearch char(1),    
 @invnumber varchar(12),    
 @ISAControlNum  varchar(10)    
AS    
/************Modifications**********    
 4/06/05 Aross PTS 27655; added status code to result set for lookup type 'A'.  Modified to select from Temp table.    
 7/05/05 Aross PTS 27624; added status reason code to result set for lookup type 'A'.    
 11/14/05 Aross PTS 30563 Added GS and ISA control number columns.    
 02/21/06 Aross PTS 30241 Added status date to the result set.    
 2/05/08  AROSS  PTS 40671 Added ISA Control to select    
 3/10/10 AROSS PTS 51345 Added criteria to temp table update 
 2/17/16 JRICH PTS 83960 Added 210 and 214 specific logic to prevent duplicate 210's
 3/24/16 JRICH PTS 100739 Updated to current TMW Standards
*/     
    
IF LEN(RTRIM(isnull(@ordnumber,''))) = 0 SELECT @ordnumber = '##'    
IF LEN(RTRIM(isnull(@controlnumber,''))) = 0 SELECT @controlnumber= '##'    
IF LEN(RTRIM(isnull(@invnumber,''))) = 0 SELECT @invnumber= '##'    
IF LEN(RTRIM(isnull(@ISAControlNum,''))) = 0 SELECT @isaControlNum = '##'   --40671    
    
declare @batchstart datetime2, @batchend datetime2    
    
--Create a temp table to hold archive values    
IF @typeofsearch = 'A'
BEGIN
CREATE TABLE #result_set (edt_doctype varchar(5) NULL,    
     edt_batch_datetime_id varchar(12) NULL,    
     trp_id varchar(20) NULL,    
     edt_docID varchar(50) NULL,    
     edt_extract_dttm datetime2 NULL,    
     edt_extract_count smallint NULL,    
     edt_ack_dttm datetime2 NULL,    
     edt_ack_flag varchar(6) NULL,    
     edt_batch_image_seq int NULL,    
     edt_batch_control int NULL,    
     edt_batch_doc_seq int NULL,    
     edt_997_dttm datetime2 NULL,    
     edt_997_flag varchar(6) NULL,    
     edt_selected char NULL,    
     ord_number varchar(13) NULL,    
     ivh_invoicenumber varchar(12) NULL,    
     status_code varchar(5) NULL,    
     status_reason varchar(3) NULL,    
     edt_GS_control_number int NULL,    
     edt_ISA_control_number int NULL,    
     status_date varchar(10) NULL,    
     status_time varchar(5)  NULL,  
     edt_id int null,
	 edt_source varchar(128) null,
	 edt_user varchar(128) null,
	 edt_extractapp varchar(128) null
    )    
END
    
IF @typeofsearch = 'A' AND @docType = '210'     
BEGIN    
INSERT INTO #result_set    
SELECT edt_doctype,    
 edt_batch_datetime_id,    
 trp_id,    
 edt_docID,    
 edt_extract_dttm,    
 edt_extract_count,    
 edt_ack_dttm,    
 edt_ack_flag,    
 edt_batch_image_seq,    
 edt_batch_control,    
 edt_batch_doc_seq,    
 edt_997_dttm,    
 edt_997_flag,    
 edt_selected,    
 ord_number,    
 ivh_invoicenumber,    
 '',    
 '',    
 edt_GS_control_number,    
 edt_ISA_control_number,    
 '',    
 '',  
 edt_id,
 edt_source,
 edt_user,
 edt_extractapp
FROM edi_document_tracking      
WHERE edt_batch_image_seq = 1     
 AND edt_doctype = @doctype    
 AND @trpid in (trp_id,'UNKNOWN')    
 AND @controlnumber in (convert(varchar(10),edt_batch_control), '##')    
 AND @ordnumber in (ord_number, '##')    
 AND @invnumber in (ivh_invoicenumber,'##')    
 AND edt_batch_datetime_id between @batchdatestart and @batchdateend    
 AND @ISAControlNum in (convert(varchar(10),edt_isa_control_number),'##')   --40671    
 AND (@ack824yn = '?' --?,?    
 or (@ack824yn = 'Y' AND edt_ack_flag = @ack824flag) --Y,value    
 or (@ack824yn = 'Y' and @ack824flag = '?' AND edt_ack_flag IS NOT NULL) --Y,?    
 or (@ack824yn = 'N' and edt_ack_flag IS NULL)) --N,?    
 AND (@ack997yn = '?' --?,?    
 or (@ack997yn = 'Y' AND edt_997_flag = @ack997flag) --Y,value    
 or (@ack997yn = 'Y' and @ack997flag = '?' AND edt_997_flag IS NOT NULL) --Y,?    
 or (@ack997yn = 'N' and edt_997_flag IS NULL)) --N    

/* 
 --update the temp table with the appropriate status code from the 3 record for the matching doc ID    
 UPDATE #result_set    
 SET status_code = substring(d.edt_image,4,2),    
  status_reason = substring(d.edt_image,82,3),    
  status_date = substring(d.edt_image,6,8),    
  status_time = substring(d.edt_image,14,4)    
 FROM edi_document_tracking d    
 WHERE #result_set.edt_docid = d.edt_docid    
	AND d.edt_doctype = '214'     
	AND left(d.edt_image,3) = '339'    
	and d.edt_batch_datetime_id = #result_set.edt_batch_datetime_id
   AND #result_set.edt_batch_doc_seq = d.edt_batch_doc_seq --51345    
   AND #result_set.edt_batch_control = d.edt_batch_control    
    
*/    
 --Return the result set    
 SELECT edt_doctype ,    
         edt_batch_datetime_id,    
        trp_id,    
       edt_docID,    
         edt_extract_dttm,    
  edt_extract_count,    
  edt_ack_dttm,    
  edt_ack_flag,    
  edt_batch_image_seq,    
  edt_batch_control,    
  edt_batch_doc_seq,    
  edt_997_dttm,    
  edt_997_flag,    
  edt_selected,    
  ord_number,    
  ivh_invoicenumber,    
  status_code ,    
  status_reason,    
  edt_GS_control_number,    
  edt_ISA_control_number,    
  status_date,    
  status_time,   
  edt_id,
  edt_source,
  edt_user,
  edt_extractapp
       
 FROM #result_set    
 drop table #result_set    
     
END     

ELSE IF @typeofsearch = 'A' AND @docType = '214'     
BEGIN    
INSERT INTO #result_set    
SELECT edt_doctype,    
 edt_batch_datetime_id,    
 trp_id,    
 edt_docID,    
 edt_extract_dttm,    
 edt_extract_count,    
 edt_ack_dttm,    
 edt_ack_flag,    
 edt_batch_image_seq,    
 edt_batch_control,    
 edt_batch_doc_seq,    
 edt_997_dttm,    
 edt_997_flag,    
 edt_selected,    
 ord_number,    
 ivh_invoicenumber,    
 '',    
 '',    
 edt_GS_control_number,    
 edt_ISA_control_number,    
 '',    
 '',  
 edt_id,
 edt_source,
 edt_user,
 edt_extractapp
FROM edi_document_tracking      
WHERE LEFT(edt_image,1)='3'	--PTS75406 replaced edt_batch_image_seq = 1      
 AND edt_doctype = @doctype    
 AND @trpid in (trp_id,'UNKNOWN')    
 AND @controlnumber in (convert(varchar(10),edt_batch_control), '##')    
 AND @ordnumber in (ord_number, '##')    
 AND @invnumber in (ivh_invoicenumber,'##')    
 AND edt_batch_datetime_id between @batchdatestart and @batchdateend    
 AND @ISAControlNum in (convert(varchar(10),edt_isa_control_number),'##')   --40671    
 AND (@ack824yn = '?' --?,?    
 or (@ack824yn = 'Y' AND edt_ack_flag = @ack824flag) --Y,value    
 or (@ack824yn = 'Y' and @ack824flag = '?' AND edt_ack_flag IS NOT NULL) --Y,?    
 or (@ack824yn = 'N' and edt_ack_flag IS NULL)) --N,?    
 AND (@ack997yn = '?' --?,?    
 or (@ack997yn = 'Y' AND edt_997_flag = @ack997flag) --Y,value    
 or (@ack997yn = 'Y' and @ack997flag = '?' AND edt_997_flag IS NOT NULL) --Y,?    
 or (@ack997yn = 'N' and edt_997_flag IS NULL)) --N    

 --update the temp table with the appropriate status code from the 3 record for the matching doc ID    
 UPDATE #result_set    
 SET status_code = substring(d.edt_image,4,2),    
  status_reason = substring(d.edt_image,82,3),    
  status_date = substring(d.edt_image,6,8),    
  status_time = substring(d.edt_image,14,4)    
 FROM edi_document_tracking d    
 WHERE #result_set.edt_docid = d.edt_docid    
	AND d.edt_doctype = '214'     
	AND left(d.edt_image,3) = '339'    
	and d.edt_batch_datetime_id = #result_set.edt_batch_datetime_id
   AND #result_set.edt_batch_doc_seq = d.edt_batch_doc_seq --51345    
   AND #result_set.edt_batch_control = d.edt_batch_control    
      
 --Return the result set    
 SELECT edt_doctype ,    
         edt_batch_datetime_id,    
        trp_id,    
       edt_docID,    
         edt_extract_dttm,    
  edt_extract_count,    
  edt_ack_dttm,    
  edt_ack_flag,    
  edt_batch_image_seq,    
  edt_batch_control,    
  edt_batch_doc_seq,    
  edt_997_dttm,    
  edt_997_flag,    
  edt_selected,    
  ord_number,    
  ivh_invoicenumber,    
  status_code ,    
  status_reason,    
  edt_GS_control_number,    
  edt_ISA_control_number,    
  status_date,    
  status_time,   
  edt_id,
  edt_source,
  edt_user,
  edt_extractapp
       
 FROM #result_set    
     
     
END     


ELSE     
begin    
    
select @batchdatestart = isnull(@batchdatestart,'200001010000'),    
  @batchdateend = isnull(@batchdateend,'204912312359')    
    
select  @batchstart = left(@batchdatestart,4)+'-'+    
     substring(@batchdatestart,5,2)+'-'+    
     substring(@batchdatestart,7,2)+' '+    
     substring(@batchdatestart,9,2)+':'+    
     substring(@batchdatestart,11,2),    
  @batchend = left(@batchdateend,4)+'-'+    
     substring(@batchdateend,5,2)+'-'+    
     substring(@batchdateend,7,2)+' '+    
     substring(@batchdateend,9,2)+':'+    
     substring(@batchdateend,11,2)    
IF @typeofsearch ='U'    
 SELECT     
 edt.edt_doctype,    
 edt.edt_extract_dttm,    
 edt.trp_id,    
 edt.edt_docID,    
 edt.edt_ack_flag,    
 edt.edt_batch_control,    
 edt.edt_batch_doc_seq,    
 edt.edt_997_flag,    
 edt.ord_number,    
 i.ivh_billdate,     
 convert(int,substring(edt.edt_image,93,7)), --charge    
 i.ivh_invoicenumber,    
sum(convert(int,substring(b.edt_image,93,7))),
count(*),
  edt.edt_id    
 FROM edi_document_tracking edt    
 LEFT JOIN invoiceheader i ON edt.ivh_invoicenumber = i.ivh_invoicenumber    
  inner JOIN edi_document_tracking b ON edt.edt_batch_control = b.edt_batch_control
 where edt.edt_batch_image_seq = 1  
  and b.edt_batch_image_seq = edt.edt_batch_image_seq  
  AND edt.edt_doctype = @doctype    
  AND @trpid in (edt.trp_id,'UNKNOWN')    
  AND @controlnumber in (convert(varchar(10),edt.edt_batch_control), '##')    
  AND @ordnumber in (edt.ord_number, '##')    
  AND @invnumber in (edt.ivh_invoicenumber,'##')    
  AND i.ivh_billdate between @batchstart and @batchend    
  AND (@ack824yn = '?' --?,?    
  or (@ack824yn = 'Y' AND edt.edt_ack_flag = @ack824flag) --Y,value    
  or (@ack824yn = 'Y' and @ack824flag = '?' AND edt.edt_ack_flag IS NOT NULL) --Y,?    
  or (@ack824yn = 'N' and edt.edt_ack_flag IS NULL)) --N,?    
  AND (@ack997yn = '?' --?,?    
  or (@ack997yn = 'Y' AND edt.edt_997_flag = @ack997flag) --Y,value    
  or (@ack997yn = 'Y' and @ack997flag = '?' AND edt.edt_997_flag IS NOT NULL) --Y,?    
  or (@ack997yn = 'N' and edt.edt_997_flag IS NULL)) --N  
  
  group by
  edt.edt_doctype,
  edt.trp_id,    
  edt.edt_batch_control,
  edt.edt_extract_dttm,    
  edt.edt_docID,    
  edt.edt_ack_flag,    
  edt.edt_batch_doc_seq,    
  edt.edt_997_flag,    
  edt.ord_number,    
  i.ivh_billdate,     
  i.ivh_invoicenumber,
  edt.edt_image,  
  edt.edt_id
  
end    
  
GO
GRANT EXECUTE ON  [dbo].[edi_archive_select_retrieve_sp_dotnet] TO [public]
GO
