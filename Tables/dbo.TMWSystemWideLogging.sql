CREATE TABLE [dbo].[TMWSystemWideLogging]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[AppID] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyWord1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[KeyWord2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Importance] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMWUser] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AppVersion] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscDataDef] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MiscData4] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDate] [datetime] NULL,
[Message] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWSystemWideLogging] ADD CONSTRAINT [pk_tsswlogging] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWSystemWideLogging] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWSystemWideLogging] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWSystemWideLogging] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWSystemWideLogging] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWSystemWideLogging] TO [public]
GO
