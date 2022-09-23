SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



create proc [dbo].[edi_errorlogretrieve] 
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
	@invnumber varchar(12)
as

IF LEN(RTRIM(isnull(@ordnumber,''))) = 0 SELECT @ordnumber = '##'
IF LEN(RTRIM(isnull(@controlnumber,''))) = 0 SELECT @controlnumber= '##'
IF LEN(RTRIM(isnull(@invnumber,''))) = 0 SELECT @invnumber= '##'


declare @batchstart varchar(20), @batchend varchar(20)

select @batchdatestart = isnull(@batchdatestart,'200001010000'),
		@batchdateend = isnull(@batchdateend,'204912312359')

select 	@batchstart = left(@batchdatestart,4)+'-'+
					substring(@batchdatestart,5,2)+'-'+
					substring(@batchdatestart,7,2)+' '+
					substring(@batchdatestart,9,2)+':'+
					substring(@batchdatestart,11,2),
		@batchend = left(@batchdateend,4)+'-'+
					substring(@batchdateend,5,2)+'-'+
					substring(@batchdateend,7,2)+' '+
					substring(@batchdateend,9,2)+':'+
					substring(@batchdateend,11,2)
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
	AND err_datetime between @batchstart and @batchend
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
GO
GRANT EXECUTE ON  [dbo].[edi_errorlogretrieve] TO [public]
GO
