CREATE TABLE [dbo].[dx_BusinessRules]
(
[dx_ident] [bigint] NOT NULL IDENTITY(1, 1),
[dx_ExecGroup] [int] NULL,
[dx_TradingPartnerID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_rulename] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_ruleExecSequence] [int] NULL,
[dx_recordseq] [int] NULL,
[dx_which] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_item] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_field] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_operator] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_value] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_action] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_conjunction] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_ruletext] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_lastupdated] [datetime] NULL,
[dx_lastuser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_notifymessage] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_BusinessRules] ADD CONSTRAINT [PK_dx_BusinessRules] PRIMARY KEY CLUSTERED ([dx_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_BusinessRules] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_BusinessRules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dx_BusinessRules] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_BusinessRules] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_BusinessRules] TO [public]
GO
