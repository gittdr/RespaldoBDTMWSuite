CREATE TABLE [dbo].[ImageMoveList]
(
[iml_ID] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImageMoveList] ADD CONSTRAINT [PK__ImageMoveList__6009D43F] PRIMARY KEY CLUSTERED ([iml_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_movnumber] ON [dbo].[ImageMoveList] ([mov_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ImageMoveList] TO [public]
GO
GRANT INSERT ON  [dbo].[ImageMoveList] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ImageMoveList] TO [public]
GO
GRANT SELECT ON  [dbo].[ImageMoveList] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImageMoveList] TO [public]
GO
