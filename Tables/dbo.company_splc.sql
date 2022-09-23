CREATE TABLE [dbo].[company_splc]
(
[cst_id] [int] NOT NULL IDENTITY(1, 1),
[cst_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_splc] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_splc_sub] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_splc] ADD CONSTRAINT [company_splc_id] PRIMARY KEY CLUSTERED ([cst_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_splc] ADD CONSTRAINT [company_splc_cmp_id] UNIQUE NONCLUSTERED ([cst_cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_splc] TO [public]
GO
GRANT INSERT ON  [dbo].[company_splc] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_splc] TO [public]
GO
GRANT SELECT ON  [dbo].[company_splc] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_splc] TO [public]
GO
