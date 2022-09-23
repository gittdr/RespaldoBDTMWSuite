CREATE TABLE [dbo].[notesiconruleslabels]
(
[nrl_id] [int] NOT NULL IDENTITY(1, 1),
[nrl_labeldefinition] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nrl_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nrl_nir_id] [int] NULL,
[nrl_created_date] [datetime] NULL,
[nrl_created_user] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notesiconruleslabels] ADD CONSTRAINT [PK_notesiconruleslabels] PRIMARY KEY CLUSTERED ([nrl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notesiconruleslabels] TO [public]
GO
GRANT INSERT ON  [dbo].[notesiconruleslabels] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notesiconruleslabels] TO [public]
GO
GRANT SELECT ON  [dbo].[notesiconruleslabels] TO [public]
GO
GRANT UPDATE ON  [dbo].[notesiconruleslabels] TO [public]
GO
