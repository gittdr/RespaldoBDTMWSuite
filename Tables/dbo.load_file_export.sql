CREATE TABLE [dbo].[load_file_export]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[lfe_output] [char] (382) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[load_file_export] ADD CONSTRAINT [pk_load_file_export_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[load_file_export] TO [public]
GO
GRANT INSERT ON  [dbo].[load_file_export] TO [public]
GO
GRANT REFERENCES ON  [dbo].[load_file_export] TO [public]
GO
GRANT SELECT ON  [dbo].[load_file_export] TO [public]
GO
GRANT UPDATE ON  [dbo].[load_file_export] TO [public]
GO
