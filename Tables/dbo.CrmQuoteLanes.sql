CREATE TABLE [dbo].[CrmQuoteLanes]
(
[cql_id] [int] NOT NULL IDENTITY(1, 1),
[cql_cqh_id] [int] NOT NULL,
[cql_LaneID] [int] NULL,
[cql_origintype] [int] NOT NULL CONSTRAINT [df_cql_origintype] DEFAULT ((0)),
[cql_originvalue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cql_destinationtype] [int] NOT NULL CONSTRAINT [df_cql_destinationtype] DEFAULT ((0)),
[cql_destinationvalue] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cql_chargeamount] [money] NULL,
[cql_minimumtype] [int] NOT NULL CONSTRAINT [df_cql_minimumtype] DEFAULT ((0)),
[cql_minimum] [money] NOT NULL CONSTRAINT [df_cql_minimum] DEFAULT ((0)),
[cql_acceptreject] [int] NOT NULL CONSTRAINT [df_cql_acceptreject] DEFAULT ((0)),
[cql_effectivedate] [datetime] NOT NULL CONSTRAINT [df_cql_effectivedate] DEFAULT ('19500101'),
[cql_expirationdate] [datetime] NOT NULL CONSTRAINT [df_cql_expirationdate] DEFAULT ('19500101'),
[cql_rangetype] [int] NOT NULL CONSTRAINT [df_cql_rangetype] DEFAULT ((0)),
[cql_minrange] [decimal] (9, 4) NOT NULL CONSTRAINT [df_cql_minrange] DEFAULT ((0)),
[cql_maxrange] [decimal] (9, 4) NOT NULL CONSTRAINT [df_cql_maxrange] DEFAULT ((0)),
[cql_tar_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrmQuoteLanes] ADD CONSTRAINT [pk_cql_id] PRIMARY KEY CLUSTERED ([cql_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ux_cql_lanedefinition] ON [dbo].[CrmQuoteLanes] ([cql_id], [cql_origintype], [cql_originvalue], [cql_destinationtype], [cql_destinationvalue]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CrmQuoteLanes] ADD CONSTRAINT [fk_cql_cqh_id] FOREIGN KEY ([cql_cqh_id]) REFERENCES [dbo].[crmQuoteHeader] ([cqh_id])
GO
GRANT DELETE ON  [dbo].[CrmQuoteLanes] TO [public]
GO
GRANT INSERT ON  [dbo].[CrmQuoteLanes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CrmQuoteLanes] TO [public]
GO
GRANT SELECT ON  [dbo].[CrmQuoteLanes] TO [public]
GO
GRANT UPDATE ON  [dbo].[CrmQuoteLanes] TO [public]
GO
