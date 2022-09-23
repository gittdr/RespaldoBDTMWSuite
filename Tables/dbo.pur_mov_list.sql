CREATE TABLE [dbo].[pur_mov_list]
(
[mov_number] [int] NULL,
[pur_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_mov_list_mov_number] ON [dbo].[pur_mov_list] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_mov_list_pur_id] ON [dbo].[pur_mov_list] ([pur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pur_mov_list] TO [public]
GO
GRANT INSERT ON  [dbo].[pur_mov_list] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pur_mov_list] TO [public]
GO
GRANT SELECT ON  [dbo].[pur_mov_list] TO [public]
GO
GRANT UPDATE ON  [dbo].[pur_mov_list] TO [public]
GO
