CREATE TABLE [dbo].[m2msgqdtl]
(
[m2qdid] [int] NOT NULL,
[m2qdkey] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[m2qdcrtpgm] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2qdvalue] [varchar] (3800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2qdid] ON [dbo].[m2msgqdtl] ([m2qdid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2msgqdtl] TO [public]
GO
GRANT INSERT ON  [dbo].[m2msgqdtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2msgqdtl] TO [public]
GO
GRANT SELECT ON  [dbo].[m2msgqdtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2msgqdtl] TO [public]
GO
