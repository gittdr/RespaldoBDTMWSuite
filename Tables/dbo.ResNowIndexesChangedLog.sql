CREATE TABLE [dbo].[ResNowIndexesChangedLog]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dtChange] [datetime] NULL CONSTRAINT [DF__ResNowInd__dtCha__1A6B183B] DEFAULT (getdate()),
[stage] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[index_keys] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowIndexesChangedLog] ADD CONSTRAINT [AutoPK_ResNowIndexesChangedLog_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowIndexesChangedLog] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowIndexesChangedLog] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowIndexesChangedLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowIndexesChangedLog] TO [public]
GO
