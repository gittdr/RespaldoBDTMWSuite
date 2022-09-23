CREATE TABLE [dbo].[pendingadvances]
(
[pa_id] [int] NOT NULL IDENTITY(1, 1),
[asgn_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pa_amount] [money] NULL,
[pa_fee] [money] NULL,
[pa_status] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__pendingad__pa_st__6E214E8F] DEFAULT ('U'),
[pa_result] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tracking_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_number] [int] NULL,
[mov_number] [int] NULL,
[crd_accountid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_customerid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[crd_cardnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_date] [datetime] NULL,
[processed_date] [datetime] NULL,
[pa_payback] [money] NULL,
[pa_bond] [money] NULL,
[pa_pay] [money] NULL,
[pa_processing_message] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[update_date] [datetime] NULL,
[pa_advance_percent] [money] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[pendingadvances] ADD CONSTRAINT [pk_pendingadvances_pa_id] PRIMARY KEY CLUSTERED ([pa_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pendingadvances] TO [public]
GO
GRANT INSERT ON  [dbo].[pendingadvances] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pendingadvances] TO [public]
GO
GRANT SELECT ON  [dbo].[pendingadvances] TO [public]
GO
GRANT UPDATE ON  [dbo].[pendingadvances] TO [public]
GO
