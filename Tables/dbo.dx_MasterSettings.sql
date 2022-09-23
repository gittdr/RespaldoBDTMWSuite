CREATE TABLE [dbo].[dx_MasterSettings]
(
[dx_ident] [int] NOT NULL IDENTITY(1, 1),
[dx_entitytype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_entityname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_description] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_default] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_MasterSettings] ADD CONSTRAINT [PK_dx_MasterSettings] PRIMARY KEY CLUSTERED ([dx_entitytype], [dx_entityname]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_MasterSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_MasterSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_MasterSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_MasterSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_MasterSettings] TO [public]
GO
