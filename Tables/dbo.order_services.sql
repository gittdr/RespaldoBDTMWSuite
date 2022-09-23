CREATE TABLE [dbo].[order_services]
(
[mov_number] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[stp_number] [int] NOT NULL,
[fgt_number] [int] NOT NULL,
[svc_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[order_qty] [money] NULL,
[actual_qty] [money] NULL,
[charge_rate] [money] NULL,
[pay_rate] [money] NULL,
[comment] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[create_userid] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_order_services_create_userid] DEFAULT (user_name()),
[create_date] [datetime] NOT NULL CONSTRAINT [DF_order_services_create_date] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[order_services] ADD CONSTRAINT [PK_order_services] PRIMARY KEY NONCLUSTERED ([mov_number], [ord_hdrnumber], [stp_number], [fgt_number], [svc_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ord_services_order] ON [dbo].[order_services] ([ord_hdrnumber]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[order_services] ADD CONSTRAINT [FK_order_services_order] FOREIGN KEY ([ord_hdrnumber]) REFERENCES [dbo].[orderheader] ([ord_hdrnumber])
GO
ALTER TABLE [dbo].[order_services] ADD CONSTRAINT [FK_order_services_services] FOREIGN KEY ([svc_code]) REFERENCES [dbo].[services] ([svc_code])
GO
GRANT DELETE ON  [dbo].[order_services] TO [public]
GO
GRANT INSERT ON  [dbo].[order_services] TO [public]
GO
GRANT REFERENCES ON  [dbo].[order_services] TO [public]
GO
GRANT SELECT ON  [dbo].[order_services] TO [public]
GO
GRANT UPDATE ON  [dbo].[order_services] TO [public]
GO
