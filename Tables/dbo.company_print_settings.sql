CREATE TABLE [dbo].[company_print_settings]
(
[cps_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cps_print_invoice] [int] NULL,
[cps_print_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_fax_invoice] [int] NULL,
[cps_fax_number] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_fax_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_email_invoice] [int] NULL,
[cps_email_address1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_email_address2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_email_address3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_email_printer] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_email_subject] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_pdf_invoice] [int] NULL,
[cps_email_directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cps_work_directory] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_email_bodytext] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_fax_coverfile] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_fax_subject] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_fax_to] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_clear_files] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_print_settings] ADD CONSTRAINT [pk_cps_id] PRIMARY KEY CLUSTERED ([cps_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cps_company_uk] ON [dbo].[company_print_settings] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_print_settings] TO [public]
GO
GRANT INSERT ON  [dbo].[company_print_settings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_print_settings] TO [public]
GO
GRANT SELECT ON  [dbo].[company_print_settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_print_settings] TO [public]
GO
