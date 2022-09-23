CREATE TABLE [dbo].[SettlementOvertimeBackoutType]
(
[BackoutTypeId] [tinyint] NOT NULL IDENTITY(1, 1),
[BackoutType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SettlementOvertimeBackoutType] ADD CONSTRAINT [PK_SettlementOvertimeBackoutType] PRIMARY KEY CLUSTERED ([BackoutTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[SettlementOvertimeBackoutType] TO [public]
GO
GRANT INSERT ON  [dbo].[SettlementOvertimeBackoutType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[SettlementOvertimeBackoutType] TO [public]
GO
GRANT SELECT ON  [dbo].[SettlementOvertimeBackoutType] TO [public]
GO
GRANT UPDATE ON  [dbo].[SettlementOvertimeBackoutType] TO [public]
GO
