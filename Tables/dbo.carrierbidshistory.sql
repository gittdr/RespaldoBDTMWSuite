CREATE TABLE [dbo].[carrierbidshistory]
(
[cbh_id] [int] NOT NULL IDENTITY(1, 1),
[cb_id] [int] NULL,
[ca_id] [int] NULL,
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_date] [datetime] NULL,
[cb_reply_expires] [datetime] NULL,
[cb_reply_amount] [money] NULL,
[cb_reply_message] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_load_requirement] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_driver_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_truck_mcnum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_trailernumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cb_reply_otheramount] [money] NULL,
[cb_reply_fuelamount] [money] NULL,
[cb_reply_linehaul] [money] NULL,
[created_date] [datetime] NULL,
[created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierbidshistory] ADD CONSTRAINT [pk_carrierbidshistory_cbh_id] PRIMARY KEY CLUSTERED ([cbh_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierbidshistory] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierbidshistory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierbidshistory] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierbidshistory] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierbidshistory] TO [public]
GO
