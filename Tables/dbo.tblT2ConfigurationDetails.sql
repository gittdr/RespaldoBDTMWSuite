CREATE TABLE [dbo].[tblT2ConfigurationDetails]
(
[cfd_SN] [int] NOT NULL IDENTITY(1, 1),
[cnf_SN] [int] NOT NULL,
[cfd_Code] [int] NOT NULL,
[cfd_state] [int] NOT NULL,
[cfd_Value] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblT2ConfigurationDetails] ADD CONSTRAINT [PK_tblT2ConfigurationDetails] PRIMARY KEY CLUSTERED ([cfd_SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblT2ConfigurationDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[tblT2ConfigurationDetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblT2ConfigurationDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[tblT2ConfigurationDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblT2ConfigurationDetails] TO [public]
GO
