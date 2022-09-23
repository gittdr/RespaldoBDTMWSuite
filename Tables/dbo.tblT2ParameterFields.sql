CREATE TABLE [dbo].[tblT2ParameterFields]
(
[pfd_SN] [int] NOT NULL IDENTITY(1, 1),
[evt_sn] [int] NOT NULL,
[pfd_Number] [int] NOT NULL,
[pfd_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_Identifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_StartPos] [int] NOT NULL,
[pfd_Length] [int] NOT NULL,
[pfd_MinValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_MaxValue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_Binary] [int] NULL,
[pfd_Field_Offset] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pfd_Length_Field_Number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblT2ParameterFields] ADD CONSTRAINT [PK_tblT2ParameterFields] PRIMARY KEY CLUSTERED ([pfd_SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblT2ParameterFields_Identifier] ON [dbo].[tblT2ParameterFields] ([pfd_Identifier]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblT2ParameterFields] ON [dbo].[tblT2ParameterFields] ([pfd_Number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblT2ParameterFields] TO [public]
GO
GRANT INSERT ON  [dbo].[tblT2ParameterFields] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblT2ParameterFields] TO [public]
GO
GRANT SELECT ON  [dbo].[tblT2ParameterFields] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblT2ParameterFields] TO [public]
GO
