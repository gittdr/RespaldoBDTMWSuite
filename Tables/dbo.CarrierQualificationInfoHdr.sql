CREATE TABLE [dbo].[CarrierQualificationInfoHdr]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[FeatureName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__CarrierQu__lastu__1B3E6D2E] DEFAULT (getdate()),
[lastupdateuser] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CarrierQu__lastu__1C329167] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierQualificationInfoHdr] ADD CONSTRAINT [pk_CarrierQualificationInfoHdr] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_CarrierQualificationInfoHdr_FeatureName] ON [dbo].[CarrierQualificationInfoHdr] ([FeatureName]) INCLUDE ([id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierQualificationInfoHdr] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierQualificationInfoHdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierQualificationInfoHdr] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierQualificationInfoHdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierQualificationInfoHdr] TO [public]
GO
