CREATE TABLE [dbo].[RMXML_EquipmentType]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[TmwXmlImportLog_id] [int] NULL,
[RootElementID] [int] NULL,
[ParentLevel] [int] NULL,
[CurrentLevel] [int] NULL,
[EquipmentTypeDescrip] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EquipmentTypeCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EquipmentTypeCount] [int] NULL,
[EquipmentTypeAddedDate] [datetime] NULL,
[Tmw_SynchStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__RMXML_Equ__lastu__3C9F60F9] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RMXML_Equ__lastu__3D938532] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RMXML_EquipmentType] TO [public]
GO
GRANT INSERT ON  [dbo].[RMXML_EquipmentType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RMXML_EquipmentType] TO [public]
GO
GRANT SELECT ON  [dbo].[RMXML_EquipmentType] TO [public]
GO
GRANT UPDATE ON  [dbo].[RMXML_EquipmentType] TO [public]
GO
