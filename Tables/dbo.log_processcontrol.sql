CREATE TABLE [dbo].[log_processcontrol]
(
[control_id] [smallint] NOT NULL,
[processes] [smallint] NOT NULL,
[processdatetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [log_processcontrol_idx] ON [dbo].[log_processcontrol] ([control_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[log_processcontrol] TO [public]
GO
GRANT INSERT ON  [dbo].[log_processcontrol] TO [public]
GO
GRANT REFERENCES ON  [dbo].[log_processcontrol] TO [public]
GO
GRANT SELECT ON  [dbo].[log_processcontrol] TO [public]
GO
GRANT UPDATE ON  [dbo].[log_processcontrol] TO [public]
GO
