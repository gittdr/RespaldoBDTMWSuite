CREATE TABLE [dbo].[NoTouchSettlementResourceType]
(
[ntsResourceTypeId] [int] NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retired] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchSettlementResourceType] ADD CONSTRAINT [PK_NoTouchSettlementResourceType] PRIMARY KEY CLUSTERED ([ntsResourceTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NoTouchSettlementResourceType] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchSettlementResourceType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchSettlementResourceType] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchSettlementResourceType] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchSettlementResourceType] TO [public]
GO
