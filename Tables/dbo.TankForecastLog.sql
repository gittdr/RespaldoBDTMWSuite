CREATE TABLE [dbo].[TankForecastLog]
(
[LogId] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ForecastDate] [datetime] NOT NULL CONSTRAINT [DF_TankForecastLog_ForecastDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL CONSTRAINT [DF_TankForecastLog_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLog] ADD CONSTRAINT [PK_TankForecastLog] PRIMARY KEY CLUSTERED ([LogId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_cmp_id_ModifiedDate] ON [dbo].[TankForecastLog] ([cmp_id], [ModifiedDate]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastLog] ADD CONSTRAINT [FK_TankForecastLog_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[TankForecastLog] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastLog] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastLog] TO [public]
GO
