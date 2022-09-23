CREATE TABLE [dbo].[edi_task]
(
[edi_task_id] [float] NOT NULL,
[edi_task_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[edi_task_event] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[edi_task] TO [public]
GO
GRANT INSERT ON  [dbo].[edi_task] TO [public]
GO
GRANT REFERENCES ON  [dbo].[edi_task] TO [public]
GO
GRANT SELECT ON  [dbo].[edi_task] TO [public]
GO
GRANT UPDATE ON  [dbo].[edi_task] TO [public]
GO
