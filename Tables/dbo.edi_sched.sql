CREATE TABLE [dbo].[edi_sched]
(
[edi_sched_id] [float] NOT NULL,
[edi_sched_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_sched_next] [datetime] NULL,
[edi_sched_last] [datetime] NULL,
[edi_sched_start] [datetime] NULL,
[edi_sched_end] [datetime] NULL,
[edi_sched_interval] [float] NOT NULL,
[edi_sched_interval_type] [float] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_sched] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_sched] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_sched] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_sched] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_sched] TO [public]
GO
