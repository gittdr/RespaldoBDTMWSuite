CREATE TABLE [dbo].[company_dwelloverride]
(
[enddate] [datetime] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dwellminutes] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_dwelloverride] ADD CONSTRAINT [PK__company_dwellove__4A0F3E65] PRIMARY KEY CLUSTERED ([enddate], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_dwelloverride] TO [public]
GO
GRANT INSERT ON  [dbo].[company_dwelloverride] TO [public]
GO
GRANT SELECT ON  [dbo].[company_dwelloverride] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_dwelloverride] TO [public]
GO
