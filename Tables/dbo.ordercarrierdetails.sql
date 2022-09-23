CREATE TABLE [dbo].[ordercarrierdetails]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ordercarrier_id] [int] NULL,
[fgt_number] [int] NULL,
[quantity] [float] NULL,
[rate] [money] NULL,
[sub_charges] [money] NULL,
[discount_rate] [money] NULL,
[discount] [money] NULL,
[charges] [money] NULL,
[rate_per] [float] NULL,
[deficit] [int] NULL,
[description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tar_number] [int] NULL,
[rate_option] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL,
[cmd_NMFC_rate_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rate_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[discount_per] [decimal] (10, 2) NULL,
[discount_qty] [decimal] (10, 2) NULL,
[discount_tar_number] [int] NULL,
[tariff_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[manual_rate] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ordercarrierdetails] ADD CONSTRAINT [PK__ordercar__3213E83F34C86344] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [oc_details_ocid] ON [dbo].[ordercarrierdetails] ([ordercarrier_id], [id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ordercarrierdetails] TO [public]
GO
GRANT INSERT ON  [dbo].[ordercarrierdetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ordercarrierdetails] TO [public]
GO
GRANT SELECT ON  [dbo].[ordercarrierdetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[ordercarrierdetails] TO [public]
GO
