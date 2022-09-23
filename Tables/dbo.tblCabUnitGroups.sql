CREATE TABLE [dbo].[tblCabUnitGroups]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[GroupCabSN] [int] NOT NULL,
[MemberCabSN] [int] NOT NULL,
[Changed] [int] NULL CONSTRAINT [DF__tblcabuni__Chang__4B7734FF] DEFAULT (0),
[Deleted] [int] NULL CONSTRAINT [DF__tblcabuni__Delet__4C6B5938] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCabUnitGroups] ADD CONSTRAINT [PK__tblCabUnitGroups__252C64B9] PRIMARY KEY CLUSTERED ([SN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblCabUnitGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[tblCabUnitGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblCabUnitGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[tblCabUnitGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblCabUnitGroups] TO [public]
GO
