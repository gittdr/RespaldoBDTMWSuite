CREATE TABLE [dbo].[CarrierCSALogHdr]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[ProviderName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__CarrierCS__lastu__547E4AC1] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierCS__lastu__55726EFA] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCSALogHdr] ADD CONSTRAINT [pk_CarrierCSALogHdr] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSALogHdr_ProviderName] ON [dbo].[CarrierCSALogHdr] ([ProviderName]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierCSALogHdr] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierCSALogHdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierCSALogHdr] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierCSALogHdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierCSALogHdr] TO [public]
GO
