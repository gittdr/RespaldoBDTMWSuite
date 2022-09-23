CREATE TABLE [dbo].[ResNowTrackUsage]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[UserID] [int] NULL,
[UsageDate] [datetime] NULL,
[Category] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Layer] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Metric] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DetailYN] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequestType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowTrackUsage] ADD CONSTRAINT [AutoPK_ResNowTrackUsage_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowTrackUsage] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowTrackUsage] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowTrackUsage] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowTrackUsage] TO [public]
GO
