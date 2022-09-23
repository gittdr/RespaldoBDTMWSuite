CREATE TABLE [dbo].[edi_outbound204_fgt]
(
[ob_204id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[stp_number] [int] NULL,
[fgt_number] [int] NULL,
[fgt_sequence] [int] NULL,
[fgt_count] [decimal] (10, 2) NULL,
[fgt_countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_weight] [float] NULL,
[fgt_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume] [float] NULL,
[fgt_volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_rate] [money] NULL,
[fgt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_charge] [money] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_actual_quantity] [float] NULL,
[fgt_actual_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edi_commodity] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[commodity_stcc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_haz_num] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_hazmat_class_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_hazmat_shipping_name_qualifier] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shipping_name] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_imdg_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_imdg_packaginggroup] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eof_ob_204id] ON [dbo].[edi_outbound204_fgt] ([ob_204id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eof_ord_hdrnumber] ON [dbo].[edi_outbound204_fgt] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_fgt] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_fgt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_outbound204_fgt] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_fgt] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_fgt] TO [public]
GO
