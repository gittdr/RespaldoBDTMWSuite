CREATE TABLE [dbo].[commoditypurchaseservices]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psd_type] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cps_estqty] [float] NULL,
[cps_estrate] [money] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commoditypurchaseservices] TO [public]
GO
GRANT INSERT ON  [dbo].[commoditypurchaseservices] TO [public]
GO
GRANT REFERENCES ON  [dbo].[commoditypurchaseservices] TO [public]
GO
GRANT SELECT ON  [dbo].[commoditypurchaseservices] TO [public]
GO
GRANT UPDATE ON  [dbo].[commoditypurchaseservices] TO [public]
GO
