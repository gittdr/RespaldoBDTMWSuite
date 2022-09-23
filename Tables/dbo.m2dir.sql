CREATE TABLE [dbo].[m2dir]
(
[m2dirid] [int] NOT NULL,
[m2dirset] [smallint] NULL,
[m2dirseq] [smallint] NULL,
[m2dirunit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2dirtext] [varchar] (79) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2dirtxtty] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2direrror] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2dirid] ON [dbo].[m2dir] ([m2dirid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2dir] TO [public]
GO
GRANT INSERT ON  [dbo].[m2dir] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2dir] TO [public]
GO
GRANT SELECT ON  [dbo].[m2dir] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2dir] TO [public]
GO
