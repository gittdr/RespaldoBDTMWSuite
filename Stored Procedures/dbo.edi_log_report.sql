SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[edi_log_report] 
	@docType varchar( 12 ),
	@ordnumber varchar(12),
	@controlnumber varchar(10),
	@batchdatestart datetime,
	@batchdateend datetime,
	@trpid varchar(30),
	@ack824yn char(1),
	@ack824flag char(2),
	@ack997yn char(1),
	@ack997flag char(2),
	@typeofsearch char(1),
	@invnumber varchar(12)
as
IF LEN(RTRIM(isnull(@trpid,''))) = 0 SELECT @trpid = 'UNKNOWN'
IF LEN(RTRIM(isnull(@ack824yn,''))) = 0 SELECT @ack824yn = '?'
IF LEN(RTRIM(isnull(@ack997yn,''))) = 0 SELECT @ack997yn = '?'
IF LEN(RTRIM(isnull(@ordnumber,''))) = 0 SELECT @ordnumber = '##'
IF LEN(RTRIM(isnull(@controlnumber,''))) = 0 SELECT @controlnumber= '##'
IF LEN(RTRIM(isnull(@invnumber,''))) = 0 SELECT @invnumber= '##'
IF LEN(RTRIM(isnull(@batchdatestart,''))) = 0 or @batchdatestart = '1900-01-01' SELECT @batchdatestart= '2000-01-01'
IF LEN(RTRIM(isnull(@batchdateend,''))) = 0 or @batchdateend = '1900-01-01' SELECT @batchdateend= '2049-12-31'

if len(isnull(@typeofsearch,'')) = 0 select @typeofsearch = 'A'

IF @typeofsearch = 'A' 
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
	ivh_invoicenumber
FROM edi_document_tracking  
WHERE edt_batch_image_seq = 1 
	AND edt_doctype = @doctype
	AND @trpid in (trp_id,'UNKNOWN')
	AND @controlnumber in (convert(varchar(10),edt_batch_control), '##')
	AND @ordnumber in (ord_number, '##')
	AND @invnumber in (edt_docid,'##')
	AND left(edt_batch_datetime_id,4)+'-'+substring(edt_batch_datetime_id,5,2)+'-'+substring(edt_batch_datetime_id,7,2)+' '+substring(edt_batch_datetime_id,9,2)+':'+right(edt_batch_datetime_id,2) between @batchdatestart and @batchdateend
	AND (@ack824yn = '?' --?,?
	or (@ack824yn = 'Y' AND edt_ack_flag = @ack824flag) --Y,value
	or (@ack824yn = 'Y' and @ack824flag = '?' AND edt_ack_flag IS NOT NULL) --Y,?
	or (@ack824yn = 'N' and edt_ack_flag IS NULL)) --N,?
	AND (@ack997yn = '?' --?,?
	or (@ack997yn = 'Y' AND edt_997_flag = @ack997flag) --Y,value
	or (@ack997yn = 'Y' and @ack997flag = '?' AND edt_997_flag IS NOT NULL) --Y,?
	or (@ack997yn = 'N' and edt_997_flag IS NULL)) --N
ELSE  
IF @typeofsearch ='U'
SELECT edt_doctype,
	edt_extract_dttm,
	trp_id,
	edt_docID,
	edt_ack_flag,
	edt_batch_control,
	edt_batch_doc_seq,
	edt_997_flag,
	edt.ord_number,
	i.ivh_billdate,	
	convert(int,substring(edt_image,93,7)) charge, --charge
	i.ivh_invoicenumber,
	(select sum(convert(int,substring(edt_image,93,7))) from edi_document_tracking a --sum of charges
		where edt_batch_image_seq =1 and edt.edt_batch_control = a.edt_batch_control) sumOfCharges,
	(select count(*) from edi_document_tracking a 
		where edt_batch_image_seq=1 and edt.edt_batch_control = a.edt_batch_control) doccount
FROM edi_document_tracking edt
LEFT JOIN invoiceheader i ON edt.ivh_invoicenumber = i.ivh_invoicenumber
where edt_batch_image_seq = 1
	AND edt_doctype = @doctype
	AND @trpid in (trp_id,'UNKNOWN')
	AND @controlnumber in (convert(varchar(10),edt_batch_control), '##')
	AND @ordnumber in (edt.ord_number, '##')
	AND @invnumber in (edt.ivh_invoicenumber,'##')
	AND i.ivh_billdate between @batchdatestart and @batchdateend
	AND (@ack824yn = '?' --?,?
	or (@ack824yn = 'Y' AND edt_ack_flag = @ack824flag) --Y,value
	or (@ack824yn = 'Y' and @ack824flag = '?' AND edt_ack_flag IS NOT NULL) --Y,?
	or (@ack824yn = 'N' and edt_ack_flag IS NULL)) --N,?
	AND (@ack997yn = '?' --?,?
	or (@ack997yn = 'Y' AND edt_997_flag = @ack997flag) --Y,value
	or (@ack997yn = 'Y' and @ack997flag = '?' AND edt_997_flag IS NOT NULL) --Y,?
	or (@ack997yn = 'N' and edt_997_flag IS NULL)) --N
else 
if @typeofsearch = 'E'
begin
select 
err_GSControlNo,
err_STcontrolNo,
err_layer,
err_errorCode,
err_segmentErrorCode,
err_segmentID,
err_segmentPosition,
err_elementPosition,
err_elementReference,
err_elementErrorCode,
err_baddata,
err_pronumber,
er.edt_docid,
err_datetime
into #edi_error
from
edi_error er
left join 
edi_document_tracking as edt on ord_number = err_pronumber or ivh_invoicenumber = err_pronumber and edt_batch_image_seq = 1 AND edt_doctype = @doctype
WHERE @trpid in (trp_id,'UNKNOWN')
	AND @controlnumber in (convert(varchar(10),edt_batch_control), '##')
	AND @ordnumber in (err_pronumber, '##')
	AND @invnumber in (err_pronumber,'##') --???
	AND err_datetime between @batchdatestart and @batchdateend
	AND (@ack824yn = '?' --?,?
	or (@ack824yn = 'Y' AND edt_ack_flag = @ack824flag) --Y,value
	or (@ack824yn = 'Y' and @ack824flag = '?' AND edt_ack_flag IS NOT NULL) --Y,?
	or (@ack824yn = 'N' and edt_ack_flag IS NULL)) --N,?
	AND (@ack997yn = '?' --?,?
	or (@ack997yn = 'Y' AND edt_997_flag = @ack997flag) --Y,value
	or (@ack997yn = 'Y' and @ack997flag = '?' AND edt_997_flag IS NOT NULL) --Y,?
	or (@ack997yn = 'N' and edt_997_flag IS NULL)) --N

update #edi_error set err_errorcode = 
	(select max(name) from labelfile where abbr = err_errorcode and labeldefinition = 'edi997grouperr')
	where err_layer = 'G'
update #edi_error set err_errorcode = 
	(select max(name) from labelfile where abbr = err_errorcode and labeldefinition = 'edi997transerr')
	where err_layer = 'T'
update #edi_error set err_segmenterrorcode = 
	(select max(name) from labelfile where abbr = err_segmenterrorcode and labeldefinition = 'edi997segerr')
	where err_layer = 'S'
update #edi_error set err_elementerrorcode = 
	(select max(name) from labelfile where abbr = err_elementerrorcode and labeldefinition = 'edi997elterr')
	where err_layer = 'E'	
select * from #edi_error
end

GO
GRANT EXECUTE ON  [dbo].[edi_log_report] TO [public]
GO
