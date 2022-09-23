CREATE TABLE [dbo].[message_table]
(
[mes_number] [int] NOT NULL,
[mes_sequence] [int] NOT NULL,
[mes_idtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mes_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mes_message] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mes_fromtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mes_from] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[mes_status] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mes_type] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mes_datetime] [datetime] NULL,
[mes_priority] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [ck_id] ON [dbo].[message_table] ([mes_idtype], [mes_id], [mes_status]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_mes] ON [dbo].[message_table] ([mes_number], [mes_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[message_table] TO [public]
GO
GRANT INSERT ON  [dbo].[message_table] TO [public]
GO
GRANT REFERENCES ON  [dbo].[message_table] TO [public]
GO
GRANT SELECT ON  [dbo].[message_table] TO [public]
GO
GRANT UPDATE ON  [dbo].[message_table] TO [public]
GO
