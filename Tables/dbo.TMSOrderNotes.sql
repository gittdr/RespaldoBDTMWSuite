CREATE TABLE [dbo].[TMSOrderNotes]
(
[NoteId] [int] NOT NULL IDENTITY(1, 1),
[OrderId] [int] NOT NULL,
[Type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Text] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViewLevel] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SentDate] [datetime] NULL,
[ExpirationDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderNotes] ADD CONSTRAINT [PK_TMSOrderNotes] PRIMARY KEY CLUSTERED ([NoteId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSOrderNotes] ADD CONSTRAINT [FK_TMSOrderNotes_TMSOrder] FOREIGN KEY ([OrderId]) REFERENCES [dbo].[TMSOrder] ([OrderId])
GO
GRANT DELETE ON  [dbo].[TMSOrderNotes] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSOrderNotes] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSOrderNotes] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSOrderNotes] TO [public]
GO
