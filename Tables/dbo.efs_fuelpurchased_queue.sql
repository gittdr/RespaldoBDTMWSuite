CREATE TABLE [dbo].[efs_fuelpurchased_queue]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[status] [int] NOT NULL,
[packet] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dt_added] [datetime] NULL,
[dt_last_updated] [datetime] NULL,
[efs_fp_que_error_message] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[efs_fuelpurchased_queue] ADD CONSTRAINT [pk_efs_fp_queue_id] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_efs_fp_queue_status] ON [dbo].[efs_fuelpurchased_queue] ([status]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[efs_fuelpurchased_queue] TO [public]
GO
GRANT INSERT ON  [dbo].[efs_fuelpurchased_queue] TO [public]
GO
GRANT SELECT ON  [dbo].[efs_fuelpurchased_queue] TO [public]
GO
GRANT UPDATE ON  [dbo].[efs_fuelpurchased_queue] TO [public]
GO
