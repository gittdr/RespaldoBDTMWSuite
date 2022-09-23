CREATE TABLE [dbo].[integrated_report_menu_args]
(
[ir_id] [int] NOT NULL,
[irm_sequence] [int] NOT NULL,
[irm_datawindow] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irma_sequence] [int] NOT NULL,
[irma_column_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[irma_parameter] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irma_datatype] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[irma_parameter_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[integrated_report_menu_args] ADD CONSTRAINT [pk_integrated_report_menu_args] PRIMARY KEY NONCLUSTERED ([ir_id], [irm_sequence], [irm_datawindow], [irma_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[integrated_report_menu_args] TO [public]
GO
GRANT INSERT ON  [dbo].[integrated_report_menu_args] TO [public]
GO
GRANT REFERENCES ON  [dbo].[integrated_report_menu_args] TO [public]
GO
GRANT SELECT ON  [dbo].[integrated_report_menu_args] TO [public]
GO
GRANT UPDATE ON  [dbo].[integrated_report_menu_args] TO [public]
GO
