CREATE TABLE [dbo].[ImageCompanyRecs]
(
[icr_ID] [int] NOT NULL IDENTITY(1, 1),
[image] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageCompanyRecs] ADD CONSTRAINT [PK__ImageCompanyRecs__69933E79] PRIMARY KEY CLUSTERED ([icr_ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageCompanyRecs] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageCompanyRecs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageCompanyRecs] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageCompanyRecs] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageCompanyRecs] TO [public]
GO
