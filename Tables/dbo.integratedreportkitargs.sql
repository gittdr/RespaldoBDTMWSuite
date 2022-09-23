CREATE TABLE [dbo].[integratedreportkitargs]
(
[ika_id] [int] NOT NULL IDENTITY(1, 1),
[ika_sequence] [int] NULL,
[ika_column_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ika_parameter] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ika_datatype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_id_master] [int] NULL,
[irk_id_email] [int] NULL,
[iki_id] [int] NULL,
[irk_id] [int] NULL,
[ika_created_date] [datetime] NOT NULL,
[ika_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ika_modified_date] [datetime] NULL,
[ika_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ika_parameter_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportkitargs] ADD CONSTRAINT [PK__integratedreport__48808DEE] PRIMARY KEY CLUSTERED ([ika_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportkitargs] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportkitargs] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportkitargs] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportkitargs] TO [public]
GO
