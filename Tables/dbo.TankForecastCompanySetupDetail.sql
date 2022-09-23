CREATE TABLE [dbo].[TankForecastCompanySetupDetail]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayOrder] [int] NOT NULL,
[TargetMinDelivery] [int] NOT NULL,
[TargetOnHandAmount] [int] NOT NULL,
[TargetOnHandRule] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpecificGravity] [decimal] (9, 4) NULL,
[TankKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DefaultTankKey] DEFAULT (''),
[ForecastRule] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DefaultTargetRule] DEFAULT ('TARGET'),
[DefaultShipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [TankForecastCompanySetupDetail_DefaultShipper] DEFAULT ('UNKNOWN'),
[DefaultSupplier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [TankForecastCompanySetupDetail_DefaultSupplier] DEFAULT ('UNKNOWN'),
[DefaultAccountOf] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [TankForecastCompanySetupDetail_DefaultAccountOf] DEFAULT ('UNKNOWN'),
[TargetMaxDelivery] [int] NULL,
[TargetDeliveryWindowHrs] [int] NOT NULL CONSTRAINT [df_TankForecastCompanySetupDetail_TargetDeliveryWindowHrs] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastCompanySetupDetail] ADD CONSTRAINT [PK_TankForecastCompanySetupDetail] PRIMARY KEY CLUSTERED ([cmp_id], [cmd_code], [TankKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [uk_TankForecastCompanySetupDetail_cmp_id_DisplayOrder] ON [dbo].[TankForecastCompanySetupDetail] ([cmp_id], [DisplayOrder]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TankForecastCompanySetupDetail] ADD CONSTRAINT [FK_TankForecastCompanySetupDetail_cmd_code] FOREIGN KEY ([cmd_code]) REFERENCES [dbo].[commodity] ([cmd_code])
GO
ALTER TABLE [dbo].[TankForecastCompanySetupDetail] ADD CONSTRAINT [FK_TankForecastCompanySetupDetail_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[TankForecastCompanySetupDetail] ADD CONSTRAINT [FK_TankForecastCompanySetupDetail_ForecastRule] FOREIGN KEY ([ForecastRule]) REFERENCES [dbo].[TankForecastRuleList] ([ForecastRule])
GO
GRANT DELETE ON  [dbo].[TankForecastCompanySetupDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TankForecastCompanySetupDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TankForecastCompanySetupDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TankForecastCompanySetupDetail] TO [public]
GO
