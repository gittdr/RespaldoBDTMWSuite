CREATE TABLE [dbo].[CrmRevenueUserRelationship]
(
[cru_id] [int] NOT NULL IDENTITY(1, 1),
[cru_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cru_value] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cru_user] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrmRevenueUserRelationship] ADD CONSTRAINT [pk_crmrevenueuserrelationship] PRIMARY KEY CLUSTERED ([cru_type], [cru_value], [cru_user]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CrmRevenueUserRelationship] TO [public]
GO
GRANT INSERT ON  [dbo].[CrmRevenueUserRelationship] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CrmRevenueUserRelationship] TO [public]
GO
GRANT SELECT ON  [dbo].[CrmRevenueUserRelationship] TO [public]
GO
GRANT UPDATE ON  [dbo].[CrmRevenueUserRelationship] TO [public]
GO
