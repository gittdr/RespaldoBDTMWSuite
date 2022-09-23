CREATE TABLE [dbo].[NoTouchSettlementConfiguration]
(
[nts_id] [int] NOT NULL IDENTITY(1, 1),
[ntsResourceTypeId] [int] NOT NULL,
[ntsSettleTripsPbcId] [int] NOT NULL,
[ntsDateTypeId] [int] NOT NULL,
[ntsCompany] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntsDivision] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntsFleet] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntsTerminal] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntsResourceType1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntsResourceType2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntsResourceType3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntsResourceType4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchSettlementConfiguration] ADD CONSTRAINT [PK_NoTouchSettlementConfiguration] PRIMARY KEY CLUSTERED ([nts_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchSettlementConfiguration] ADD CONSTRAINT [FK_NoTouchSettlementConfiguration_NoTouchSettlementDateType] FOREIGN KEY ([ntsDateTypeId]) REFERENCES [dbo].[NoTouchSettlementDateType] ([ntsDateTypeId])
GO
ALTER TABLE [dbo].[NoTouchSettlementConfiguration] ADD CONSTRAINT [FK_NoTouchSettlementConfiguration_NoTouchSettlementResourceType] FOREIGN KEY ([ntsResourceTypeId]) REFERENCES [dbo].[NoTouchSettlementResourceType] ([ntsResourceTypeId])
GO
GRANT DELETE ON  [dbo].[NoTouchSettlementConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchSettlementConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchSettlementConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchSettlementConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchSettlementConfiguration] TO [public]
GO
