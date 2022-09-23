CREATE TABLE [dbo].[stdmaster]
(
[sdm_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_deductionterm] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_deductionrate] [money] NULL,
[sdm_reductionterm] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_reductionrate] [money] NULL,
[sdm_interestrate] [float] NULL,
[sdm_compoundterm] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_calculateterm] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_minusbalance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_deductionbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_reductionbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_priority] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[sdm_deductionqty] [money] NULL,
[sdm_reductionqty] [money] NULL,
[sdm_allowancepay] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_dedschedule] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_deddays] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_dedweeks] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_dedmonths] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_redschedule] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_reddays] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_redweeks] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_redmonths] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_dedround] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_redround] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_compschedule] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_compdays] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_compweeks] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_compmonths] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_calcschedule] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_calcdays] [char] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_calcweeks] [char] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_calcmonths] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_compounddays] [money] NULL,
[sdm_payback] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_miletype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_group] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_cap] [money] NULL,
[sdm_ratetable] [int] NULL,
[sdm_vendorpay] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_sdm_vendorpay] DEFAULT ('N'),
[sdm_ignoreonclose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_sdm_ignoreonclose] DEFAULT ('N'),
[sdm_escrowstyle] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sth_abbr] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_sth_priority] [int] NULL,
[sdm_Garnishment] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_CapPercent] [money] NULL,
[pyt_itemcodenontax] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_AdjustWithNegativePay] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdm_sequential_loan] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_pyt_itemcode] ON [dbo].[stdmaster] ([pyt_itemcode]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sdm_calculateterm] ON [dbo].[stdmaster] ([sdm_calculateterm]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_sdm_itemcode] ON [dbo].[stdmaster] ([sdm_itemcode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stdmaster] TO [public]
GO
GRANT INSERT ON  [dbo].[stdmaster] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stdmaster] TO [public]
GO
GRANT SELECT ON  [dbo].[stdmaster] TO [public]
GO
GRANT UPDATE ON  [dbo].[stdmaster] TO [public]
GO
