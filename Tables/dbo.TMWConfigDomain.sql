CREATE TABLE [dbo].[TMWConfigDomain]
(
[Domain] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PriorityCode] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWConfigDomain] ADD CONSTRAINT [PK_TMWConfigDomain_Domain] PRIMARY KEY CLUSTERED ([Domain]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWConfigDomain] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWConfigDomain] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWConfigDomain] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWConfigDomain] TO [public]
GO
