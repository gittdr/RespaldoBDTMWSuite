SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- view to replace table
CREATE VIEW [dbo].[dx_Archive] WITH SCHEMABINDING AS
  select 
    dxad.dx_ident,
    dxah.dx_importid,
    dxah.dx_sourcename,
    dxah.dx_sourcedate,
    dxad.dx_seq,
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
  UNION
  select 
    dx_ident,
    dx_importid,
    dx_sourcename,
    dx_sourcedate,
    dx_seq,
    dx_updated,
    dx_accepted,
    dx_ordernumber,
    dx_orderhdrnumber,
    dx_movenumber,
    dx_stopnumber,
    dx_freightnumber,
    dx_docnumber,
    dx_manifestnumber,
    dx_manifeststop,
    dx_batchref,
    dx_field001,
    dx_field002,
    dx_field003,
    dx_field004,
    dx_field005,
    dx_field006,
    dx_field007,
    dx_field008,
    dx_field009,
    dx_field010,
    dx_field011,
    dx_field012,
    dx_field013,
    dx_field014,
    dx_field015,
    dx_field016,
    dx_field017,
    dx_field018,
    dx_field019,
    dx_field020,
    dx_field021,
    dx_field022,
    dx_field023,
    dx_field024,
    dx_field025,
    dx_field026,
    dx_field027,
    dx_field028,
    dx_field029,
    dx_field030,
    dx_field031,
    dx_field032,
    dx_field033,
    dx_field034,
    dx_field035,
    dx_doctype,
    dx_createdby,
    dx_createdate,
    dx_updatedby,
    dx_updatedate,
    dx_processed,
    dx_trpid,
    dx_sourcedate_reference,
    dx_billto,
	0
	from dbo.dx_Archive_72183
	where IsNull(dx_processed,'DONE') <> 'EXPORT'

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[dt_dx_Archive] ON [dbo].[dx_Archive]
INSTEAD OF DELETE
AS
BEGIN
  set nocount on
    -- detail table    
  delete dbo.dx_Archive_detail 
  from DELETED d
	where dx_Archive_detail.dx_ident = d.dx_ident
		and d.dx_archive_header_id > 0

  -- header Table
  delete dbo.dx_Archive_header 
  from DELETED d left outer join dx_Archive_detail dxad on dxad.dx_archive_header_id = d.dx_archive_header_id
   where dxad.dx_archive_header_id is null
    and dx_Archive_header.dx_Archive_header_id = d.dx_Archive_header_id
	and d.dx_archive_header_id > 0

-- legacy
delete dx_Archive_72183
  from DELETED d
	where d.dx_Archive_header_id = 0
	and dx_Archive_72183.dx_ident = d.dx_ident


END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_dx_Archive] ON [dbo].[dx_Archive]
INSTEAD OF INSERT
AS
BEGIN
  set nocount on
  -- header table
  insert into dbo.dx_Archive_header (
    dx_importid,
    dx_sourcename,
    dx_sourcedate,
    dx_updated,
    dx_accepted,
    dx_ordernumber,
    dx_orderhdrnumber,
    dx_movenumber,
    dx_manifestnumber,
    dx_batchref,
    dx_doctype,
    dx_docnumber,
    dx_createdby,
    dx_createdate,
    dx_updatedby,
    dx_updatedate,
    dx_processed,
    dx_trpid,
    dx_sourcedate_reference,
    dx_billto
  )
  select 	
    i.dx_importid,
    i.dx_sourcename,
    i.dx_sourcedate,
    i.dx_updated,
    i.dx_accepted,
    i.dx_ordernumber,
    i.dx_orderhdrnumber,
    i.dx_movenumber,
    i.dx_manifestnumber,
    i.dx_batchref,
    i.dx_doctype,
    i.dx_docnumber,
    i.dx_createdby,
    i.dx_createdate,
    i.dx_updatedby,
    i.dx_updatedate,
    i.dx_processed,
    i.dx_trpid,
    i.dx_sourcedate_reference,
    i.dx_billto
  from (select max(i.dx_seq) as dx_seq, i.dx_importid, i.dx_sourcename, i.dx_sourcedate 
        from INSERTED i 
        group by i.dx_importid, i.dx_sourcename, i.dx_sourcedate) mi
    inner join inserted i 
      on i.dx_seq = mi.dx_seq 
        and i.dx_importid = mi.dx_importid 
        and i.dx_sourcename = mi.dx_sourcename 
        and i.dx_sourcedate = mi.dx_sourcedate
   where not exists(select * from dbo.dx_Archive_header dxah where dxah.dx_importid = i.dx_importid and dxah.dx_sourcename = i.dx_sourcename and dxah.dx_sourcedate = i.dx_sourcedate);

  -- detail values
  insert into dbo.dx_Archive_detail (
	dx_archive_header_id,
    dx_seq,
    dx_stopnumber,
    dx_freightnumber,
    dx_manifeststop,
	dx_field001,
	dx_field002,
	dx_field003,
	dx_field004,
	dx_field005,
	dx_field006,
	dx_field007,
	dx_field008,
	dx_field009,
	dx_field010,
	dx_field011,
	dx_field012,
	dx_field013,
	dx_field014,
	dx_field015,
	dx_field016,
	dx_field017,
	dx_field018,
	dx_field019,
	dx_field020,
	dx_field021,
	dx_field022,
	dx_field023,
	dx_field024,
	dx_field025,
	dx_field026,
	dx_field027,
	dx_field028,
	dx_field029,
	dx_field030,
	dx_field031,
	dx_field032,
	dx_field033,
	dx_field034,
	dx_field035
  )
  select 	
    (select dx_archive_header_id from dx_archive_header dxh where dxh.dx_importid = i.dx_importid and dxh.dx_sourcename = i.dx_sourcename and dxh.dx_sourcedate = i.dx_sourcedate),
    i.dx_seq,
    i.dx_stopnumber,
    i.dx_freightnumber,
    i.dx_manifeststop,
    i.dx_field001,
    i.dx_field002,
    i.dx_field003,
    i.dx_field004,
    i.dx_field005,
    i.dx_field006,
    i.dx_field007,
    i.dx_field008,
    i.dx_field009,
    i.dx_field010,
    i.dx_field011,
    i.dx_field012,
    i.dx_field013,
    i.dx_field014,
    i.dx_field015,
    i.dx_field016,
    i.dx_field017,
    i.dx_field018,
    i.dx_field019,
    i.dx_field020,
    i.dx_field021,
    i.dx_field022,
    i.dx_field023,
    i.dx_field024,
    i.dx_field025,
    i.dx_field026,
    i.dx_field027,
    i.dx_field028,
    i.dx_field029,
    i.dx_field030,
    i.dx_field031,
    i.dx_field032,
    i.dx_field033,
    i.dx_field034,
    i.dx_field035
  from INSERTED i
  where not exists(select * from dbo.dx_Archive_detail dxad where dxad.dx_archive_header_id = (select dx_archive_header_id from dx_archive_header dxh where dxh.dx_importid = i.dx_importid and dxh.dx_sourcename = i.dx_sourcename and dxh.dx_sourcedate = i.dx_sourcedate) and dxad.dx_seq = i.dx_seq)
    
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_dx_Archive] ON [dbo].[dx_Archive]
INSTEAD OF UPDATE
AS
BEGIN
  set nocount on
  -- header table
  update dbo.dx_Archive_header
  set 
    dx_importid = i.dx_importid,
    dx_sourcename = i.dx_sourcename,
    dx_sourcedate = i.dx_sourcedate,
    dx_updated = i.dx_updated,
    dx_accepted = i.dx_accepted,
    dx_ordernumber = i.dx_ordernumber,
    dx_orderhdrnumber = i.dx_orderhdrnumber,
    dx_movenumber = i.dx_movenumber,
    dx_manifestnumber = i.dx_manifestnumber,
    dx_batchref = i.dx_batchref,
    dx_doctype = i.dx_doctype,
    dx_docnumber = i.dx_docnumber,
    dx_createdby = i.dx_createdby,
    dx_createdate = i.dx_createdate,
    dx_updatedby = i.dx_updatedby,
    dx_updatedate = i.dx_updatedate,
    dx_processed = i.dx_processed,
    dx_trpid = i.dx_trpid,
    dx_sourcedate_reference = i.dx_sourcedate_reference,
    dx_billto = i.dx_billto
  from INSERTED i inner join dbo.dx_Archive_header dxah 
    on i.dx_Archive_header_id = dxah.dx_Archive_header_id
	where i.dx_Archive_header_id > 0


  -- detail table
  update dbo.dx_Archive_detail
  set
    dx_stopnumber = i.dx_stopnumber,
    dx_freightnumber = i.dx_freightnumber,
    dx_manifeststop = i.dx_manifeststop,
	dx_field001 = 	i.dx_field001,
	dx_field002 = 	i.dx_field002,
	dx_field003 = 	i.dx_field003,
	dx_field004 = 	i.dx_field004,
	dx_field005 = 	i.dx_field005,
	dx_field006 = 	i.dx_field006,
	dx_field007 = 	i.dx_field007,
	dx_field008 = 	i.dx_field008,
	dx_field009 = 	i.dx_field009,
	dx_field010 = 	i.dx_field010,
	dx_field011 = 	i.dx_field011,
	dx_field012 = 	i.dx_field012,
	dx_field013 = 	i.dx_field013,
	dx_field014 = 	i.dx_field014,
	dx_field015 = 	i.dx_field015,
	dx_field016 = 	i.dx_field016,
	dx_field017 = 	i.dx_field017,
	dx_field018 = 	i.dx_field018,
	dx_field019 = 	i.dx_field019,
	dx_field020 = 	i.dx_field020,
	dx_field021 = 	i.dx_field021,
	dx_field022 = 	i.dx_field022,
	dx_field023 = 	i.dx_field023,
	dx_field024 = 	i.dx_field024,
	dx_field025 = 	i.dx_field025,
	dx_field026 = 	i.dx_field026,
	dx_field027 = 	i.dx_field027,
	dx_field028 = 	i.dx_field028,
	dx_field029 = 	i.dx_field029,
	dx_field030 = 	i.dx_field030,
	dx_field031 = 	i.dx_field031,
	dx_field032 = 	i.dx_field032,
	dx_field033 = 	i.dx_field033,
	dx_field034 = 	i.dx_field034,
	dx_field035 = 	i.dx_field035
  from dbo.dx_Archive_detail dxad inner join INSERTED i 
    on dxad.dx_ident = i.dx_ident
	where i.dx_Archive_header_id > 0

-- legacy
  update dx_Archive_72183
  set 
    dx_importid = i.dx_importid,
    dx_sourcename = i.dx_sourcename,
    dx_sourcedate = i.dx_sourcedate,
    dx_updated = i.dx_updated,
    dx_accepted = i.dx_accepted,
    dx_ordernumber = i.dx_ordernumber,
    dx_orderhdrnumber = i.dx_orderhdrnumber,
    dx_movenumber = i.dx_movenumber,
    dx_manifestnumber = i.dx_manifestnumber,
    dx_batchref = i.dx_batchref,
    dx_doctype = i.dx_doctype,
    dx_docnumber = i.dx_docnumber,
    dx_createdby = i.dx_createdby,
    dx_createdate = i.dx_createdate,
    dx_updatedby = i.dx_updatedby,
    dx_updatedate = i.dx_updatedate,
    dx_processed = i.dx_processed,
    dx_trpid = i.dx_trpid,
    dx_sourcedate_reference = i.dx_sourcedate_reference,
    dx_billto = i.dx_billto,
    dx_stopnumber = i.dx_stopnumber,
    dx_freightnumber = i.dx_freightnumber,
    dx_manifeststop = i.dx_manifeststop,
	dx_field001 = 	i.dx_field001,
	dx_field002 = 	i.dx_field002,
	dx_field003 = 	i.dx_field003,
	dx_field004 = 	i.dx_field004,
	dx_field005 = 	i.dx_field005,
	dx_field006 = 	i.dx_field006,
	dx_field007 = 	i.dx_field007,
	dx_field008 = 	i.dx_field008,
	dx_field009 = 	i.dx_field009,
	dx_field010 = 	i.dx_field010,
	dx_field011 = 	i.dx_field011,
	dx_field012 = 	i.dx_field012,
	dx_field013 = 	i.dx_field013,
	dx_field014 = 	i.dx_field014,
	dx_field015 = 	i.dx_field015,
	dx_field016 = 	i.dx_field016,
	dx_field017 = 	i.dx_field017,
	dx_field018 = 	i.dx_field018,
	dx_field019 = 	i.dx_field019,
	dx_field020 = 	i.dx_field020,
	dx_field021 = 	i.dx_field021,
	dx_field022 = 	i.dx_field022,
	dx_field023 = 	i.dx_field023,
	dx_field024 = 	i.dx_field024,
	dx_field025 = 	i.dx_field025,
	dx_field026 = 	i.dx_field026,
	dx_field027 = 	i.dx_field027,
	dx_field028 = 	i.dx_field028,
	dx_field029 = 	i.dx_field029,
	dx_field030 = 	i.dx_field030,
	dx_field031 = 	i.dx_field031,
	dx_field032 = 	i.dx_field032,
	dx_field033 = 	i.dx_field033,
	dx_field034 = 	i.dx_field034,
	dx_field035 = 	i.dx_field035
  from INSERTED i 
	where i.dx_Archive_header_id = 0
	and i.dx_ident = dx_Archive_72183.dx_ident
END
GO
GRANT DELETE ON  [dbo].[dx_Archive] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Archive] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Archive] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Archive] TO [public]
GO
