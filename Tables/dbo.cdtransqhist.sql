CREATE TABLE [dbo].[cdtransqhist]
(
[ctqh_id] [int] NOT NULL IDENTITY(1, 1),
[ctq_id] [int] NULL,
[ctqh_mov_number] [int] NULL,
[ctqh_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctqh_issuedon] [datetime] NULL,
[ctqh_status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctqh_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdtransqhist] ADD CONSTRAINT [PK_cdtransqhist] PRIMARY KEY CLUSTERED ([ctqh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cdtransqhist] TO [public]
GO
GRANT INSERT ON  [dbo].[cdtransqhist] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdtransqhist] TO [public]
GO
GRANT SELECT ON  [dbo].[cdtransqhist] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdtransqhist] TO [public]
GO
