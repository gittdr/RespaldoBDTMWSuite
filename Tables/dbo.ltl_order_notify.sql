CREATE TABLE [dbo].[ltl_order_notify]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evt_number] [int] NULL,
[status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[statusts] [datetime] NULL,
[email_affiliation] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_order_notify] ADD CONSTRAINT [PK__ltl_orde__3213E83F73D4BBAF] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ltl_order_notify_order] ON [dbo].[ltl_order_notify] ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_order_notify] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_order_notify] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_order_notify] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_order_notify] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_order_notify] TO [public]
GO
