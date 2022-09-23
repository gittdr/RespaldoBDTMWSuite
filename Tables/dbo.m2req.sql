CREATE TABLE [dbo].[m2req]
(
[m2reqid] [int] NOT NULL,
[m2reqseq] [smallint] NOT NULL,
[m2requnit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[m2reqload] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqtype] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcount] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqexpir] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcrtdt] [datetime] NULL,
[m2reqcrtpg] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqchgdt] [datetime] NULL,
[m2reqchgpg] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcityc] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcitys] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcityn] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcityz] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqplant] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqref] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2cmdtycde] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2reqcmnt] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[m2lat] [decimal] (12, 4) NULL,
[m2long] [decimal] (12, 4) NULL,
[m2subcnfig] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_m2reqid] ON [dbo].[m2req] ([m2reqid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[m2req] TO [public]
GO
GRANT INSERT ON  [dbo].[m2req] TO [public]
GO
GRANT REFERENCES ON  [dbo].[m2req] TO [public]
GO
GRANT SELECT ON  [dbo].[m2req] TO [public]
GO
GRANT UPDATE ON  [dbo].[m2req] TO [public]
GO
