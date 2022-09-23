CREATE TABLE [dbo].[NoTouchSettlementDateType]
(
[ntsDateTypeId] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retired] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchSettlementDateType] ADD CONSTRAINT [PK_NoTouchSettlementDateType] PRIMARY KEY CLUSTERED ([ntsDateTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NoTouchSettlementDateType] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchSettlementDateType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchSettlementDateType] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchSettlementDateType] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchSettlementDateType] TO [public]
GO
