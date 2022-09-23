CREATE TABLE [dbo].[TMWConfigSection]
(
[AppKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SectionKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SectionDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigSection] ADD CONSTRAINT [PK_TMWConfigSection_AppKey_SectionKey] PRIMARY KEY CLUSTERED ([AppKey], [SectionKey]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigSection] ADD CONSTRAINT [FK_TMWConfigSection_TMWConfigApplication] FOREIGN KEY ([AppKey]) REFERENCES [dbo].[TMWConfigApplication] ([AppKey])
GO
GRANT DELETE ON  [dbo].[TMWConfigSection] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWConfigSection] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWConfigSection] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWConfigSection] TO [public]
GO
