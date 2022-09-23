CREATE TABLE [dbo].[CarrierSettlementPaymentTerms_BillTo]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[billto_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierSettlementPaymentTerms_BillTo] ADD CONSTRAINT [pk_CarrierSettlementPaymentTerms_BillTo] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [CarrierSettlementPaymentTerms_BillTo_car_id_billto_id] ON [dbo].[CarrierSettlementPaymentTerms_BillTo] ([car_id], [billto_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierSettlementPaymentTerms_BillTo] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierSettlementPaymentTerms_BillTo] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierSettlementPaymentTerms_BillTo] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierSettlementPaymentTerms_BillTo] TO [public]
GO
