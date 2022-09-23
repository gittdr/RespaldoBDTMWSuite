CREATE TABLE [dbo].[MANHATTAN_WorkQueue]
(
[mwq_id] [int] NOT NULL IDENTITY(1, 1),
[mwq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mov_number] [int] NULL,
[trc_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadrequirement_id] [int] NULL,
[mwq_source] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mwq_updatedate] [datetime] NOT NULL CONSTRAINT [df_mwq_updatedate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MANHATTAN_WorkQueue] ADD CONSTRAINT [pk_MANHATTAN_WorkQueue] PRIMARY KEY CLUSTERED ([mwq_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MANHATTAN_WorkQueue] TO [public]
GO
GRANT INSERT ON  [dbo].[MANHATTAN_WorkQueue] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MANHATTAN_WorkQueue] TO [public]
GO
GRANT SELECT ON  [dbo].[MANHATTAN_WorkQueue] TO [public]
GO
GRANT UPDATE ON  [dbo].[MANHATTAN_WorkQueue] TO [public]
GO
