CREATE TABLE [dbo].[Orderheader_TMSOrderRating]
(
[RateId] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[RateMode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [money] NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [money] NULL,
[RateUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Charge] [decimal] (19, 4) NULL,
[ChargeType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TarNumber] [int] NULL,
[TarString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinQuantity] [decimal] (19, 4) NULL,
[MinCharge] [decimal] (19, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Orderheader_TMSOrderRating] ADD CONSTRAINT [PK_Orderheader_TMSOrderRating] PRIMARY KEY CLUSTERED ([RateId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Orderheader_TMSOrderRating] TO [public]
GO
GRANT INSERT ON  [dbo].[Orderheader_TMSOrderRating] TO [public]
GO
GRANT SELECT ON  [dbo].[Orderheader_TMSOrderRating] TO [public]
GO
GRANT UPDATE ON  [dbo].[Orderheader_TMSOrderRating] TO [public]
GO
