CREATE TABLE [dbo].[SettlementPaymentTerms]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[termCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[days] [int] NOT NULL,
[rate] [float] NOT NULL,
[termType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[defaultEnabled] [bit] NULL,
[defaultTerm] [bit] NULL,
[retired] [bit] NULL,
[CreatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatedDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SettlementPaymentTerms_retired] ON [dbo].[SettlementPaymentTerms] ([retired]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SettlementPaymentTerms_termCode] ON [dbo].[SettlementPaymentTerms] ([termCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SettlementPaymentTerms] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementPaymentTerms] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementPaymentTerms] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementPaymentTerms] TO [public]
GO
