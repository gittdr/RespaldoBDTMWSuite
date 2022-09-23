CREATE TABLE [dbo].[dx_FieldDefinitions]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_recordtype_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_fielddefstart] [int] NOT NULL,
[dx_fielddeflength] [int] NOT NULL,
[dx_fielddeftype] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_fielddefname] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_dbtable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_dbcolumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_sourcefield] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_dbtype] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_dbUpdateLevel] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_FieldDefinitions] ADD CONSTRAINT [pk_dx_FieldDefinitions] PRIMARY KEY CLUSTERED ([dx_importid], [dx_recordtype_name], [dx_fielddefstart]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_FieldDefinitions] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_FieldDefinitions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_FieldDefinitions] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_FieldDefinitions] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_FieldDefinitions] TO [public]
GO
