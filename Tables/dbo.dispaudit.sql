CREATE TABLE [dbo].[dispaudit]
(
[ord_hdrnumber] [int] NULL,
[lgh_number] [int] NULL,
[updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_dt] [datetime] NULL,
[stp_number] [int] NULL,
[old_req_pickup_dt] [datetime] NULL,
[new_req_pickup_dt] [datetime] NULL,
[old_req_delivery_dt] [datetime] NULL,
[new_req_delivery_dt] [datetime] NULL,
[old_dispatch_dt] [datetime] NULL,
[new_dispatch_dt] [datetime] NULL,
[old_actual_arrival_dt] [datetime] NULL,
[new_actual_arrival_dt] [datetime] NULL,
[stp_event] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_nmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmp_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dispaudit_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dispaudit] ADD CONSTRAINT [prkey_dispaudit] PRIMARY KEY CLUSTERED ([dispaudit_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dispaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[dispaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dispaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[dispaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[dispaudit] TO [public]
GO
