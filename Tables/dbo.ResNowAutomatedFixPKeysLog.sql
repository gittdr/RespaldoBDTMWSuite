CREATE TABLE [dbo].[ResNowAutomatedFixPKeysLog]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dt] [datetime] NULL CONSTRAINT [DF__ResNowAutoma__dt__23005E3C] DEFAULT (getdate()),
[SuccessFlagYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLScript] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowAutomatedFixPKeysLog] ADD CONSTRAINT [PK_ResNowAutomatedFixPKeysLog_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowAutomatedFixPKeysLog] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowAutomatedFixPKeysLog] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowAutomatedFixPKeysLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowAutomatedFixPKeysLog] TO [public]
GO
