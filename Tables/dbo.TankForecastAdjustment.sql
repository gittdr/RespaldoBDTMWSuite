CREATE TABLE [dbo].[TankForecastAdjustment]
(
[Id] [int] NOT NULL IDENTITY(1, 1),
[EffectiveStart] [datetime] NOT NULL,
[EffectiveEnd] [datetime] NOT NULL,
[Priority] [int] NOT NULL CONSTRAINT [DF_TankForecastAdjustment_Priority] DEFAULT ((0)),
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmd_code] DEFAULT ('UNKNOWN'),
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmd_class] DEFAULT ('UNKNOWN'),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_id] DEFAULT ('UNKNOWN'),
[cmp_defaultbillto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_defaultbillto] DEFAULT ('UNKNOWN'),
[cmp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_revtype1] DEFAULT ('UNK'),
[cmp_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_revtype2] DEFAULT ('UNK'),
[cmp_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_revtype3] DEFAULT ('UNK'),
[cmp_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_revtype4] DEFAULT ('UNK'),
[cmp_othertype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_othertype1] DEFAULT ('UNK'),
[cmp_othertype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_othertype2] DEFAULT ('UNK'),
[cmp_state] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_TankForecastAdjustment_cmp_state] DEFAULT ('XX'),
[AdjustType] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AdjustAmount] [decimal] (9, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastAdjustment] ADD CONSTRAINT [PK__TankForecastAdju__599045FD] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastAdjustment] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastAdjustment] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastAdjustment] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastAdjustment] TO [public]
GO
