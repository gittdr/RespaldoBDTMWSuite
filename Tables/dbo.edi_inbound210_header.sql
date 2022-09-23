CREATE TABLE [dbo].[edi_inbound210_header]
(
[inv_number] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[invoice_date] [datetime] NULL,
[ord_identifier] [int] NULL,
[ord_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[payment_method] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tot_weight] [int] NULL,
[tot_charge] [money] NULL,
[car_edi_scac] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[warning_reason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_in210_ord_number] ON [dbo].[edi_inbound210_header] ([ord_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_inbound210_header] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_inbound210_header] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_inbound210_header] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_inbound210_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_inbound210_header] TO [public]
GO
