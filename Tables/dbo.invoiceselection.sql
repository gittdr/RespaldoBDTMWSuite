CREATE TABLE [dbo].[invoiceselection]
(
[ivs_number] [int] NOT NULL,
[ivh_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_sequence] [smallint] NULL,
[ivs_copies] [smallint] NULL,
[ivs_showactualtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_invoicedatawindow] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_logocompanyname] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_logocompanyloc] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_logocompanyfontsize] [smallint] NULL,
[ivs_logopicturefile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_remittocompanyname] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_remittocompanyloc] [varchar] (120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_terms] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_invoicetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_interestrate] [money] NULL,
[ivs_imageformat] [varchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_company] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ivs_daysdue] [int] NULL,
[ir_id] [int] NULL,
[ivs_print_orientation] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ivs_number] ON [dbo].[invoiceselection] ([ivs_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invoiceselection] TO [public]
GO
GRANT INSERT ON  [dbo].[invoiceselection] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invoiceselection] TO [public]
GO
GRANT SELECT ON  [dbo].[invoiceselection] TO [public]
GO
GRANT UPDATE ON  [dbo].[invoiceselection] TO [public]
GO
