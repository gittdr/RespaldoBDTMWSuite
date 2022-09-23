CREATE TABLE [dbo].[TelemetryPermission]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[UserId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Permission] [bit] NOT NULL CONSTRAINT [DF_TelemetryPermission_Permission] DEFAULT ((0)),
[Prompted] [bit] NOT NULL CONSTRAINT [DF_TelemetryPermission_Prompted] DEFAULT ((0)),
[TelemetryItems] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TimeStamp] [datetime] NOT NULL CONSTRAINT [DF_TelemetryPermission_TimeStamp] DEFAULT (getdate()),
[ApplicationVersion] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__Telemetry__Appli__4F7172F4] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TelemetryPermission] ADD CONSTRAINT [TelemetryPermission_pk] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
