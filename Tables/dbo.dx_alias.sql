CREATE TABLE [dbo].[dx_alias]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[Token] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TokenGroup] [float] NULL,
[Hook] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_alias] ADD CONSTRAINT [PK_dx_alias] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_alias] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_alias] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_alias] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_alias] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_alias] TO [public]
GO
