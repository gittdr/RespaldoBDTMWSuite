CREATE TABLE [dbo].[tblAttachments]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Message] [int] NULL,
[InsertionPt] [int] NULL,
[DataSN] [int] NULL,
[InLine] [bit] NOT NULL,
[Path] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachments] ADD CONSTRAINT [pk_tblAttachments] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachments] ADD CONSTRAINT [FK__Temporary__Messa__1E4F88CD] FOREIGN KEY ([Message]) REFERENCES [dbo].[tblMessages] ([SN])
GO
