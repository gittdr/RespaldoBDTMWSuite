CREATE TABLE [dbo].[dx_Settings]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[Application] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[settingSection] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[settingKeyword] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[settingValue] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[settingDefault] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Settings] ADD CONSTRAINT [PK_dx_Settings] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Settings] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Settings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_Settings] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Settings] TO [public]
GO
