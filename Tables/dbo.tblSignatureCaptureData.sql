CREATE TABLE [dbo].[tblSignatureCaptureData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[stp_number] [int] NOT NULL,
[msg_SN] [int] NOT NULL,
[signatureid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[signaturename] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retrievecount] [int] NULL CONSTRAINT [DF__tblSignat__retri__41432193] DEFAULT ((0)),
[receiveddate] [datetime] NOT NULL,
[vendor] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSignatureCaptureData] ADD CONSTRAINT [PK__tblSigna__32151C64E3126A22] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_SignCaptureData] ON [dbo].[tblSignatureCaptureData] ([stp_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[tblSignatureCaptureData] TO [public]
GO
GRANT SELECT ON  [dbo].[tblSignatureCaptureData] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblSignatureCaptureData] TO [public]
GO
