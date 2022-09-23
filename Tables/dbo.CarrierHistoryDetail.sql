CREATE TABLE [dbo].[CarrierHistoryDetail]
(
[chd_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[ord_origincity] [int] NULL,
[ord_originstate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_destcity] [int] NULL,
[ord_deststate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Crh_Carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_pay] [money] NULL,
[lgh_accessorial] [money] NULL,
[lgh_fsc] [money] NULL,
[lgh_billed] [money] NULL,
[lgh_paid] [money] NULL,
[lgh_enddate] [datetime] NULL,
[orders_late] [int] NULL,
[margin] [money] NULL,
[lgh_number] [int] NULL,
[lgh_invoiced] [money] NULL,
[lgh_prebilled] [money] NULL,
[chd_archive] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierHistoryDetail] ADD CONSTRAINT [pk_carrierhistorydetail_chd_id] PRIMARY KEY CLUSTERED ([chd_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_chd_composite] ON [dbo].[CarrierHistoryDetail] ([Crh_Carrier], [ord_origincity], [ord_originstate], [ord_destcity], [ord_deststate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carhistdestcity] ON [dbo].[CarrierHistoryDetail] ([ord_destcity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carhistorigindestcity] ON [dbo].[CarrierHistoryDetail] ([ord_origincity], [ord_destcity]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[CarrierHistoryDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHistoryDetail] TO [public]
GO
