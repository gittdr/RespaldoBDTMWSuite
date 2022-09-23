CREATE TABLE [dbo].[m2ref]
(
[m2refid] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[m2refname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refaddr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refaddr2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refcity] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refstate] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refzip] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refphone] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reffreq] [int] NULL,
[m2refstat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refmsg] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refnotes] [varchar] (512) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refcrtdt] [datetime] NULL,
[m2refcrtpg] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refcrtus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refchgdt] [datetime] NULL,
[m2refchgpg] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2refchgus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2refid] ON [dbo].[m2ref] ([m2refid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2ref] TO [public]
GO
GRANT INSERT ON  [dbo].[m2ref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2ref] TO [public]
GO
GRANT SELECT ON  [dbo].[m2ref] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2ref] TO [public]
GO
