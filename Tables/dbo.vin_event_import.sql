CREATE TABLE [dbo].[vin_event_import]
(
[vei_id] [numeric] (18, 0) NOT NULL IDENTITY(1, 1),
[vei_creation_dt] [datetime] NOT NULL,
[vei_processed_dt] [datetime] NULL,
[vei_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__vin_event__vei_s__424D23EB] DEFAULT (0),
[vei_error_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_origin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_brand] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_vin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_ord_hdrnumber] [int] NULL,
[vei_event_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_event_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_event_date_time] [datetime] NULL,
[vei_event_data1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_event_data2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_event_data3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vei_event_data4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vin_event_import] ADD CONSTRAINT [pk_vin_event_import] PRIMARY KEY CLUSTERED ([vei_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_vei_event_code] ON [dbo].[vin_event_import] ([vei_event_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_vei_status] ON [dbo].[vin_event_import] ([vei_status]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[vin_event_import] TO [public]
GO
GRANT INSERT ON  [dbo].[vin_event_import] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vin_event_import] TO [public]
GO
GRANT SELECT ON  [dbo].[vin_event_import] TO [public]
GO
GRANT UPDATE ON  [dbo].[vin_event_import] TO [public]
GO
