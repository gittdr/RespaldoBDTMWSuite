CREATE TABLE [dbo].[TMSBranchCapacity]
(
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EqCode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Quantity1Max] [decimal] (14, 4) NOT NULL,
[Quantity2Max] [decimal] (14, 4) NOT NULL,
[Quantity3Max] [decimal] (14, 4) NOT NULL,
[RatingTypeOverride1Def] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatingTypeOverride1Value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatingTypeOverride2Def] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RatingTypeOverride2Value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TruckType] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaxWorkTime] [int] NOT NULL,
[MaxDriveTime] [int] NOT NULL,
[MinLayoverTime] [int] NOT NULL,
[MaxLayoverTime] [int] NOT NULL,
[Maxlayovers] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranchCapacity] ADD CONSTRAINT [PK_TMSBranchCapacity] PRIMARY KEY CLUSTERED ([brn_id], [Code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSBranchCapacity] ADD CONSTRAINT [fk_TMSBranchCapacity_TMSBranch] FOREIGN KEY ([brn_id]) REFERENCES [dbo].[TMSBranch] ([brn_id])
GO
GRANT DELETE ON  [dbo].[TMSBranchCapacity] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSBranchCapacity] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSBranchCapacity] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSBranchCapacity] TO [public]
GO
