CREATE TABLE [dbo].[tti_gls_sensor]
(
[GlsSN] [int] NOT NULL,
[SensorID] [int] NOT NULL,
[SensorType] [int] NOT NULL,
[SensorName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SensorEvent] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SensorData] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DTData] [datetime] NULL,
[DTCreated] [datetime] NULL
) ON [PRIMARY]
GO
