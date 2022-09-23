CREATE TABLE [dbo].[transcore_codes]
(
[tcc_id] [int] NOT NULL IDENTITY(1, 1),
[tcc_abbr] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tcc_name] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tcc_labeltype] [int] NULL,
[tcc_labelvalue] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transcore_codes] ADD CONSTRAINT [pk_transcore_codes] PRIMARY KEY CLUSTERED ([tcc_abbr]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transcore_codes] TO [public]
GO
GRANT INSERT ON  [dbo].[transcore_codes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[transcore_codes] TO [public]
GO
GRANT SELECT ON  [dbo].[transcore_codes] TO [public]
GO
GRANT UPDATE ON  [dbo].[transcore_codes] TO [public]
GO
