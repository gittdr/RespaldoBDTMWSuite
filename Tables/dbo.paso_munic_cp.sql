CREATE TABLE [dbo].[paso_munic_cp]
(
[id_cityexcel] [numeric] (10, 0) NOT NULL,
[nombre] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cp] [numeric] (10, 0) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[paso_munic_cp] ADD CONSTRAINT [pk_idexcelcp] PRIMARY KEY NONCLUSTERED ([id_cityexcel]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[paso_munic_cp] TO [public]
GO
GRANT INSERT ON  [dbo].[paso_munic_cp] TO [public]
GO
GRANT REFERENCES ON  [dbo].[paso_munic_cp] TO [public]
GO
GRANT SELECT ON  [dbo].[paso_munic_cp] TO [public]
GO
GRANT UPDATE ON  [dbo].[paso_munic_cp] TO [public]
GO
