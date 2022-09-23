SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[getDXArchive204ByProcessed]
@processStatus varchar(6),
@ord_hdrnumber int 
As
begin
  set nocount on
  declare @QueueSize int
  declare @LastQueueFilterStart char(1)
  declare @QueueFilterStart varchar(2)
  declare @QueueFilterEnd varchar(2)
  declare @QueueFilterStartSteps char(16)
  declare @QueueFilterEndSteps char(16)
  declare @QueueFilterIndex int
  set @QueueFilterStartSteps = '/0123456789CHNUZ'
  set @QueueFilterEndSteps = '0123456789CHNUZÐ'
  SELECT @QueueSize = count(*) FROM DX_ARCHIVE_header Where dx_processed = @processStatus and (@ord_hdrnumber = 0 or dx_orderhdrnumber = @ord_hdrnumber)
  if @QueueSize > 1000
	begin
		select @LastQueueFilterStart = IsNull(last_filter, ' ') from dx_archive_recordlock
		set @QueueFilterIndex = charindex(@LastQueueFilterStart, @QueueFilterStartSteps) 
		if @QueueFilterIndex = 16
			set @QueueFilterIndex = 0

        set @QueueFilterIndex = @QueueFilterIndex + 1
		set @QueueFilterStart  = substring(@QueueFilterStartSteps, @QueueFilterIndex, 1)
		set @QueueFilterEnd = substring(@QueueFilterEndSteps, @QueueFilterIndex, 1)
		update dx_archive_recordlock set last_filter = @QueueFilterStart
		set @QueueFilterStart = @QueueFilterStart + '%'
		set @QueueFilterEnd = @QueueFilterEnd + '%'
	end
  else
    begin
		set @QueueFilterStart = '/'
		set @QueueFilterEnd = 'Ð'
	end
      select 
    dxad.dx_ident,
    dxah.dx_importid,
    dxah.dx_sourcename,
    dxah.dx_sourcedate,
    convert(int, dxad.dx_seq) dx_seq,
    dxah.dx_updated,
    dxah.dx_accepted,
    dxah.dx_ordernumber,
    dxah.dx_orderhdrnumber,
    dxah.dx_movenumber,
    dxad.dx_stopnumber,
    dxad.dx_freightnumber,
    dxah.dx_docnumber,
    dxah.dx_manifestnumber,
    dxad.dx_manifeststop,
    dxah.dx_batchref,
    dxad.dx_field001,
    dxad.dx_field002,
    dxad.dx_field003,
    dxad.dx_field004,
    dxad.dx_field005,
    dxad.dx_field006,
    dxad.dx_field007,
    dxad.dx_field008,
    dxad.dx_field009,
    dxad.dx_field010,
    dxad.dx_field011,
    dxad.dx_field012,
    dxad.dx_field013,
    dxad.dx_field014,
    dxad.dx_field015,
    dxad.dx_field016,
    dxad.dx_field017,
    dxad.dx_field018,
    dxad.dx_field019,
    dxad.dx_field020,
    dxad.dx_field021,
    dxad.dx_field022,
    dxad.dx_field023,
    dxad.dx_field024,
    dxad.dx_field025,
    dxad.dx_field026,
    dxad.dx_field027,
    dxad.dx_field028,
    dxad.dx_field029,
    dxad.dx_field030,
    dxad.dx_field031,
    dxad.dx_field032,
    dxad.dx_field033,
    dxad.dx_field034,
    dxad.dx_field035,
    dxah.dx_doctype,
    dxah.dx_createdby,
    dxah.dx_createdate,
    dxah.dx_updatedby,
    dxah.dx_updatedate,
    dxah.dx_processed,
    dxah.dx_trpid,
    dxah.dx_sourcedate_reference,
    dxah.dx_billto,
	dxah.dx_Archive_header_id
  from dbo.dx_Archive_header dxah (nolock)
    left outer join dbo.dx_Archive_detail dxad (nolock)
      on dxah.dx_Archive_header_id = dxad.dx_Archive_header_id
	where dxah.dx_Processed=@processStatus
		and dxah.dx_importid= 'dx_204'
		and dxah.dx_ordernumber > @QueueFilterStart
		and dxah.dx_ordernumber < @QueueFilterEnd
		and (@processStatus = 'PEND'
		or exists(select 1 from dx_archive_header y where dxah.dx_ordernumber = y.dx_ordernumber 
											and  dxah.dx_trpid = y.dx_trpid
											and y.dx_processed = 'DONE' 
											and y.dx_orderhdrnumber > 0))
		and (@ord_hdrnumber = 0 or dxah.dx_orderhdrnumber = @ord_hdrnumber)


end

GO
GRANT EXECUTE ON  [dbo].[getDXArchive204ByProcessed] TO [public]
GO
