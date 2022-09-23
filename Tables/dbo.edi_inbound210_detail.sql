CREATE TABLE [dbo].[edi_inbound210_detail]
(
[inv_number] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_identifier] [int] NULL,
[ord_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [int] NULL,
[weight_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [int] NULL,
[quantity_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate] [money] NULL,
[rate_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[charge] [money] NULL,
[item_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_in210detail_ord_number] ON [dbo].[edi_inbound210_detail] ([ord_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_inbound210_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_inbound210_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_inbound210_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_inbound210_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_inbound210_detail] TO [public]
GO
