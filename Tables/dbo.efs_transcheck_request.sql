CREATE TABLE [dbo].[efs_transcheck_request]
(
[etr_id] [int] NOT NULL IDENTITY(1, 1),
[etr_asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etr_asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[etr_amount] [money] NOT NULL,
[etr_reasoncode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[etr_transcheckcode] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etr_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etr_request_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etr_request_time] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_efs_transcheck_request] ON [dbo].[efs_transcheck_request] FOR INSERT AS   
SET NOCOUNT ON

DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

update efs_transcheck_request
   set etr_request_user = @tmwuser,
       etr_request_time = getdate()
  from inserted
 where inserted.etr_id = efs_transcheck_request.etr_id
GO
ALTER TABLE [dbo].[efs_transcheck_request] ADD CONSTRAINT [pk_efs_transcheck_request] PRIMARY KEY CLUSTERED ([etr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_etr_asgn_id_date] ON [dbo].[efs_transcheck_request] ([etr_asgn_type], [etr_asgn_id], [etr_request_time]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[efs_transcheck_request] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_transcheck_request] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_transcheck_request] TO [public]
GO
