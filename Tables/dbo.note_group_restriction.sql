CREATE TABLE [dbo].[note_group_restriction]
(
[note_grp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_rest_grp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[note_group_restriction] ADD CONSTRAINT [pk_note_group_rest_note_grp_id] PRIMARY KEY CLUSTERED ([note_grp_id], [note_rest_grp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[note_group_restriction] TO [public]
GO
GRANT INSERT ON  [dbo].[note_group_restriction] TO [public]
GO
GRANT REFERENCES ON  [dbo].[note_group_restriction] TO [public]
GO
GRANT SELECT ON  [dbo].[note_group_restriction] TO [public]
GO
GRANT UPDATE ON  [dbo].[note_group_restriction] TO [public]
GO
