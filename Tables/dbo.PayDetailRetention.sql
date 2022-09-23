CREATE TABLE [dbo].[PayDetailRetention]
(
[pdr_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[asgn_number] [int] NOT NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_quantity] [float] NULL,
[pyd_rate] [money] NULL,
[pyd_amount] [money] NULL,
[pyh_payperiod] [datetime] NULL,
[pyd_minus] [int] NULL,
[psd_id] [int] NULL,
[tar_tarriffnumber] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__PayDetail__Creat__37C9685B] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__PayDetail__Creat__38BD8C94] DEFAULT (getdate()),
[PayScheduleId] [int] NULL CONSTRAINT [DF__PayDetail__PaySc__5F13776D] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayDetailRetention] ADD CONSTRAINT [PK_PayDetailRetention_pdr_id] PRIMARY KEY CLUSTERED ([pdr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PayDetailRetention] TO [public]
GO
GRANT INSERT ON  [dbo].[PayDetailRetention] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PayDetailRetention] TO [public]
GO
GRANT SELECT ON  [dbo].[PayDetailRetention] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayDetailRetention] TO [public]
GO
