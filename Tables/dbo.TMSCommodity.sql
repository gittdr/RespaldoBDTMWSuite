CREATE TABLE [dbo].[TMSCommodity]
(
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemLength] [decimal] (18, 4) NULL,
[ItemWidth] [decimal] (18, 4) NULL,
[ItemHeight] [decimal] (18, 4) NULL,
[ItemWeight] [decimal] (18, 4) NULL,
[ItemsPerCase] [decimal] (18, 4) NULL,
[CaseCount] [decimal] (18, 4) NULL,
[CaseLength] [decimal] (18, 4) NULL,
[CaseWidth] [decimal] (18, 4) NULL,
[CaseHeight] [decimal] (18, 4) NULL,
[CaseWeight] [decimal] (18, 4) NULL,
[CasesPerPallet] [decimal] (18, 4) NULL,
[PalletLength] [decimal] (18, 4) NULL,
[PalletWidth] [decimal] (18, 4) NULL,
[PalletHeight] [decimal] (18, 4) NULL,
[PalletWeight] [decimal] (18, 4) NULL,
[PalletColumnFactor] [int] NOT NULL CONSTRAINT [PalletColumnFactorDefault] DEFAULT ((2)),
[PalletStackabilityFactor] [int] NOT NULL CONSTRAINT [PalletStackabilityFactor] DEFAULT ((1)),
[PalletColumnLength] [int] NOT NULL CONSTRAINT [PalletColumnLengthDefault] DEFAULT ((40))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSCommodity] ADD CONSTRAINT [PK_TMSCommodity] PRIMARY KEY CLUSTERED ([cmd_code]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSCommodity] ADD CONSTRAINT [FK_TMSCommodity_commodity] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
GRANT DELETE ON  [dbo].[TMSCommodity] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSCommodity] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSCommodity] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSCommodity] TO [public]
GO
