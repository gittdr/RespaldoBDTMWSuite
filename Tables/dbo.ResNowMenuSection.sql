CREATE TABLE [dbo].[ResNowMenuSection]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[Active] [int] NOT NULL CONSTRAINT [DF__ResNowMen__Activ__00E05062] DEFAULT ((1)),
[Sort] [int] NOT NULL CONSTRAINT [DF__ResNowMenu__Sort__01D4749B] DEFAULT ((0)),
[Caption] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaptionFull] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MenuSystem] [int] NOT NULL CONSTRAINT [DF__ResNowMen__MenuS__02C898D4] DEFAULT ((0)),
[CustomProcess] [int] NOT NULL CONSTRAINT [DF__ResNowMen__Custo__03BCBD0D] DEFAULT ((0)),
[CustomPageTable] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomAdminPageURL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SystemCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNowMenuSection] ADD CONSTRAINT [PK__ResNowMenuSectio__7FEC2C29] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNowMenuSection] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNowMenuSection] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ResNowMenuSection] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNowMenuSection] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNowMenuSection] TO [public]
GO
