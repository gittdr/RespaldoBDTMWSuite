CREATE TABLE [dbo].[pur_legheader_list]
(
[lgh_number] [int] NULL,
[pur_id] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_legheader_list_lgh_number] ON [dbo].[pur_legheader_list] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pur_legheader_list_pur_id] ON [dbo].[pur_legheader_list] ([pur_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pur_legheader_list] TO [public]
GO
GRANT INSERT ON  [dbo].[pur_legheader_list] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pur_legheader_list] TO [public]
GO
GRANT SELECT ON  [dbo].[pur_legheader_list] TO [public]
GO
GRANT UPDATE ON  [dbo].[pur_legheader_list] TO [public]
GO
