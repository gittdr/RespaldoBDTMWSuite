CREATE TABLE [dbo].[TMSTransitRatingDetail]
(
[DetailId] [bigint] NOT NULL IDENTITY(1, 1),
[RateId] [bigint] NOT NULL,
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
ALTER TABLE [dbo].[TMSTransitRatingDetail] ADD CONSTRAINT [PK_TMSTransitRatingDetail] PRIMARY KEY CLUSTERED ([DetailId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitRatingDetail] ADD CONSTRAINT [FK_TMSTransitRating_TMSTransitRatingDetail] FOREIGN KEY ([RateId]) REFERENCES [dbo].[TMSTransitRating] ([RateId])
GO
GRANT DELETE ON  [dbo].[TMSTransitRatingDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitRatingDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitRatingDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitRatingDetail] TO [public]
GO
