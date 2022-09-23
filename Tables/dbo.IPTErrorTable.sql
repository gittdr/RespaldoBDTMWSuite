CREATE TABLE [dbo].[IPTErrorTable]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[ipt_number] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[orig_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_text] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[err_date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IPTErrorTable] ADD CONSTRAINT [pk_ipterrortable_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ipterrortable_ipt_number] ON [dbo].[IPTErrorTable] ([ipt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[IPTErrorTable] TO [public]
GO
GRANT INSERT ON  [dbo].[IPTErrorTable] TO [public]
GO
GRANT REFERENCES ON  [dbo].[IPTErrorTable] TO [public]
GO
GRANT SELECT ON  [dbo].[IPTErrorTable] TO [public]
GO
GRANT UPDATE ON  [dbo].[IPTErrorTable] TO [public]
GO
