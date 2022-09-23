CREATE TABLE [dbo].[nlmvehicletracking_history]
(
[nlm_vthist_id] [int] NOT NULL IDENTITY(1, 1),
[nlm_shipment_number] [int] NULL,
[nlm_url] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_retxml] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived_time] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shipnum] ON [dbo].[nlmvehicletracking_history] ([nlm_shipment_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shipnum_status_time] ON [dbo].[nlmvehicletracking_history] ([nlm_shipment_number], [nlm_status], [archived_time]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_ident] ON [dbo].[nlmvehicletracking_history] ([nlm_vthist_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmvehicletracking_history] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmvehicletracking_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmvehicletracking_history] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmvehicletracking_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmvehicletracking_history] TO [public]
GO
