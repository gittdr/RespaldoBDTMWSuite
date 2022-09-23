CREATE TABLE [dbo].[legal_entity_postingperiod]
(
[lepp_le_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_lepp_le_id] DEFAULT ('UNK'),
[lepp_fiscalyear] [smallint] NOT NULL,
[lepp_series] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lepp_period] [smallint] NOT NULL,
[lepp_period_startdate] [datetime] NULL,
[lepp_period_enddate] [datetime] NULL,
[lepp_use_postdate] [datetime] NULL,
[lepp_period_cutoff] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legal_entity_postingperiod] ADD CONSTRAINT [pk_legal_entity_postingperiod] PRIMARY KEY NONCLUSTERED ([lepp_le_id], [lepp_fiscalyear], [lepp_series], [lepp_period]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legal_entity_postingperiod] TO [public]
GO
GRANT INSERT ON  [dbo].[legal_entity_postingperiod] TO [public]
GO
GRANT REFERENCES ON  [dbo].[legal_entity_postingperiod] TO [public]
GO
GRANT SELECT ON  [dbo].[legal_entity_postingperiod] TO [public]
GO
GRANT UPDATE ON  [dbo].[legal_entity_postingperiod] TO [public]
GO
