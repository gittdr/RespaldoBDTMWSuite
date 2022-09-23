CREATE TABLE [dbo].[cdtransqueue]
(
[ctq_id] [int] NOT NULL IDENTITY(1, 1),
[ctq_mov_number] [int] NULL,
[ctq_userid] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctq_issuedon] [datetime] NULL,
[ctq_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctq_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdtransqueue] ADD CONSTRAINT [pk_cdtransqueue] PRIMARY KEY CLUSTERED ([ctq_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdtransqueue] TO [public]
GO
GRANT INSERT ON  [dbo].[cdtransqueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdtransqueue] TO [public]
GO
GRANT SELECT ON  [dbo].[cdtransqueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdtransqueue] TO [public]
GO
