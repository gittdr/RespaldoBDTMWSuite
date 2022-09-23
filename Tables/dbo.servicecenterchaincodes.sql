CREATE TABLE [dbo].[servicecenterchaincodes]
(
[sccc_id] [int] NOT NULL IDENTITY(1, 1),
[sccc_chaincode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sccc_rebateamount] [money] NOT NULL,
[sccc_fueltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sccc_rateunit] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sccc_expiration_date] [datetime] NOT NULL,
[sccc_policy_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[servicecenterchaincodes] ADD CONSTRAINT [PK__servicecentercha__270A5591] PRIMARY KEY CLUSTERED ([sccc_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[servicecenterchaincodes] TO [public]
GO
GRANT INSERT ON  [dbo].[servicecenterchaincodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[servicecenterchaincodes] TO [public]
GO
GRANT SELECT ON  [dbo].[servicecenterchaincodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[servicecenterchaincodes] TO [public]
GO
