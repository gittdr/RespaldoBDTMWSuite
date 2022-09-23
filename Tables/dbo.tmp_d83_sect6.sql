CREATE TABLE [dbo].[tmp_d83_sect6]
(
[LowZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LowZipRange] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HighZip] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factor] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmp_d83_sect6] TO [public]
GO
GRANT INSERT ON  [dbo].[tmp_d83_sect6] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmp_d83_sect6] TO [public]
GO
GRANT SELECT ON  [dbo].[tmp_d83_sect6] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmp_d83_sect6] TO [public]
GO
