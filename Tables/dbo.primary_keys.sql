CREATE TABLE [dbo].[primary_keys]
(
[table_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[index_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[column_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[key_ordinal] [int] NOT NULL,
[indid] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[primary_keys] ADD CONSTRAINT [pk_primary_keys] PRIMARY KEY CLUSTERED ([table_name], [indid], [key_ordinal]) ON [PRIMARY]
GO
