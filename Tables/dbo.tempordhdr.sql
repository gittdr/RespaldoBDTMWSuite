CREATE TABLE [dbo].[tempordhdr]
(
[toh_ordernumber] [int] NOT NULL,
[toh_orderedby] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_contact] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_shipdate] [datetime] NOT NULL,
[toh_deldate] [datetime] NOT NULL,
[toh_refnumtype] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_driver] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_trailer] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_rateunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_rate] [money] NULL,
[toh_quantity] [float] NULL,
[toh_charge] [money] NULL,
[toh_user] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_tstampq] [int] NULL,
[toh_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_hitemp] [smallint] NULL,
[toh_lotemp] [smallint] NULL,
[toh_pallets] [smallint] NULL,
[toh_comments] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_error_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_flag1] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_flag2] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_flag3] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_flag4] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mov_number] [int] NULL,
[toh_edicontrolid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_bookdate] [datetime] NULL,
[toh_quantityunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_ordtype] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_ord_number] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_ord_terms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_ord_totalmiles] [int] NULL,
[toh_inv_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_ord_quantity_type] [int] NULL,
[toh_ord_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_trl_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_lgh_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_key] ON [dbo].[tempordhdr] ([toh_tstampq], [toh_ordernumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tempordhdr] ADD CONSTRAINT [FK_toh_billto] FOREIGN KEY ([toh_billto]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[tempordhdr] ADD CONSTRAINT [FK_toh_consignee] FOREIGN KEY ([toh_consignee]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[tempordhdr] ADD CONSTRAINT [FK_toh_orderedby] FOREIGN KEY ([toh_orderedby]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[tempordhdr] ADD CONSTRAINT [FK_toh_shipper] FOREIGN KEY ([toh_shipper]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[tempordhdr] TO [public]
GO
GRANT INSERT ON  [dbo].[tempordhdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tempordhdr] TO [public]
GO
GRANT SELECT ON  [dbo].[tempordhdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[tempordhdr] TO [public]
GO
