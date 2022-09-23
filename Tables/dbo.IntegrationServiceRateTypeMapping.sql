CREATE TABLE [dbo].[IntegrationServiceRateTypeMapping]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[ThreeGCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Strategy] [int] NOT NULL CONSTRAINT [DF_IntegrationServiceRateTypeMapping_Strategy] DEFAULT ((0)),
[ThreeGRateType] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TmwChargeType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TMWPayType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime2] (3) NOT NULL CONSTRAINT [DF_IntegrationServiceRateTypeMapping_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IntegrationServiceRateTypeMapping_CreatedBy] DEFAULT (user_name()),
[LastUpdateDate] [datetime2] (3) NOT NULL CONSTRAINT [DF_IntegrationServiceRateTypeMapping_LastUpdateDate] DEFAULT (getdate()),
[LastUpdateBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_IntegrationServiceRateTypeMapping_LastUpdateBy] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IntegrationServiceRateTypeMapping] ADD CONSTRAINT [PK_IntegrationServiceRateTypeMapping] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IntegrationServiceRateTypeMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[IntegrationServiceRateTypeMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[IntegrationServiceRateTypeMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[IntegrationServiceRateTypeMapping] TO [public]
GO
