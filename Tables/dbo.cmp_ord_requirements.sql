CREATE TABLE [dbo].[cmp_ord_requirements]
(
[cor_id] [int] NOT NULL,
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[req_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cor_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_seq] [int] NULL,
[cor_stopseq] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_stoptype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_stopstatusfield] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_stopstatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_totalby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_min_qty] [decimal] (19, 4) NULL,
[cor_max_qty] [decimal] (19, 4) NULL,
[cor_createdby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_createdon] [datetime] NULL,
[cor_updatedby] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cor_updatedon] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmp_ord_requirements] TO [public]
GO
GRANT INSERT ON  [dbo].[cmp_ord_requirements] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmp_ord_requirements] TO [public]
GO
GRANT SELECT ON  [dbo].[cmp_ord_requirements] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmp_ord_requirements] TO [public]
GO
