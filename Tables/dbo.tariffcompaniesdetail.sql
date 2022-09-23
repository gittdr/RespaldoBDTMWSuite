CREATE TABLE [dbo].[tariffcompaniesdetail]
(
[tch_id] [int] NOT NULL,
[tcd_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffcompaniesdetail] ADD CONSTRAINT [PK_tariffcompaniesdetail] PRIMARY KEY CLUSTERED ([tch_id], [tcd_cmp_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffcompaniesdetail] ADD CONSTRAINT [FK_tariffcompaniesdetail_tariffcompaniesheader] FOREIGN KEY ([tch_id]) REFERENCES [dbo].[tariffcompaniesheader] ([tch_id])
GO
GRANT DELETE ON  [dbo].[tariffcompaniesdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffcompaniesdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffcompaniesdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffcompaniesdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffcompaniesdetail] TO [public]
GO
