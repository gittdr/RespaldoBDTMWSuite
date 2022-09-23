CREATE TABLE [dbo].[vin_event_export]
(
[vee_id] [numeric] (18, 0) NOT NULL IDENTITY(1, 1),
[vee_creation_dt] [datetime] NOT NULL,
[vee_processed_dt] [datetime] NULL,
[vee_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__vin_event__vee_s__3F70B740] DEFAULT (0),
[vee_error_msg] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_origin] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_brand] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_ord_hdrnumber] [int] NULL,
[vee_vin] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_code] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_date_time] [datetime] NULL,
[vee_event_data1] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_data2] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_data3] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[vee_event_data4] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[vin_event_export] ADD CONSTRAINT [pk_vin_event_export] PRIMARY KEY CLUSTERED ([vee_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[vin_event_export] TO [public]
GO
GRANT INSERT ON  [dbo].[vin_event_export] TO [public]
GO
GRANT REFERENCES ON  [dbo].[vin_event_export] TO [public]
GO
GRANT SELECT ON  [dbo].[vin_event_export] TO [public]
GO
GRANT UPDATE ON  [dbo].[vin_event_export] TO [public]
GO
