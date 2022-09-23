CREATE TABLE [dbo].[dvgroups]
(
[dvg_group] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dvg_description] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dvgroups] ADD CONSTRAINT [PK__dvgroups__0A41FF6F] PRIMARY KEY CLUSTERED ([dvg_group]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dvgroups] TO [public]
GO
GRANT INSERT ON  [dbo].[dvgroups] TO [public]
GO
GRANT SELECT ON  [dbo].[dvgroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[dvgroups] TO [public]
GO
