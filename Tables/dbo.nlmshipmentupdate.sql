CREATE TABLE [dbo].[nlmshipmentupdate]
(
[update_id] [int] NOT NULL IDENTITY(1, 1),
[nlm_shipment_number] [int] NULL,
[lgh_number] [int] NULL,
[stp_number] [int] NULL,
[event_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[process_time] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[nlmshipmentupdate] TO [public]
GO
GRANT INSERT ON  [dbo].[nlmshipmentupdate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[nlmshipmentupdate] TO [public]
GO
GRANT SELECT ON  [dbo].[nlmshipmentupdate] TO [public]
GO
GRANT UPDATE ON  [dbo].[nlmshipmentupdate] TO [public]
GO
