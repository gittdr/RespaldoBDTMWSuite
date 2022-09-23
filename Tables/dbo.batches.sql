CREATE TABLE [dbo].[batches]
(
[bachnumb] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bachdesc] [varchar] (61) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bachdate] [datetime] NULL,
[numoftrx] [int] NULL,
[bachtotal] [money] NULL,
[createdate] [datetime] NULL CONSTRAINT [DF__batches__created__348C100B] DEFAULT (getdate()),
[createuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__batches__createu__35803444] DEFAULT (user_name()),
[modifieddate] [datetime] NULL CONSTRAINT [DF__batches__modifie__3674587D] DEFAULT (getdate()),
[modifieduser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__batches__modifie__37687CB6] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[batches] ADD CONSTRAINT [pk_batches] PRIMARY KEY CLUSTERED ([bachnumb]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[batches] TO [public]
GO
GRANT INSERT ON  [dbo].[batches] TO [public]
GO
GRANT REFERENCES ON  [dbo].[batches] TO [public]
GO
GRANT SELECT ON  [dbo].[batches] TO [public]
GO
GRANT UPDATE ON  [dbo].[batches] TO [public]
GO
