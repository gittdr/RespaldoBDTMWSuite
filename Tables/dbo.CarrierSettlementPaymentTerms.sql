CREATE TABLE [dbo].[CarrierSettlementPaymentTerms]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[csptbt_id] [int] NOT NULL,
[termCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[enabled] [bit] NULL,
[isDefault] [bit] NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CarrierSettlementPaymentTerms_termCode] ON [dbo].[CarrierSettlementPaymentTerms] ([termCode]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierSettlementPaymentTerms] ADD CONSTRAINT [fk_CarrierSettlementPaymentTerms_csptbt_id] FOREIGN KEY ([csptbt_id]) REFERENCES [dbo].[CarrierSettlementPaymentTerms_BillTo] ([id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[CarrierSettlementPaymentTerms] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierSettlementPaymentTerms] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierSettlementPaymentTerms] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierSettlementPaymentTerms] TO [public]
GO
