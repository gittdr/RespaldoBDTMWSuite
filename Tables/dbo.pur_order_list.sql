CREATE TABLE [dbo].[pur_order_list]
(
[ord_hdrnumber] [int] NULL,
[pur_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_order_list_ord_hdrnumber] ON [dbo].[pur_order_list] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_order_list_pur_id] ON [dbo].[pur_order_list] ([pur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pur_order_list] TO [public]
GO
GRANT INSERT ON  [dbo].[pur_order_list] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pur_order_list] TO [public]
GO
GRANT SELECT ON  [dbo].[pur_order_list] TO [public]
GO
GRANT UPDATE ON  [dbo].[pur_order_list] TO [public]
GO
