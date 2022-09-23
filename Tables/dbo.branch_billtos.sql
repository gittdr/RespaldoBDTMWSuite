CREATE TABLE [dbo].[branch_billtos]
(
[bbc_brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bbc_cmp_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[bbc_default] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_default] DEFAULT ('N'),
[bbc_lastbillingperiod] [datetime] NOT NULL CONSTRAINT [DF_bbc_lastbillingperiod] DEFAULT ('19500101'),
[bbc_lastbilling_closed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_lastbilling_closed] DEFAULT ('N'),
[bbc_lastbilling_transferred] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_lastbilling_transferred] DEFAULT ('N'),
[bbc_fullgeneration_complete] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_fullgeneration_complete] DEFAULT ('N'),
[bbc_accounting_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bbc_fullgeneration_date] [datetime] NOT NULL CONSTRAINT [DF_bbc_fullgeneration_date] DEFAULT ('19500101'),
[bbc_dedicated_bill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_dedicated_bill] DEFAULT ('N'),
[bbc_cycle_days] [smallint] NOT NULL CONSTRAINT [DF_bbc_cycle_days] DEFAULT ((1)),
[bbc_cycle_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_cycle_type] DEFAULT ('DAYS'),
[bbc_usedate] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_usedate] DEFAULT ('SHIP'),
[bbc_hourlyrate] [money] NULL,
[bbc_dailyguarenteedhours] [money] NULL,
[bbc_periodguarenteedhours] [money] NULL,
[bbc_hrs_dbl_time] [money] NULL,
[bbc_comparisonflag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bbc_timeoffbetweenduty] [decimal] (5, 2) NULL,
[bbc_readytoclose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_readytoclose] DEFAULT ('N'),
[bbc_MustClosePayrollbeforeBillingClose] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_MustClosePayrollbeforeBillingClose] DEFAULT ('Y'),
[bbc_ident] [int] NOT NULL IDENTITY(1, 1),
[bbc_do_not_transfer_billing] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_bbc_do_not_transfer_billing] DEFAULT ('Y'),
[bbc_billing_approveremail] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bbc_billing_close_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__branch_bi__bbc_b__43A6943F] DEFAULT ('PRN'),
[bbc_mileagetable] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[bbc_DefaultIntraCityMileage] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[branch_billtos] ADD CONSTRAINT [PK_branch_billtos] PRIMARY KEY CLUSTERED ([bbc_brn_id], [bbc_cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[branch_billtos] TO [public]
GO
GRANT INSERT ON  [dbo].[branch_billtos] TO [public]
GO
GRANT REFERENCES ON  [dbo].[branch_billtos] TO [public]
GO
GRANT SELECT ON  [dbo].[branch_billtos] TO [public]
GO
GRANT UPDATE ON  [dbo].[branch_billtos] TO [public]
GO
