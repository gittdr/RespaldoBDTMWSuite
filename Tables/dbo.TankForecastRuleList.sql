CREATE TABLE [dbo].[TankForecastRuleList]
(
[ForecastRule] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TriggerField] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IgnoreRunOut] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SingleDelivery] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastRuleList] ADD CONSTRAINT [PK__TankForecastRule__3DE82B88] PRIMARY KEY CLUSTERED ([ForecastRule]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TankForecastRuleList] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastRuleList] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastRuleList] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastRuleList] TO [public]
GO
