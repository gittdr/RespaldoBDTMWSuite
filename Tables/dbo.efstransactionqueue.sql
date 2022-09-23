CREATE TABLE [dbo].[efstransactionqueue]
(
[etq_id] [int] NOT NULL IDENTITY(1, 1),
[etq_mov_number] [int] NOT NULL,
[etq_issuedon] [datetime] NOT NULL,
[etq_userid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etq_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[etq_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efstransactionqueue] ADD CONSTRAINT [pk_efstransactionqueue_id] PRIMARY KEY CLUSTERED ([etq_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_etq_mov_time] ON [dbo].[efstransactionqueue] ([etq_mov_number], [etq_issuedon]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[efstransactionqueue] TO [public]
GO
GRANT INSERT ON  [dbo].[efstransactionqueue] TO [public]
GO
GRANT SELECT ON  [dbo].[efstransactionqueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[efstransactionqueue] TO [public]
GO
