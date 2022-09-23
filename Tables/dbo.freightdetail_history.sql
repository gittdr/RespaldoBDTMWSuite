CREATE TABLE [dbo].[freightdetail_history]
(
[rev_id] [int] NOT NULL IDENTITY(1, 1),
[fgt_number] [int] NULL,
[evt_number] [int] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reweigh_date] [datetime] NULL,
[count] [decimal] (10, 2) NULL,
[countunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pallet] [float] NULL,
[palletunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weight] [float] NULL,
[weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[volume] [float] NULL,
[volumeunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[length] [float] NULL,
[lengthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[height] [float] NULL,
[heightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[width] [float] NULL,
[widthunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_reftype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_quantity] [float] NULL,
[fgt_rate] [money] NULL,
[fgt_charge] [money] NULL,
[fgt_rateunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cht_basisunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_NMFC_rate_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_count2] [decimal] (10, 2) NULL,
[fgt_count2unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volume2] [float] NULL,
[fgt_volume2unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_volumeunit2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_deficit_row] [int] NULL,
[fgt_rate_per] [decimal] (10, 2) NULL,
[fgt_sub_charge] [decimal] (10, 2) NULL,
[fgt_discount_rate] [decimal] (10, 2) NULL,
[fgt_discount_per] [decimal] (10, 2) NULL,
[fgt_discount] [decimal] (10, 2) NULL,
[fgt_gross_manual] [decimal] (10, 2) NULL,
[fgt_disc_tar_number] [int] NULL,
[fgt_discount_qty] [decimal] (10, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[freightdetail_history] ADD CONSTRAINT [PK__freightd__397465D6D194A412] PRIMARY KEY CLUSTERED ([rev_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[freightdetail_history] TO [public]
GO
GRANT INSERT ON  [dbo].[freightdetail_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[freightdetail_history] TO [public]
GO
GRANT SELECT ON  [dbo].[freightdetail_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[freightdetail_history] TO [public]
GO
