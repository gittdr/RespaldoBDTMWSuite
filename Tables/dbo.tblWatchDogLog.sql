CREATE TABLE [dbo].[tblWatchDogLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[LoggedAt] [datetime] NULL,
[EventType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Event] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblWatchDogLog] ADD CONSTRAINT [PK__tblWatchDogLog__31ED9C11] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblWatchDogLog] TO [public]
GO
GRANT INSERT ON  [dbo].[tblWatchDogLog] TO [public]
GO
GRANT SELECT ON  [dbo].[tblWatchDogLog] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblWatchDogLog] TO [public]
GO
