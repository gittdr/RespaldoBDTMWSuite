SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create PROCEDURE  [dbo].[sp_DXArchive_SingleBatch]
@processStatus varchar(6) = 'QUEUED',
@Update bit = 1
As

/*******************************************************************************************************************  
  Object Description:
  sp_DXArchive_SingleBatch

  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------   ----------------------------------------
  07/19/2016   David Wilks                   Replace NOLOCK hint with HoldLock so that other instances will be locked out of grabbing 
											 the same SID.
********************************************************************************************************************/

begin
  set nocount on;

  -- table of dx_Archive_header.dx_Archive_header_ids of modified records
  
  declare @SQLCmd varchar(max);
  declare @HeaderIds table(headerId bigint);
  begin transaction 
  
 insert into @HeaderIds
 Exec('select dx_Archive_header_id 
		from dx_archive_header dah with (holdlock)
	  where dah.dx_Processed='''+@processStatus+'''
		and dah.dx_ordernumber = (select top 1 chk.dx_ordernumber
	  from  dx_archive_header chk with (index=dk_dx_archive_header_dx_processed_dx_ordernumber) 
	  left join (select dx_ordernumber from dx_Archive_header with (index=dk_dx_archive_header_dx_processed_dx_ordernumber) where dx_processed = ''RESERV'') as sub 
						on chk.dx_ordernumber = sub.dx_ordernumber  
						where sub.dx_ordernumber is null
						and isnull(chk.dx_ordernumber,'''') > ''''  
						and chk.dx_Processed='''+@processStatus+'''
						order by chk.dx_Archive_header_id)
')

  --insert into @HeaderIds
  --EXEC(@SQLCmd)

	--select dx_Archive_header_id 
	--			from  dx_archive_header chk with (index=dk_dx_archive_header_dx_processed_dx_ordernumber) --index hints added by Mindy 20140914.
 --                                                                             left join (select dx_ordernumber from dx_Archive_header with (index=dk_dx_archive_header_dx_processed_dx_ordernumber) where dx_processed = 'RESERV') as sub 
	--																					on chk.dx_ordernumber = sub.dx_ordernumber  
	--																					where chk.dx_processed = @processStatus
	--																					and isnull(chk.dx_ordernumber,'') > ''  
	--																					and sub.dx_ordernumber is null  
	
	
  if @Update = 1
		update h
                 set dx_processed = 'RESERV',
                                dx_updatedby = 'RulesEngine',
                                dx_updatedate = getdate(),
                                dx_batchref = isnull(dx_batchref, 0) + 1
		from dbo.dx_archive_header h inner join @HeaderIds hi on h.dx_archive_header_id = hi.headerId


commit transaction

  select 
    dxad.dx_ident,
    dxah.dx_importid,
    dxah.dx_sourcename,
    dxah.dx_sourcedate,
    convert(int,dxad.dx_seq) dx_seq,
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
  from dbo.dx_Archive_header dxah
    left outer join dbo.dx_Archive_detail dxad 
      on dxah.dx_Archive_header_id = dxad.dx_Archive_header_id
	inner join @HeaderIds h on dxah.dx_archive_header_id = h.headerId order by dx_sourcedate, dx_seq  
end

GO
GRANT EXECUTE ON  [dbo].[sp_DXArchive_SingleBatch] TO [public]
GO
