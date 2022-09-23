CREATE TABLE [dbo].[note_note_type_permits]
(
[note_grp_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_note_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[note_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[note_note_type_permits] ADD CONSTRAINT [pk_note_note_type_permits_grp] PRIMARY KEY CLUSTERED ([note_grp_id], [note_note_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[note_note_type_permits] TO [public]
GO
GRANT INSERT ON  [dbo].[note_note_type_permits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[note_note_type_permits] TO [public]
GO
GRANT SELECT ON  [dbo].[note_note_type_permits] TO [public]
GO
GRANT UPDATE ON  [dbo].[note_note_type_permits] TO [public]
GO
