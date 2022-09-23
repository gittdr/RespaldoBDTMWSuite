CREATE TABLE [dbo].[SystemLog]
(
[LogId] [uniqueidentifier] NOT NULL CONSTRAINT [DF__SystemLog__LogId__7457E5EE] DEFAULT (newid()),
[TrackingId] [uniqueidentifier] NOT NULL CONSTRAINT [DF__SystemLog__Track__754C0A27] DEFAULT (newid()),
[UserName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MachineName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDateTime] [datetime] NULL,
[EventLevel] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorSource] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorClass] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMethod] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InnerErrorMessage] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SystemLog] ADD CONSTRAINT [PK__SystemLo__5E548648BF4530FD] PRIMARY KEY CLUSTERED ([LogId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SystemLog] TO [public]
GO
GRANT INSERT ON  [dbo].[SystemLog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SystemLog] TO [public]
GO
GRANT SELECT ON  [dbo].[SystemLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[SystemLog] TO [public]
GO
