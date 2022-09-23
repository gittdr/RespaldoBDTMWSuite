CREATE TABLE [dbo].[tempref]
(
[toh_ordernumber] [int] NOT NULL,
[ts_sequence] [tinyint] NULL,
[tr_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tr_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tr_refsequence] [smallint] NULL,
[mov_number] [int] NULL,
[toh_tstampq] [int] NULL,
[tc_sequence] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [tb_k1] ON [dbo].[tempref] ([toh_tstampq], [toh_ordernumber], [ts_sequence], [tc_sequence], [tr_refsequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tempref] TO [public]
GO
GRANT INSERT ON  [dbo].[tempref] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tempref] TO [public]
GO
GRANT SELECT ON  [dbo].[tempref] TO [public]
GO
GRANT UPDATE ON  [dbo].[tempref] TO [public]
GO
