CREATE TABLE [dbo].[tariffcompaniesheader]
(
[tch_id] [int] NOT NULL,
[tch_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tch_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[tch_stopexcludeflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffcompaniesheader] ADD CONSTRAINT [PK_tariffcompanies] PRIMARY KEY CLUSTERED ([tch_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffcompaniesheader] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffcompaniesheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffcompaniesheader] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffcompaniesheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffcompaniesheader] TO [public]
GO
