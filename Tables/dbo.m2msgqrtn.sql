CREATE TABLE [dbo].[m2msgqrtn]
(
[m2rqid] [int] NOT NULL,
[m2rqtype] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[m2rqcrtdte] [datetime] NULL,
[m2rquserid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2rqsubjct] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2rqtext] [varchar] (3800) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2rqstatus] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2rqid] ON [dbo].[m2msgqrtn] ([m2rqid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2msgqrtn] TO [public]
GO
GRANT INSERT ON  [dbo].[m2msgqrtn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2msgqrtn] TO [public]
GO
GRANT SELECT ON  [dbo].[m2msgqrtn] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2msgqrtn] TO [public]
GO
