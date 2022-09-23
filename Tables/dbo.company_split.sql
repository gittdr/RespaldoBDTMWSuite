CREATE TABLE [dbo].[company_split]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_splitid] [tinyint] NOT NULL,
[cmp_split] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_split_cmp_split] DEFAULT ('N'),
[cmp_transfer] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_split_cmp_transfer] DEFAULT ('N'),
[cmp_splitlocation] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_split_cmp_splitlocation] DEFAULT ('UNKNOWN'),
[cmp_lowweight] [float] NOT NULL CONSTRAINT [DF_company_split_cmp_lowweight] DEFAULT (0),
[cmp_highweight] [float] NOT NULL CONSTRAINT [DF_company_split_cmp_highweight] DEFAULT (0),
[cmp_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_company_split_cmp_weightunit] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_split] ADD CONSTRAINT [PK_company_split] PRIMARY KEY CLUSTERED ([cmp_id], [cmp_splitid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_split] TO [public]
GO
GRANT INSERT ON  [dbo].[company_split] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_split] TO [public]
GO
GRANT SELECT ON  [dbo].[company_split] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_split] TO [public]
GO
