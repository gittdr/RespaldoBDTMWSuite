CREATE TABLE [dbo].[tblAttachmentData_archive]
(
[SN] [int] NOT NULL,
[Data] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Filename] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachmentData_archive] ADD CONSTRAINT [PK_tblAttachmentData_archive] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
