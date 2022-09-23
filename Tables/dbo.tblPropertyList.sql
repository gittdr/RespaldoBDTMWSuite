CREATE TABLE [dbo].[tblPropertyList]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Range1] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Range2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Editable] [int] NULL,
[MaximumLength] [int] NULL,
[IsUnique] [int] NULL,
[PropType] [int] NULL,
[System] [int] NULL,
[Description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PropCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MultSetsAllowed] [int] NULL,
[ParentSN] [int] NULL,
[IsParent] [int] NULL,
[IsDataDef] [int] NULL,
[DataSequence] [int] NULL,
[ReadOnly] [int] NULL,
[FrmFldValAsFldPropVal] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblPropertyList] ADD CONSTRAINT [PK_tblPropertylist_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_PropList_PropType_Name] ON [dbo].[tblPropertyList] ([PropType], [Name]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxNameMCSNPropType] ON [dbo].[tblPropertyList] ([SN], [Name], [PropType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblPropertyList] TO [public]
GO
GRANT INSERT ON  [dbo].[tblPropertyList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblPropertyList] TO [public]
GO
GRANT SELECT ON  [dbo].[tblPropertyList] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblPropertyList] TO [public]
GO
