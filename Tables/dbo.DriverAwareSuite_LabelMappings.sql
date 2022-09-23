CREATE TABLE [dbo].[DriverAwareSuite_LabelMappings]
(
[Parameter_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pres_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Label_Definition] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LabelAbbr] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultControl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListIfListOrComboBox] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sort_Order] [int] NULL,
[TableLookUp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUpCodeColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUpDescColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUpRestrictColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverAwareSuite_LabelMappings] ADD CONSTRAINT [PK_DriverAwareSuite] PRIMARY KEY CLUSTERED ([Parameter_Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverAwareSuite_LabelMappings] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverAwareSuite_LabelMappings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverAwareSuite_LabelMappings] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverAwareSuite_LabelMappings] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverAwareSuite_LabelMappings] TO [public]
GO
