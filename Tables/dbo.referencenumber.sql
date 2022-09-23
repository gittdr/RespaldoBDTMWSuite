CREATE TABLE [dbo].[referencenumber]
(
[ref_tablekey] [int] NOT NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_typedesc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sequence] [int] NULL,
[ord_hdrnumber] [int] NULL,
[timestamp] [timestamp] NULL,
[ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_pickup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REF_last_updateby] DEFAULT (case when charindex('\',suser_sname())>(0) then left(substring(suser_sname(),charindex('\',suser_sname())+(1),len(suser_sname())),(20)) else left(suser_sname(),(20)) end),
[last_updatedate] [datetime] NULL CONSTRAINT [DF_REF_last_updatedate] DEFAULT (getdate()),
[ref_id] [int] NOT NULL IDENTITY(1, 1),
[AutoRefNumberOrigin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE TRIGGER [dbo].[it_referencenumber]
ON [dbo].[referencenumber]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
/* Trigger it_orderheader
	DPETE PTS 14202 add trigger to ensure the ref numbers added for orderheader on order imports have the ord_hdrnumber
   field set.
   DPETE PTS 64327 implementing performance improvements for DBA Mindy
*/


--76259	If (select Count(*) from inserted Where ref_table = 'orderheader' and ord_hdrnumber is null or ord_hdrnumber = 0) > 0
If (select Count(*) from inserted Where ref_table = 'orderheader' and (ord_hdrnumber is null or ord_hdrnumber = 0)) > 0	--NQIAO 05/31/14 PTS 76259
  Update referencenumber set ord_hdrnumber = inserted.ref_tablekey
  From Inserted
  Where referencenumber.ref_id = inserted.ref_id
  /*
  Where referencenumber.ref_table  = 'orderheader' 
  And referencenumber.ref_tablekey = inserted.ref_tablekey
  */
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create trigger [dbo].[ut_refnum_changelog]
ON [dbo].[referencenumber]
FOR UPDATE --no longer an insert/update trigger. ONLY an update trigger.
AS 
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
--PTS79233 2014.06.11 MTC. Put insert trigger logic into def constraint on table, not trigger.
/*
PTS 64327 DPETE implementing improvements from DBA Mindy

*/
declare @updatecount int, @delcount	int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

--PTS 79233 BEGIN
select @updatecount = count(*) from inserted  
select @delcount = count(*) from deleted  
--if inserted recs & no deleteds, that's a pure insert.
--if both, that's an update	
declare @now datetime
select @now = getdate()
 	
	if (@updatecount > 0 and @delcount > 0)--is an UPDATE ONLY.
		Update ReferenceNumber  
		set last_updateby = @tmwuser,  
		last_updatedate = @now  
		from inserted  inner join ReferenceNumber on inserted.ref_id = ReferenceNumber.ref_id 
	   
 --PTS 79233 END

	
GO
ALTER TABLE [dbo].[referencenumber] ADD CONSTRAINT [pk_refnum] PRIMARY KEY CLUSTERED ([ref_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[referencenumber] ([ord_hdrnumber], [ref_type], [ref_number], [ref_sequence]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ref_num] ON [dbo].[referencenumber] ([ref_number], [ref_type]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ref_table_ref_number] ON [dbo].[referencenumber] ([ref_table], [ref_number], [ref_sequence]) INCLUDE ([ref_type], [ord_hdrnumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [sk_ref_reftable] ON [dbo].[referencenumber] ([ref_table], [ref_tablekey], [ref_type], [ref_number], [ref_sequence]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_referencenumber_timestamp] ON [dbo].[referencenumber] ([timestamp]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[referencenumber] TO [public]
GO
GRANT INSERT ON  [dbo].[referencenumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[referencenumber] TO [public]
GO
GRANT SELECT ON  [dbo].[referencenumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[referencenumber] TO [public]
GO
