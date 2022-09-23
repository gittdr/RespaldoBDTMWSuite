CREATE TABLE [dbo].[ResNowLog]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[dateandtime] [datetime] NOT NULL CONSTRAINT [DF__ResNowLog__datea__1B0A36B9] DEFAULT (getdate()),
[source] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[longdesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[metriccode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowLog] ADD CONSTRAINT [PK__ResNowLog__1A161280] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_resnowlog_dateandtime] ON [dbo].[ResNowLog] ([dateandtime]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowLog] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ResNowLog] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowLog] TO [public]
GO
