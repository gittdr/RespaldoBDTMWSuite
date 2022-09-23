CREATE TABLE [dbo].[TimeDetailExternalRecordKeys]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TimeDetailId] [int] NOT NULL,
[ExternalRecordKey] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeDetailExternalRecordKeys] ADD CONSTRAINT [FK_TimeDetailExternalRecordKeys_TimeDetails] FOREIGN KEY ([TimeDetailId]) REFERENCES [dbo].[TimeDetails] ([TimeDetailId])
GO
GRANT DELETE ON  [dbo].[TimeDetailExternalRecordKeys] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeDetailExternalRecordKeys] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeDetailExternalRecordKeys] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeDetailExternalRecordKeys] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeDetailExternalRecordKeys] TO [public]
GO
