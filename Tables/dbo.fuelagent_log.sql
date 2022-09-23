CREATE TABLE [dbo].[fuelagent_log]
(
[fal_id] [int] NOT NULL IDENTITY(1, 1),
[gf_request_id] [int] NULL,
[gf_lgh_number] [int] NOT NULL,
[fal_type] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fal_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fal_updatedby] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fal_time] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelagent_log] ADD CONSTRAINT [pk_fuelagent_log_id] PRIMARY KEY NONCLUSTERED ([fal_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelagent_log] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelagent_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelagent_log] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelagent_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelagent_log] TO [public]
GO
