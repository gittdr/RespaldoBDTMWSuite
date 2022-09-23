CREATE TABLE [dbo].[integratedreportkits]
(
[irk_id] [int] NOT NULL IDENTITY(1, 1),
[irk_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_purpose] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_master_ir_id] [int] NULL,
[irk_email_ir_id] [int] NULL,
[irk_report_list] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_message_list] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_communication_list] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_post_process_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_post_process] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_default_subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_default_other_email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irk_created_date] [datetime] NOT NULL,
[irk_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irk_modified_date] [datetime] NULL,
[irk_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integratedreportkits] ADD CONSTRAINT [PK__integratedreport__4698457C] PRIMARY KEY CLUSTERED ([irk_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integratedreportkits] TO [public]
GO
GRANT INSERT ON  [dbo].[integratedreportkits] TO [public]
GO
GRANT SELECT ON  [dbo].[integratedreportkits] TO [public]
GO
GRANT UPDATE ON  [dbo].[integratedreportkits] TO [public]
GO
