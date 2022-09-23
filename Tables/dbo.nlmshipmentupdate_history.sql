CREATE TABLE [dbo].[nlmshipmentupdate_history]
(
[nlm_shipment_number] [int] NOT NULL,
[nlm_url] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_retxml] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nlm_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[archived_time] [datetime] NOT NULL,
[nlmsuh_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_shipnum_status_time] ON [dbo].[nlmshipmentupdate_history] ([nlm_shipment_number], [nlm_status], [archived_time]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [uk_ident] ON [dbo].[nlmshipmentupdate_history] ([nlmsuh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmshipmentupdate_history] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmshipmentupdate_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmshipmentupdate_history] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmshipmentupdate_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmshipmentupdate_history] TO [public]
GO
