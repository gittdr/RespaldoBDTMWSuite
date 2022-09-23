CREATE TABLE [dbo].[trailer_unassign_reasonlog]
(
[autoreason_id] [int] NOT NULL IDENTITY(1, 1),
[trl_number] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trl_unassigned_precode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_unassigned_curcode] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_unassigned_comments] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[updated_date] [datetime] NULL,
[last_updated_by] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_unassign_reasonlog] ADD CONSTRAINT [pk_trailer_unassign_reasonlog] PRIMARY KEY CLUSTERED ([autoreason_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_unassign_reasonlog] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_unassign_reasonlog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailer_unassign_reasonlog] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_unassign_reasonlog] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_unassign_reasonlog] TO [public]
GO
