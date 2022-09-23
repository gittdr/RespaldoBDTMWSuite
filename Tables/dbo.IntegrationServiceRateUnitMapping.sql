CREATE TABLE [dbo].[IntegrationServiceRateUnitMapping]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ItemType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ThreeGRateType] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ThreeGHandlingUnit] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TmwUnitBasis] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TmwRateUnit] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime2] (3) NOT NULL CONSTRAINT [DF_IntegrationServiceRateUnitMapping_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IntegrationServiceRateUnitMapping_CreatedBy] DEFAULT (user_name()),
[LastUpdateDate] [datetime2] (3) NOT NULL CONSTRAINT [DF_IntegrationServiceRateUnitMapping_LastUpdateDate] DEFAULT (getdate()),
[LastUpdateBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IntegrationServiceRateUnitMapping_LastUpdateBy] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceRateUnitMapping] ADD CONSTRAINT [PK_IntegrationServiceRateUnitMapping] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceRateUnitMapping] ADD CONSTRAINT [IX_IntegrationServiceRateUnitMapping] UNIQUE NONCLUSTERED ([ItemType], [ThreeGRateType], [TmwUnitBasis]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IntegrationServiceRateUnitMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceRateUnitMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceRateUnitMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceRateUnitMapping] TO [public]
GO
