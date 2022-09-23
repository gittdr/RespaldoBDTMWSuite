CREATE TABLE [dbo].[MetricUser]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[NTUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disable] [int] NULL CONSTRAINT [DF__MetricUse__Disab__4866ED15] DEFAULT ((0)),
[GenericUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GenericPassword] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EncryptStyle] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricUser] ADD CONSTRAINT [AutoPK_MetricUser_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricUser] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricUser] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricUser] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricUser] TO [public]
GO
