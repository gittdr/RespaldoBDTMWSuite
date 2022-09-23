CREATE TABLE [dbo].[TMSBranch]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultCarrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatingType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ETSTransferType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ETSTransferType] DEFAULT ('OR2FGT'),
[MileageLookupType] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_MileageLookupType] DEFAULT ('LATLONG'),
[EnableOptimizationDebugMode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_EnableOptimizationDebugMode] DEFAULT ('N'),
[QuantityRule1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__Quant__435C7B7C] DEFAULT ('SumLineItems'),
[QuantityRule2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__Quant__44509FB5] DEFAULT ('SumLineItems'),
[QuantityRule3] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__Quant__4544C3EE] DEFAULT ('SumLineItems'),
[BookedByRevType1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PORefNum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORDRefNum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AllowLineItemEditAfterTransfer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__Allow__4638E827] DEFAULT ('N'),
[AutoRateAfterTransfer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__AutoR__472D0C60] DEFAULT ('N'),
[ForceTruckLoadOptimization] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__Force__48213099] DEFAULT ('N'),
[UseIterativePlanning] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__UseIt__491554D2] DEFAULT ('N'),
[MaxPickups] [int] NOT NULL CONSTRAINT [DF__TMSBranch__MaxPi__4A09790B] DEFAULT ((1)),
[MaxDrops] [int] NOT NULL CONSTRAINT [DF__TMSBranch__MaxDr__4AFD9D44] DEFAULT ((1)),
[MaxDistanceBetweenStops] [int] NOT NULL CONSTRAINT [DF__TMSBranch__MaxDi__4BF1C17D] DEFAULT ((1)),
[MaxOutofRouteMileages] [int] NOT NULL CONSTRAINT [DF__TMSBranch__MaxOu__4CE5E5B6] DEFAULT ((1)),
[UseLifo] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__TMSBranch__UseLi__4DDA09EF] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranch] ADD CONSTRAINT [TMSBranch_chk_RatingType] CHECK (([RatingType]='BUY' OR [RatingType]='SELL'))
GO
ALTER TABLE [dbo].[TMSBranch] ADD CONSTRAINT [PK_TMSBranch] PRIMARY KEY CLUSTERED ([brn_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranch] ADD CONSTRAINT [fk_TMSBranch_Branch] FOREIGN KEY ([brn_id]) REFERENCES [dbo].[branch] ([brn_id])
GO
GRANT DELETE ON  [dbo].[TMSBranch] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSBranch] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSBranch] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSBranch] TO [public]
GO
