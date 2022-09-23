CREATE TABLE [dbo].[billto_DeliveryReport]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierEmailAddressForErrors] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BuyerID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Supplier] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_cmp_id] ON [dbo].[billto_DeliveryReport] ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[billto_DeliveryReport] TO [public]
GO
GRANT INSERT ON  [dbo].[billto_DeliveryReport] TO [public]
GO
GRANT REFERENCES ON  [dbo].[billto_DeliveryReport] TO [public]
GO
GRANT SELECT ON  [dbo].[billto_DeliveryReport] TO [public]
GO
GRANT UPDATE ON  [dbo].[billto_DeliveryReport] TO [public]
GO
