CREATE TABLE [dbo].[pur_inv_list]
(
[ivh_hdrnumber] [int] NULL,
[pur_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_inv_list_ivh_hdrnumber] ON [dbo].[pur_inv_list] ([ivh_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_inv_list_pur_id] ON [dbo].[pur_inv_list] ([pur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pur_inv_list] TO [public]
GO
GRANT INSERT ON  [dbo].[pur_inv_list] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pur_inv_list] TO [public]
GO
GRANT SELECT ON  [dbo].[pur_inv_list] TO [public]
GO
GRANT UPDATE ON  [dbo].[pur_inv_list] TO [public]
GO
