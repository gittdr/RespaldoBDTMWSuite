CREATE TABLE [dbo].[companydirections]
(
[cdr_cmpid] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdr_sequence] [int] NOT NULL,
[cdr_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cdr_idseq] ON [dbo].[companydirections] ([cdr_cmpid], [cdr_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[companydirections] TO [public]
GO
GRANT INSERT ON  [dbo].[companydirections] TO [public]
GO
GRANT REFERENCES ON  [dbo].[companydirections] TO [public]
GO
GRANT SELECT ON  [dbo].[companydirections] TO [public]
GO
GRANT UPDATE ON  [dbo].[companydirections] TO [public]
GO
