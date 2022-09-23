CREATE TABLE [dbo].[MR_GeneralInfoMultiLevel]
(
[giml_key] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[giml_user] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[giml_report] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[giml_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_GeneralInfoMultiLevel] ADD CONSTRAINT [PK_MR_GeneralInfoReportOrUser] PRIMARY KEY CLUSTERED ([giml_key], [giml_user], [giml_report]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_GeneralInfoMultiLevel] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_GeneralInfoMultiLevel] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_GeneralInfoMultiLevel] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_GeneralInfoMultiLevel] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_GeneralInfoMultiLevel] TO [public]
GO
