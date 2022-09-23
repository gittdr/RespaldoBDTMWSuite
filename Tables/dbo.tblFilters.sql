CREATE TABLE [dbo].[tblFilters]
(
[flt_SN] [int] NOT NULL IDENTITY(1, 1),
[flt_LoginID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[flt_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flt_CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[flt_Updated] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblFilters] ON [dbo].[tblFilters] ([flt_LoginID], [flt_Name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFilters] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFilters] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFilters] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFilters] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFilters] TO [public]
GO
