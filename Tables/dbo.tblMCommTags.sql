CREATE TABLE [dbo].[tblMCommTags]
(
[SelectedMCommSN] [int] NOT NULL,
[MCommFieldIdx] [int] NOT NULL CONSTRAINT [DF__tblMCommT__MComm__51300E55] DEFAULT (0),
[Tag] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMCommTags] ADD CONSTRAINT [PK__tblMCommTags__2714AD2B] PRIMARY KEY CLUSTERED ([SelectedMCommSN], [MCommFieldIdx]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblMCommTags] TO [public]
GO
GRANT INSERT ON  [dbo].[tblMCommTags] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblMCommTags] TO [public]
GO
GRANT SELECT ON  [dbo].[tblMCommTags] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblMCommTags] TO [public]
GO
