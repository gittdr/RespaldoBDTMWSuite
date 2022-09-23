CREATE TABLE [dbo].[tempnotes]
(
[toh_ordernumber] [int] NOT NULL,
[ts_sequence] [int] NULL,
[tc_sequence] [int] NULL,
[tn_notesequence] [int] NULL,
[tn_note] [char] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[toh_tstampq] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tempnotes] TO [public]
GO
GRANT INSERT ON  [dbo].[tempnotes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tempnotes] TO [public]
GO
GRANT SELECT ON  [dbo].[tempnotes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tempnotes] TO [public]
GO
