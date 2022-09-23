CREATE TABLE [dbo].[ActiveWorkCycleInstances]
(
[awci_id] [int] NOT NULL IDENTITY(1, 1),
[awci_ip] [varchar] (90) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[awci_instance] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[awci_dedicated_workflow] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActiveWorkCycleInstances] ADD CONSTRAINT [PK__ActiveWo__00C268E6FAE2739A] PRIMARY KEY CLUSTERED ([awci_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ActiveWorkCycleInstances] TO [public]
GO
GRANT INSERT ON  [dbo].[ActiveWorkCycleInstances] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ActiveWorkCycleInstances] TO [public]
GO
GRANT SELECT ON  [dbo].[ActiveWorkCycleInstances] TO [public]
GO
GRANT UPDATE ON  [dbo].[ActiveWorkCycleInstances] TO [public]
GO
