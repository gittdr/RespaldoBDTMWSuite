CREATE TABLE [dbo].[d83_sect6]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[d83_id] [int] NULL,
[LowZip] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LowZipRange] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HighZip] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Factor] [int] NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[d83_sect6] ADD CONSTRAINT [PK__d83_sect__3213E83F0369B8A9] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [d83_sect6_zip] ON [dbo].[d83_sect6] ([d83_id], [LowZip], [LowZipRange]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[d83_sect6] TO [public]
GO
GRANT INSERT ON  [dbo].[d83_sect6] TO [public]
GO
GRANT REFERENCES ON  [dbo].[d83_sect6] TO [public]
GO
GRANT SELECT ON  [dbo].[d83_sect6] TO [public]
GO
GRANT UPDATE ON  [dbo].[d83_sect6] TO [public]
GO
