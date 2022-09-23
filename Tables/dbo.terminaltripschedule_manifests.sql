CREATE TABLE [dbo].[terminaltripschedule_manifests]
(
[schedule_id] [int] NOT NULL,
[manifest_seq] [int] NOT NULL,
[origin_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dest_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[default_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaltripschedule_manifests] ADD CONSTRAINT [PK__terminal__C3C59F4E81287CC3] PRIMARY KEY CLUSTERED ([schedule_id], [manifest_seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltripschedule_manifests] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltripschedule_manifests] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltripschedule_manifests] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltripschedule_manifests] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltripschedule_manifests] TO [public]
GO
