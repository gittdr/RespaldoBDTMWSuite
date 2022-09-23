CREATE TABLE [dbo].[cached_dws]
(
[cached_dw_id] [int] NOT NULL IDENTITY(1, 1),
[dwname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[language_id] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cached_dws] ADD CONSTRAINT [pk_cached_dws] PRIMARY KEY CLUSTERED ([cached_dw_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cached_dws] TO [public]
GO
GRANT INSERT ON  [dbo].[cached_dws] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cached_dws] TO [public]
GO
GRANT SELECT ON  [dbo].[cached_dws] TO [public]
GO
GRANT UPDATE ON  [dbo].[cached_dws] TO [public]
GO
