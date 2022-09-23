CREATE TABLE [dbo].[shiftschedules_log]
(
[ssl_id] [int] NOT NULL IDENTITY(1, 1),
[ss_id] [int] NOT NULL,
[ssl_activity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssl_activitydate] [datetime] NULL,
[ssl_auditreason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssl_createdate] [datetime] NULL,
[ssl_createdby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssl_lastupdatedate] [datetime] NULL,
[ssl_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssl_odometer] [int] NULL,
[ssl_skiptrigger] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[iut_shiftschedules_log] on [dbo].[shiftschedules_log] for update, insert
as 
 declare @inserted as int,
  @updated as int
 
 DECLARE @tmwuser varchar (255)
 exec gettmwuser @tmwuser output
 
 if not exists (select 1 from inserted i join deleted d on i.ssl_id = d.ssl_id)
  update shiftschedules_log
  set ssl_createdate = getdate(),
   ssl_createdby = @tmwuser
  from inserted
  where shiftschedules_log.ssl_id = inserted.ssl_id
  
 update shiftschedules_log
 set ssl_lastupdatedate = getdate(),
  ssl_lastupdateby = @tmwuser
 from inserted
 where shiftschedules_log.ssl_id = inserted.ssl_id
GO
GRANT DELETE ON  [dbo].[shiftschedules_log] TO [public]
GO
GRANT INSERT ON  [dbo].[shiftschedules_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[shiftschedules_log] TO [public]
GO
GRANT SELECT ON  [dbo].[shiftschedules_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[shiftschedules_log] TO [public]
GO
