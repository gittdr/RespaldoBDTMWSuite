CREATE TABLE [dbo].[company_nocontinuitytrl]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_nocontinuitytrl] ADD CONSTRAINT [UX_company_nocontinuitytrl] UNIQUE NONCLUSTERED ([cmp_id], [trl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_nocontinuitytrl] TO [public]
GO
GRANT INSERT ON  [dbo].[company_nocontinuitytrl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_nocontinuitytrl] TO [public]
GO
GRANT SELECT ON  [dbo].[company_nocontinuitytrl] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_nocontinuitytrl] TO [public]
GO
