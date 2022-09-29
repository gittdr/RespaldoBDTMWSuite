CREATE TABLE [dbo].[fuelpurchased]
(
[fp_id] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fp_sequence] [int] NOT NULL,
[fp_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_ccd_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_purchcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[fp_date] [datetime] NULL,
[fp_quantity] [money] NULL,
[fp_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_fueltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_trc_trl] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_cost_per] [money] NULL,
[fp_amount] [money] NULL,
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[stp_number] [int] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_number] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_odometer] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_vendorname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_cityname] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_city] [int] NULL,
[fp_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_invoice_no] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_charge_yn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_enteredby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_processeddt] [datetime] NULL,
[fp_processedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_statusdate] [datetime] NULL,
[fp_rebateamount] [money] NULL,
[fp_nonbillableitem] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_network_ts] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_contractnum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[cfp_identity] [int] NULL,
[fp_prevodometer] [int] NULL,
[fp_chaincode] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fp_servicefee] [money] NULL,
[fp_geotabodometer] [int] NULL,
[fp_kmsfromlastpurchase] [int] NULL,
[fp_rendimiento] [float] NULL,
[fp_tanklevel] [float] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__fuelpurch__INS_T__538D19BC] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelpurchased] ADD CONSTRAINT [pk_fuelpurchased] PRIMARY KEY CLUSTERED ([fp_id], [fp_sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fuelpurchased_fp_date] ON [dbo].[fuelpurchased] ([fp_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FuelPurchased_fp_date] ON [dbo].[fuelpurchased] ([fp_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_invno_fueltype] ON [dbo].[fuelpurchased] ([fp_invoice_no], [fp_fueltype], [fp_purchcode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [fuelpurchased_INS_TIMESTAMP] ON [dbo].[fuelpurchased] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_fuelpurchased_timestamp] ON [dbo].[fuelpurchased] ([timestamp]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_FuelPurchased_trc_number] ON [dbo].[fuelpurchased] ([trc_number]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelpurchased] ADD CONSTRAINT [fk_fuelpurchasedtoproducts] FOREIGN KEY ([cfp_identity]) REFERENCES [dbo].[cdfuelproducts] ([cfp_identity])
GO
ALTER TABLE [dbo].[fuelpurchased] ADD CONSTRAINT [fk_fuelpurchasedtotruckstops] FOREIGN KEY ([ts_code]) REFERENCES [dbo].[truckstops] ([ts_code])
GO
ALTER TABLE [dbo].[fuelpurchased] ADD CONSTRAINT [fk_fuelpurchasetocashcard] FOREIGN KEY ([fp_cardnumber], [fp_cac_id], [fp_ccd_id]) REFERENCES [dbo].[cashcard] ([crd_cardnumber], [crd_accountid], [crd_customerid])
GO
GRANT DELETE ON  [dbo].[fuelpurchased] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelpurchased] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelpurchased] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelpurchased] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelpurchased] TO [public]
GO
