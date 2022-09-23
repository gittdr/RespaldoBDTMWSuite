CREATE TABLE [dbo].[ResNow_OrderStatusChanges]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_dt] [datetime] NULL,
[PriorStatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NextStatus] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Order_Prior_Next] ON [dbo].[ResNow_OrderStatusChanges] ([ord_hdrnumber], [PriorStatus], [NextStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_OrderStatusChanges_PriorNextPlus] ON [dbo].[ResNow_OrderStatusChanges] ([PriorStatus], [NextStatus]) INCLUDE ([ord_hdrnumber], [updated_dt]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_ResNow_OrderStatusChanges_sn] ON [dbo].[ResNow_OrderStatusChanges] ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Date_Prior_Next] ON [dbo].[ResNow_OrderStatusChanges] ([updated_dt], [PriorStatus], [NextStatus]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_OrderStatusChanges] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_OrderStatusChanges] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_OrderStatusChanges] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_OrderStatusChanges] TO [public]
GO
