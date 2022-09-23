CREATE TABLE [dbo].[tblAttachments_Archive]
(
[SN] [int] NOT NULL,
[Message] [int] NULL,
[InsertionPt] [int] NULL,
[DataSN] [int] NULL,
[InLine] [bit] NOT NULL,
[Path] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachments_Archive] ADD CONSTRAINT [PK_tblAttachments_Archive] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
