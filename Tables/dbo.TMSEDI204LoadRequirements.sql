CREATE TABLE [dbo].[TMSEDI204LoadRequirements]
(
[LoadReqId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NULL,
[CargoId] [int] NULL,
[CompanyId] [int] NULL,
[Version] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AssetType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadRequirementType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MandatoryFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NegativeFlag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Quantity] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204LoadRequirements] ADD CONSTRAINT [PK_TMSEDI204LoadRequirements] PRIMARY KEY CLUSTERED ([LoadReqId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSEDI204LoadRequirements] ADD CONSTRAINT [FK_TMSEDI204LoadRequirements_TMSEDI204Cargo] FOREIGN KEY ([CargoId]) REFERENCES [dbo].[TMSEDI204Cargo] ([CargoId])
GO
ALTER TABLE [dbo].[TMSEDI204LoadRequirements] ADD CONSTRAINT [FK_TMSEDI204LoadRequirements_TMSEDI204Companies] FOREIGN KEY ([CompanyId]) REFERENCES [dbo].[TMSEDI204Companies] ([CompanyId])
GO
ALTER TABLE [dbo].[TMSEDI204LoadRequirements] ADD CONSTRAINT [FK_TMSEDI204LoadRequirements_TMSEDI204Orders] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSEDI204Orders] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSEDI204LoadRequirements] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSEDI204LoadRequirements] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSEDI204LoadRequirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSEDI204LoadRequirements] TO [public]
GO
