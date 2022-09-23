CREATE TABLE [dbo].[serviceexceptionaudit]
(
[sxn_stp_number] [int] NOT NULL,
[sxn_sequence_number] [int] NOT NULL,
[sxa_sequence_number] [int] NOT NULL IDENTITY(1, 1),
[sxn_mov_number] [int] NOT NULL,
[sxa_change_column] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxa_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sxa_dttm] [datetime] NOT NULL,
[sxa_old_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sxa_new_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[serviceexceptionaudit] ADD CONSTRAINT [pk_serviceexceptionaudit] PRIMARY KEY CLUSTERED ([sxn_stp_number], [sxn_sequence_number], [sxa_sequence_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_serviceexceptionaudit] ON [dbo].[serviceexceptionaudit] ([sxn_mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[serviceexceptionaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[serviceexceptionaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[serviceexceptionaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[serviceexceptionaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[serviceexceptionaudit] TO [public]
GO
