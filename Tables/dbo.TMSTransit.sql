CREATE TABLE [dbo].[TMSTransit]
(
[TransitID] [int] NOT NULL IDENTITY(1, 1),
[Mode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceLevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TransitCalcId] [int] NOT NULL,
[CarrierRating] [decimal] (18, 4) NULL,
[RatingType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSTransi__Ratin__43C68FD0] DEFAULT ('BOTH'),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RevType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RevType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrlType4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Commodity] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EquipmentType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransit] ADD CONSTRAINT [TMSTransit_chk_RatingType] CHECK (([RatingType]='BUY' OR [RatingType]='SELL' OR [RatingType]='BOTH'))
GO
ALTER TABLE [dbo].[TMSTransit] ADD CONSTRAINT [PK_TMSTransit] PRIMARY KEY CLUSTERED ([TransitID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransit] ADD CONSTRAINT [UC_Mode_ServiceLevel_Carrier_RatingType] UNIQUE NONCLUSTERED ([Mode], [ServiceLevel], [Carrier], [RatingType]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransit] ADD CONSTRAINT [FK_TMSTransit_carrier] FOREIGN KEY ([Carrier]) REFERENCES [dbo].[carrier] ([car_id])
GO
ALTER TABLE [dbo].[TMSTransit] ADD CONSTRAINT [FK_TMSTransit_TMSTransitCalculation] FOREIGN KEY ([TransitCalcId]) REFERENCES [dbo].[TMSTransitCalculation] ([TransitCalcID])
GO
GRANT DELETE ON  [dbo].[TMSTransit] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransit] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransit] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransit] TO [public]
GO
