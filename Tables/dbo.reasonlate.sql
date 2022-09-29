CREATE TABLE [dbo].[reasonlate]
(
[rlt_id] [int] NOT NULL IDENTITY(1, 1),
[rlt_stp_number] [int] NULL,
[rlt_arv_dep] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rlt_arv_dep_seq] [int] NULL,
[rlt_reasonlate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rlt_reasonlate_text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rlt_reasonlate_min] [int] NULL,
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__reasonlat__INS_T__6C58C786] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reasonlate] ADD CONSTRAINT [pk_reasonlate] PRIMARY KEY CLUSTERED ([rlt_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [reasonlate_INS_TIMESTAMP] ON [dbo].[reasonlate] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_reasonlate] ON [dbo].[reasonlate] ([rlt_stp_number], [rlt_arv_dep]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reasonlate] TO [public]
GO
GRANT INSERT ON  [dbo].[reasonlate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reasonlate] TO [public]
GO
GRANT SELECT ON  [dbo].[reasonlate] TO [public]
GO
GRANT UPDATE ON  [dbo].[reasonlate] TO [public]
GO
