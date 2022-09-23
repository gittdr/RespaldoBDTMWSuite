CREATE TABLE [dbo].[edi_sched_event]
(
[edi_sched_event_id] [float] NOT NULL,
[edi_sched_id] [float] NOT NULL,
[edi_task_id] [float] NOT NULL,
[edi_sched_event_seq] [float] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_sched_event] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_sched_event] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_sched_event] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_sched_event] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_sched_event] TO [public]
GO
