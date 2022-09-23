CREATE TABLE [dbo].[utilization]
(
[util_id] [int] NOT NULL IDENTITY(1, 1),
[lpa_id] [int] NOT NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lgh_number] [int] NOT NULL,
[trc_status] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[util_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[util_start_date] [datetime] NOT NULL,
[util_end_date] [datetime] NULL,
[update_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[utilization] ADD CONSTRAINT [pk_utilization] PRIMARY KEY CLUSTERED ([util_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_util_lgh_number] ON [dbo].[utilization] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_util_trc_number] ON [dbo].[utilization] ([trc_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[utilization] TO [public]
GO
GRANT INSERT ON  [dbo].[utilization] TO [public]
GO
GRANT SELECT ON  [dbo].[utilization] TO [public]
GO
GRANT UPDATE ON  [dbo].[utilization] TO [public]
GO
