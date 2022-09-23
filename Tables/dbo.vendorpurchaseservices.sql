CREATE TABLE [dbo].[vendorpurchaseservices]
(
[cmp_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psd_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[vps_estqty] [float] NULL,
[vps_estrate] [money] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[vendorpurchaseservices] TO [public]
GO
GRANT INSERT ON  [dbo].[vendorpurchaseservices] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vendorpurchaseservices] TO [public]
GO
GRANT SELECT ON  [dbo].[vendorpurchaseservices] TO [public]
GO
GRANT UPDATE ON  [dbo].[vendorpurchaseservices] TO [public]
GO
