CREATE TABLE [dbo].[MatchAdviceLogStopInfo]
(
[malsi_id] [int] NOT NULL IDENTITY(1, 1),
[mal_id] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[ts_arrival] [datetime] NULL,
[ts_departure] [datetime] NULL,
[ts_earliest] [datetime] NULL,
[ts_latest] [datetime] NULL,
[ma_arrival] [datetime] NULL,
[ma_departure] [datetime] NULL,
[ma_earliest] [datetime] NULL,
[ma_latest] [datetime] NULL,
[malsi_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[malsi_updatedate] [datetime] NOT NULL,
[ts_miles] [float] NULL,
[ma_miles] [float] NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MatchAdviceLogStopInfo] ADD CONSTRAINT [PK_MatchAdviceLogStopInfo] PRIMARY KEY CLUSTERED ([malsi_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DK_MatchAdviceLogStopInfo_MalID] ON [dbo].[MatchAdviceLogStopInfo] ([mal_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MatchAdviceLogStopInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[MatchAdviceLogStopInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MatchAdviceLogStopInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[MatchAdviceLogStopInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[MatchAdviceLogStopInfo] TO [public]
GO
