CREATE TABLE [dbo].[dx_ImportTypes]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_importname] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_importtype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_recordtype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_location] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_query] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_filewatch_enabled] [bit] NOT NULL,
[dx_polling_enabled] [bit] NOT NULL,
[dx_polling_minutes] [float] NULL,
[dx_timecheck_seconds] [bigint] NULL,
[dx_import_file_mask] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_delimiters] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_headersincluded] [bit] NOT NULL,
[dx_archive] [bit] NOT NULL,
[dx_archivedir] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_faileddir] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_auto_purge] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_ImportTypes] ADD CONSTRAINT [pk_dx_ImportTypes] PRIMARY KEY CLUSTERED ([dx_importid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_ImportTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_ImportTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_ImportTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_ImportTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_ImportTypes] TO [public]
GO
