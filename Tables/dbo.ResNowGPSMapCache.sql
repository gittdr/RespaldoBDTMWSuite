CREATE TABLE [dbo].[ResNowGPSMapCache]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[MetricCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PlainDate] [datetime] NULL,
[ItemID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Symbol] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gps_latitude] [float] NULL,
[gps_longitude] [float] NULL,
[gps_date] [datetime] NULL,
[DisplayText] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Upd_Daily] [datetime] NULL,
[FlashFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowGPSMapCache] ADD CONSTRAINT [PK__ResNowGPSMapCach__79FE48A9] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxResNowGPSMapCache] ON [dbo].[ResNowGPSMapCache] ([MetricCode], [PlainDate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowGPSMapCache] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowGPSMapCache] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowGPSMapCache] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowGPSMapCache] TO [public]
GO
