CREATE TABLE [dbo].[edireasonlatecode]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rsn_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_rsn_code] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edireasonlatecode] TO [public]
GO
GRANT INSERT ON  [dbo].[edireasonlatecode] TO [public]
GO
GRANT SELECT ON  [dbo].[edireasonlatecode] TO [public]
GO
GRANT UPDATE ON  [dbo].[edireasonlatecode] TO [public]
GO
