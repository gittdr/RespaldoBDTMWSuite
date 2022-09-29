CREATE TABLE [dbo].[manifestdetail]
(
[mfh_number] [int] NULL,
[timestamp] [timestamp] NULL,
[loaded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manifestd__loade__69704327] DEFAULT ('N'),
[ord_hdrnumber] [int] NULL,
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__manifestd__unit___6A646760] DEFAULT (''),
[mfd_number] [int] NOT NULL IDENTITY(1, 1),
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__manifestd__INS_T__5E0AA82F] DEFAULT (getdate())
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create trigger [dbo].[iud_manifestdetail]
on [dbo].[manifestdetail]
for insert,update,delete
as
 SET NOCOUNT ON
 DECLARE @tmwuser varchar (255)
  exec gettmwuser @tmwuser output
  
  insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, update_note)
  select ord_hdrnumber, upper(@tmwuser), GETDATE(), 'Manifest', 'Order '+Convert(varchar, ord_hdrnumber, 20)+' removed from mainfest '+ Convert(varchar, mfh_number)
     from deleted 
     where not exists(select 1 from inserted where inserted.mfh_number = deleted.mfh_number) 
     
     insert into expedite_audit (ord_hdrnumber, updated_by, updated_dt, activity, update_note)
  select ord_hdrnumber, upper(@tmwuser), GETDATE(), 'Manifest', 'Order '+Convert(varchar, ord_hdrnumber, 20)+' added to mainfest '+ Convert(varchar, mfh_number)
     from inserted
     where not exists(select 1 from deleted where inserted.mfh_number = deleted.mfh_number)
GO
CREATE NONCLUSTERED INDEX [manifestdetail_INS_TIMESTAMP] ON [dbo].[manifestdetail] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mnfstnum] ON [dbo].[manifestdetail] ([mfh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [mandtl_ordhdr] ON [dbo].[manifestdetail] ([ord_hdrnumber], [mfh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manifestdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[manifestdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manifestdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[manifestdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[manifestdetail] TO [public]
GO
