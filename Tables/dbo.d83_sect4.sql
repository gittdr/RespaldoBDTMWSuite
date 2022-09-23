CREATE TABLE [dbo].[d83_sect4]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[d83_id] [int] NULL,
[LowZip] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HighZip] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factor] [int] NULL,
[rowchgts] [timestamp] NOT NULL,
[LowZipEnd] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[d83_sect4] ADD CONSTRAINT [PK__d83_sect__3213E83FD9FE7604] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d83_sect4_zips] ON [dbo].[d83_sect4] ([d83_id], [LowZip], [LowZipEnd], [HighZip]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[d83_sect4] TO [public]
GO
GRANT INSERT ON  [dbo].[d83_sect4] TO [public]
GO
GRANT REFERENCES ON  [dbo].[d83_sect4] TO [public]
GO
GRANT SELECT ON  [dbo].[d83_sect4] TO [public]
GO
GRANT UPDATE ON  [dbo].[d83_sect4] TO [public]
GO
