CREATE TABLE [dbo].[contact_profile]
(
[con_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_asgn_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[con_print] [int] NULL,
[con_print_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email] [int] NULL,
[con_email_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email_subject] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email_bodytext] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_email_directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_pdf] [int] NULL,
[con_work_directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_work_directory_ovr] [int] NULL,
[con_use_default_coverletter] [int] NULL,
[con_fax_company] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax_coverfile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax_subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax_to] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax] [int] NULL,
[con_fax_ovr] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax_number] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_fax_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[con_clear_files] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[contact_profile] ADD CONSTRAINT [pk_con_id] PRIMARY KEY CLUSTERED ([con_id], [con_asgn_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[contact_profile] TO [public]
GO
GRANT INSERT ON  [dbo].[contact_profile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[contact_profile] TO [public]
GO
GRANT SELECT ON  [dbo].[contact_profile] TO [public]
GO
GRANT UPDATE ON  [dbo].[contact_profile] TO [public]
GO
