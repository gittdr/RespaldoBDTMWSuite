CREATE TABLE [dbo].[tmp_d83_sect4]
(
[LowZip] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HighZip] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factor] [int] NULL,
[LowZipEnd] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tmp_d83_sect4] TO [public]
GO
GRANT INSERT ON  [dbo].[tmp_d83_sect4] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tmp_d83_sect4] TO [public]
GO
GRANT SELECT ON  [dbo].[tmp_d83_sect4] TO [public]
GO
GRANT UPDATE ON  [dbo].[tmp_d83_sect4] TO [public]
GO
