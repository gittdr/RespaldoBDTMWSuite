CREATE TABLE [dbo].[tblUnitType]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayWidthVisible] [int] NULL,
[DisplayWidthLogical] [int] NULL,
[DisplayHeightVisible] [int] NULL,
[DisplayHeightLogical] [int] NULL,
[BackColor] [int] NULL,
[ForeColor] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUnitType] ADD CONSTRAINT [PK_tblUnitType_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[tblUnitType_Description_D]', N'[dbo].[tblUnitType].[Description]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[DisplayWidthVisible]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[DisplayWidthLogical]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[DisplayHeightVisible]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[DisplayHeightLogical]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[BackColor]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblUnitType].[ForeColor]'
GO
GRANT DELETE ON  [dbo].[tblUnitType] TO [public]
GO
GRANT INSERT ON  [dbo].[tblUnitType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblUnitType] TO [public]
GO
GRANT SELECT ON  [dbo].[tblUnitType] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblUnitType] TO [public]
GO
