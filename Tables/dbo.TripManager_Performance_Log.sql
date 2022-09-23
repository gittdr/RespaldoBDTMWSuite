CREATE TABLE [dbo].[TripManager_Performance_Log]
(
[rec_id] [int] NOT NULL IDENTITY(1, 1),
[log_date] [datetime] NOT NULL,
[log_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_key] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[log_duration1] [int] NULL,
[log_duration2] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripManager_Performance_Log] ADD CONSTRAINT [PK__TripManager_Perf__11FFEF6C] PRIMARY KEY CLUSTERED ([rec_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TripManager_Performance_Log] TO [public]
GO
GRANT INSERT ON  [dbo].[TripManager_Performance_Log] TO [public]
GO
GRANT SELECT ON  [dbo].[TripManager_Performance_Log] TO [public]
GO
GRANT UPDATE ON  [dbo].[TripManager_Performance_Log] TO [public]
GO
