CREATE TABLE [dbo].[TMSRuleConfig]
(
[RuleId] [int] NOT NULL IDENTITY(1, 1),
[Account] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Branch] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSOrderDefaultFieldsSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSOrderAfterSaveSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSETSGetOrderRefNumbersSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSETSGetStopRefNumbersSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMSETSAfterSaveSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [dc_TMSRuleConfig_CreateDate] DEFAULT (getdate()),
[CreateUser] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [dc_TMSRuleConfig_CreateUser] DEFAULT (suser_sname()),
[TMSShipmentDefaultFieldsSP] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dc_TMSRuleConfig_TMSShipmentDefaultFieldsSP] DEFAULT ('')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRuleConfig] ADD CONSTRAINT [PK_TMSRuleConfig] PRIMARY KEY CLUSTERED ([RuleId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_TMSRuleConfig_branch] ON [dbo].[TMSRuleConfig] ([Branch]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSRuleConfig] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSRuleConfig] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSRuleConfig] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSRuleConfig] TO [public]
GO
