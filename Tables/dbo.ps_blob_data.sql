CREATE TABLE [dbo].[ps_blob_data]
(
[blob_id] [int] NOT NULL IDENTITY(1, 1),
[blob_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blob_key] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blob_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blob_data] [image] NULL,
[blob_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blob_input_method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Blob_nbr] [smallint] NULL,
[blob_pictype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[blob_picdesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ps_blob_data] ADD CONSTRAINT [ID_PK] PRIMARY KEY CLUSTERED ([blob_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_tablekey] ON [dbo].[ps_blob_data] ([blob_table], [blob_key], [Blob_nbr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ps_blob_data] TO [public]
GO
GRANT INSERT ON  [dbo].[ps_blob_data] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ps_blob_data] TO [public]
GO
GRANT SELECT ON  [dbo].[ps_blob_data] TO [public]
GO
GRANT UPDATE ON  [dbo].[ps_blob_data] TO [public]
GO
