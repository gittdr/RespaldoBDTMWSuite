CREATE TABLE [dbo].[integratedreportkititems]
(
[iki_id] [int] NOT NULL IDENTITY(1, 1),
[iki_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ir_id] [int] NULL,
[iki_inclusion_rule] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_id] [int] NULL,
[iki_created_date] [datetime] NOT NULL,
[iki_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[iki_modified_date] [datetime] NULL,
[iki_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iki_file_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iki_extension] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iki_separator] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iki_delimiter] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[iki_line_ending] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportkititems] ADD CONSTRAINT [PK__integratedreport__4A68D660] PRIMARY KEY CLUSTERED ([iki_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportkititems] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportkititems] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportkititems] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportkititems] TO [public]
GO
