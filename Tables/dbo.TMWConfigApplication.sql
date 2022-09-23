CREATE TABLE [dbo].[TMWConfigApplication]
(
[AppKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AppDescription] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigApplication] ADD CONSTRAINT [PK_TMWConfigApplication_AppKey] PRIMARY KEY CLUSTERED ([AppKey]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWConfigApplication] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWConfigApplication] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWConfigApplication] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWConfigApplication] TO [public]
GO
