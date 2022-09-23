CREATE TABLE [dbo].[CarrierCSALogDtl]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[CarrierCSALogHdr_id] [int] NOT NULL,
[docket] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[comments] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NOT NULL CONSTRAINT [DF__CarrierCS__lastu__584EDBA5] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__CarrierCS__lastu__5942FFDE] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCSALogDtl] ADD CONSTRAINT [pk_CarrierCSALogDtl] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSALogDtl_CarrierCSALogHdr_id] ON [dbo].[CarrierCSALogDtl] ([CarrierCSALogHdr_id]) INCLUDE ([docket], [comments]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierCSALogDtl_docket] ON [dbo].[CarrierCSALogDtl] ([docket]) INCLUDE ([CarrierCSALogHdr_id], [comments]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCSALogDtl] ADD CONSTRAINT [fk_CarrierCSALogDtl_CarrierCSALogHdr_id] FOREIGN KEY ([CarrierCSALogHdr_id]) REFERENCES [dbo].[CarrierCSALogHdr] ([id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[CarrierCSALogDtl] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierCSALogDtl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierCSALogDtl] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierCSALogDtl] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierCSALogDtl] TO [public]
GO
