CREATE TABLE [dbo].[CustomerEquipment]
(
[ce_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[ce_seqnum] [int] NOT NULL,
[ce_equipnum] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_customerequipment_lgh_number_equip] ON [dbo].[CustomerEquipment] ([lgh_number], [ce_equipnum]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CustomerEquipment] TO [public]
GO
GRANT INSERT ON  [dbo].[CustomerEquipment] TO [public]
GO
GRANT SELECT ON  [dbo].[CustomerEquipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[CustomerEquipment] TO [public]
GO
