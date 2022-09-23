CREATE TABLE [dbo].[tblSignatureCaptureImage]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[SCD_SN] [int] NOT NULL,
[imagename] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[signatureimage] [varbinary] (max) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSignatureCaptureImage] ADD CONSTRAINT [PK__tblSigna__32151C64CA5CEEAB] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_NC_SignCapture] ON [dbo].[tblSignatureCaptureImage] ([SCD_SN]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSignatureCaptureImage] ADD CONSTRAINT [FK_SignCaptureData_SC] FOREIGN KEY ([SCD_SN]) REFERENCES [dbo].[tblSignatureCaptureData] ([SN])
GO
GRANT INSERT ON  [dbo].[tblSignatureCaptureImage] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSignatureCaptureImage] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSignatureCaptureImage] TO [public]
GO
