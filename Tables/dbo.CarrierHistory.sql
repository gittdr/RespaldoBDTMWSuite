CREATE TABLE [dbo].[CarrierHistory]
(
[Crh_Carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Crh_Total] [int] NULL,
[Crh_OnTime] [int] NULL,
[Crh_percent] [int] NULL,
[Crh_AveFuel] [money] NULL,
[Crh_AveTotal] [money] NULL,
[Crh_AveAcc] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Crh_Carrier__Ind] ON [dbo].[CarrierHistory] ([Crh_Carrier]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[CarrierHistory] TO [public]
GO
