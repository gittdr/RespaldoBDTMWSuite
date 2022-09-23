CREATE TABLE [dbo].[TMSTransitCalculation]
(
[TransitCalcID] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MaxDriveHrs] [decimal] (10, 2) NULL,
[BreakTimeHrs] [decimal] (10, 2) NULL,
[AverageMPH] [decimal] (10, 2) NULL,
[TransitRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitCalculation] ADD CONSTRAINT [PK_TMSTransitCalculation] PRIMARY KEY CLUSTERED ([TransitCalcID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSTransitCalculation] ADD CONSTRAINT [FK_TMSTransitCalculation_TMSTransitCalculationRule] FOREIGN KEY ([TransitRule]) REFERENCES [dbo].[TMSTransitCalculationRule] ([TransitRule])
GO
GRANT DELETE ON  [dbo].[TMSTransitCalculation] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSTransitCalculation] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSTransitCalculation] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSTransitCalculation] TO [public]
GO
