CREATE TABLE [dbo].[loadreq_to_paytypes_defset]
(
[ldf_identity] [int] NOT NULL IDENTITY(1, 1),
[ldf_equip_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ldf_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ldf_max_amt] [money] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [pk_ldf_identity] ON [dbo].[loadreq_to_paytypes_defset] ([ldf_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[loadreq_to_paytypes_defset] TO [public]
GO
GRANT INSERT ON  [dbo].[loadreq_to_paytypes_defset] TO [public]
GO
GRANT REFERENCES ON  [dbo].[loadreq_to_paytypes_defset] TO [public]
GO
GRANT SELECT ON  [dbo].[loadreq_to_paytypes_defset] TO [public]
GO
GRANT UPDATE ON  [dbo].[loadreq_to_paytypes_defset] TO [public]
GO
