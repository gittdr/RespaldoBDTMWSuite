CREATE TABLE [dbo].[TMWReportParameterMappings]
(
[Parameter_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Pres_Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Label_Definition] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultControl] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListIfListOrComboBox] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sort_Order] [int] NULL,
[Required] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Comments] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUp] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUpCodeColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableLookUpDescColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRestriction] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWReportParameterMappings] ADD CONSTRAINT [PK_TMWReportParameterMappings] PRIMARY KEY CLUSTERED ([Parameter_Name]) ON [PRIMARY]
GO
GRANT REFERENCES ON  [dbo].[TMWReportParameterMappings] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWReportParameterMappings] TO [public]
GO
