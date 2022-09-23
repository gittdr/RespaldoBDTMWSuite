CREATE TABLE [dbo].[tblWatchDogResults]
(
[ID] [int] NOT NULL,
[WatchName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastUpdate] [datetime] NULL,
[HTML] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailAddress] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblWatchD__Email__145D392A] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblWatchDogResults] ADD CONSTRAINT [PK_WatchDogResults] PRIMARY KEY CLUSTERED ([WatchName], [EmailAddress]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblWatchDogResults] TO [public]
GO
GRANT INSERT ON  [dbo].[tblWatchDogResults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblWatchDogResults] TO [public]
GO
GRANT SELECT ON  [dbo].[tblWatchDogResults] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblWatchDogResults] TO [public]
GO
