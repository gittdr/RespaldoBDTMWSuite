CREATE TABLE [dbo].[tblT2ParameterValues]
(
[pvs_SN] [int] NOT NULL IDENTITY(1, 1),
[pfd_SN] [int] NOT NULL,
[pvs_Value] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pvs_Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblT2ParameterValues] ADD CONSTRAINT [PK_tblT2ParameterValues] PRIMARY KEY CLUSTERED ([pvs_SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblT2ParameterValues] ON [dbo].[tblT2ParameterValues] ([pfd_SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblT2ParameterValues] TO [public]
GO
GRANT INSERT ON  [dbo].[tblT2ParameterValues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblT2ParameterValues] TO [public]
GO
GRANT SELECT ON  [dbo].[tblT2ParameterValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblT2ParameterValues] TO [public]
GO
