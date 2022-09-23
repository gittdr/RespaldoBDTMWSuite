CREATE TABLE [dbo].[tblT2Configurations]
(
[cnf_SN] [int] NOT NULL IDENTITY(1, 1),
[cnf_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cnf_UpdateOn] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblT2Configurations] ADD CONSTRAINT [PK_tblT2Configurations] PRIMARY KEY CLUSTERED ([cnf_SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblT2Configurations] TO [public]
GO
GRANT INSERT ON  [dbo].[tblT2Configurations] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblT2Configurations] TO [public]
GO
GRANT SELECT ON  [dbo].[tblT2Configurations] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblT2Configurations] TO [public]
GO
