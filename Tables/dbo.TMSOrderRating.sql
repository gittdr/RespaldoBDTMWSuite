CREATE TABLE [dbo].[TMSOrderRating]
(
[RateId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NULL,
[RateMode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rate] [money] NULL,
[Quantity] [money] NULL,
[TarNumber] [int] NULL,
[TarString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChargeType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RateUnit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Charge] [decimal] (19, 4) NULL,
[MinQuantity] [decimal] (19, 4) NULL,
[MinCharge] [decimal] (19, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderRating] ADD CONSTRAINT [PK_TMSOrderRating] PRIMARY KEY CLUSTERED ([RateId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderRating] ADD CONSTRAINT [FK_TMSOrderRating_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderRating] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderRating] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderRating] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderRating] TO [public]
GO
