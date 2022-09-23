CREATE TABLE [dbo].[cmpemaillog]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mail_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[maileddate] [datetime] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[stp_number] [int] NULL,
[events] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[message] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_cmpmaillog] ON [dbo].[cmpemaillog] ([cmp_id], [maileddate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cmpemaillog] TO [public]
GO
GRANT INSERT ON  [dbo].[cmpemaillog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cmpemaillog] TO [public]
GO
GRANT SELECT ON  [dbo].[cmpemaillog] TO [public]
GO
GRANT UPDATE ON  [dbo].[cmpemaillog] TO [public]
GO
