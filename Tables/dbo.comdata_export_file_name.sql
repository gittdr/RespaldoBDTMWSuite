CREATE TABLE [dbo].[comdata_export_file_name]
(
[cefn_id] [int] NOT NULL IDENTITY(1, 1),
[cefn_date] [datetime] NOT NULL,
[cefn_ctrlnumber] [int] NOT NULL CONSTRAINT [df_cefm_ctrlnumber] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[comdata_export_file_name] ADD CONSTRAINT [pk_cefn_id] PRIMARY KEY CLUSTERED ([cefn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[comdata_export_file_name] TO [public]
GO
GRANT INSERT ON  [dbo].[comdata_export_file_name] TO [public]
GO
GRANT REFERENCES ON  [dbo].[comdata_export_file_name] TO [public]
GO
GRANT SELECT ON  [dbo].[comdata_export_file_name] TO [public]
GO
GRANT UPDATE ON  [dbo].[comdata_export_file_name] TO [public]
GO
