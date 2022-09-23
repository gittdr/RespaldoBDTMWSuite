CREATE TABLE [dbo].[cmp_edi_210_settings]
(
[ces_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ces_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_applyto_definition] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_print_terms] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_edi_terms] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_print_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_edi_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ces_nooutput] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cmp_edi_210_settings] ADD CONSTRAINT [PK_cmp_edi_210_settings] PRIMARY KEY CLUSTERED ([ces_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_cmp_id_definition] ON [dbo].[cmp_edi_210_settings] ([cmp_id], [ces_definition], [ces_applyto_definition]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmp_edi_210_settings] TO [public]
GO
GRANT INSERT ON  [dbo].[cmp_edi_210_settings] TO [public]
GO
GRANT SELECT ON  [dbo].[cmp_edi_210_settings] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmp_edi_210_settings] TO [public]
GO
