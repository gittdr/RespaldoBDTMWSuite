CREATE TABLE [dbo].[ttrheader]
(
[ttr_number] [int] NOT NULL,
[ttr_triptypeorregion] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttr_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ttr_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttr_comment] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttr_addon] [datetime] NULL,
[ttr_updateon] [datetime] NULL,
[ttr_updateby] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttr_startdate] [datetime] NULL,
[ttr_enddate] [datetime] NULL,
[ttr_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttr_regiontype] [int] NOT NULL CONSTRAINT [DF_ttrheader_regiontype] DEFAULT (0),
[ttr_tax] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ttr_begin] [int] NULL,
[ttr_pup] [int] NULL,
[ttr_rtpoint] [int] NULL,
[ttr_drop] [int] NULL,
[ttr_end] [int] NULL,
[cmp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowsec_rsrv_id] [int] NULL,
[timestamp] [timestamp] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [k_code] ON [dbo].[ttrheader] ([ttr_code]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ttrnumber] ON [dbo].[ttrheader] ([ttr_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ttrheader] TO [public]
GO
GRANT INSERT ON  [dbo].[ttrheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ttrheader] TO [public]
GO
GRANT SELECT ON  [dbo].[ttrheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[ttrheader] TO [public]
GO
