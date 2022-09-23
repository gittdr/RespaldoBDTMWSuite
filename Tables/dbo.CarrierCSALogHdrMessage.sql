CREATE TABLE [dbo].[CarrierCSALogHdrMessage]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[CarrierCSALogHdr_id] [int] NOT NULL,
[Message] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__CarrierCS__lastu__5D1390C2] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierCS__lastu__5E07B4FB] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCSALogHdrMessage] ADD CONSTRAINT [pk_CarrierCSALogHdrMessage] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSALogHdrMessage_CarrierCSALogHdr_id] ON [dbo].[CarrierCSALogHdrMessage] ([CarrierCSALogHdr_id]) INCLUDE ([Message]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierCSALogHdrMessage] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierCSALogHdrMessage] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierCSALogHdrMessage] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierCSALogHdrMessage] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierCSALogHdrMessage] TO [public]
GO
