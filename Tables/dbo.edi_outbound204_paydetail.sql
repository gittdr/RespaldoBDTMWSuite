CREATE TABLE [dbo].[edi_outbound204_paydetail]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ob_204id] [int] NOT NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[pyd_number] [int] NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_rate] [money] NULL,
[pyd_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_amount] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_eop_ob_204id] ON [dbo].[edi_outbound204_paydetail] ([ob_204id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_outbound204_paydetail] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_outbound204_paydetail] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_outbound204_paydetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_outbound204_paydetail] TO [public]
GO
