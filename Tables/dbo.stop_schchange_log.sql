CREATE TABLE [dbo].[stop_schchange_log]
(
[stp_number] [int] NOT NULL,
[ssl_id] [int] NOT NULL IDENTITY(1, 1),
[ssl_old_early] [datetime] NOT NULL,
[ssl_old_late] [datetime] NOT NULL,
[ssl_new_early] [datetime] NOT NULL,
[ssl_new_late] [datetime] NOT NULL,
[ssl_updatedby] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ssl_updatedon] [datetime] NOT NULL,
[rsn_id] [int] NOT NULL,
[ssl_text1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ssl_text2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [inx_schchange] ON [dbo].[stop_schchange_log] ([ssl_id], [stp_number], [rsn_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stop_schchange_log] TO [public]
GO
GRANT INSERT ON  [dbo].[stop_schchange_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stop_schchange_log] TO [public]
GO
GRANT SELECT ON  [dbo].[stop_schchange_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[stop_schchange_log] TO [public]
GO
