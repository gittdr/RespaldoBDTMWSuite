CREATE TABLE [dbo].[commodity_prior_rules]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[prior_cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prior_cmd_class2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prior_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invalid_cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invalid_cmd_class2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[invalid_cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsPrevent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_commodity_prior_rules_IsPrevent] DEFAULT ('N'),
[LoadsBack] [int] NOT NULL CONSTRAINT [dk_commodity_prior_rules_LoadsBack] DEFAULT ((1)),
[cpr_cleaning] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [dk_commodity_prior_rules_cleaning] DEFAULT ('UNK')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[commodity_prior_rules] ADD CONSTRAINT [PK__commodity_prior___76ACDAB2] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [cpr_altidx] ON [dbo].[commodity_prior_rules] ([prior_cmd_code], [prior_cmd_class], [prior_cmd_class2]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[commodity_prior_rules] TO [public]
GO
GRANT INSERT ON  [dbo].[commodity_prior_rules] TO [public]
GO
GRANT SELECT ON  [dbo].[commodity_prior_rules] TO [public]
GO
GRANT UPDATE ON  [dbo].[commodity_prior_rules] TO [public]
GO
