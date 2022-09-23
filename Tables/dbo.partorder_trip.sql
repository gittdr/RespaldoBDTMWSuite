CREATE TABLE [dbo].[partorder_trip]
(
[pot_identity] [int] NOT NULL IDENTITY(1, 1),
[pot_master_ordhdr] [int] NULL,
[pot_ordhdr] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pot_id] ON [dbo].[partorder_trip] ([pot_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pot_mstord] ON [dbo].[partorder_trip] ([pot_master_ordhdr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pot_ord] ON [dbo].[partorder_trip] ([pot_ordhdr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_trip] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_trip] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_trip] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_trip] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_trip] TO [public]
GO
