CREATE TABLE [dbo].[averagefuelprice]
(
[afp_tableid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[afp_date] [datetime] NOT NULL,
[afp_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[afp_price] [money] NOT NULL,
[afp_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[afp_BelongsTo] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowsec_rsrv_id] [int] NULL,
[afp_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[afp_id] [int] NOT NULL IDENTITY(1, 1),
[afp_AppliedToBillingTariff] [int] NULL CONSTRAINT [DF__averagefu__afp_A__4CAFACA1] DEFAULT ((0)),
[afp_AppliedToSettlementTariff] [int] NULL CONSTRAINT [DF__averagefu__afp_A__4DA3D0DA] DEFAULT ((0)),
[afp_IsFormula] [int] NULL CONSTRAINT [DF__averagefu__afp_I__4E97F513] DEFAULT ((0)),
[afp_IsProcessed] [datetime] NULL CONSTRAINT [DF__averagefu__afp_I__7A3181FD] DEFAULT (NULL),
[INS_TIMESTAMP] [datetime2] (0) NOT NULL CONSTRAINT [DF__averagefu__INS_T__33204A2A] DEFAULT (getdate()),
[DW_TIMESTAMP] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[averagefuelprice] ADD CONSTRAINT [pk_averagefuelprice] PRIMARY KEY CLUSTERED ([afp_tableid], [afp_date]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_averagefuelprice_afp_id] ON [dbo].[averagefuelprice] ([afp_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [averagefuelprice_INS_TIMESTAMP] ON [dbo].[averagefuelprice] ([INS_TIMESTAMP] DESC) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[averagefuelprice] TO [public]
GO
GRANT INSERT ON  [dbo].[averagefuelprice] TO [public]
GO
GRANT REFERENCES ON  [dbo].[averagefuelprice] TO [public]
GO
GRANT SELECT ON  [dbo].[averagefuelprice] TO [public]
GO
GRANT UPDATE ON  [dbo].[averagefuelprice] TO [public]
GO
