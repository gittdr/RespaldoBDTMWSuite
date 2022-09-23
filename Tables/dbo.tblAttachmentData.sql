CREATE TABLE [dbo].[tblAttachmentData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Data] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Filename] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ts] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAttachmentData] ADD CONSTRAINT [PK_tblAttachmentData_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblAttachmentData] TO [public]
GO
GRANT INSERT ON  [dbo].[tblAttachmentData] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblAttachmentData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblAttachmentData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblAttachmentData] TO [public]
GO
