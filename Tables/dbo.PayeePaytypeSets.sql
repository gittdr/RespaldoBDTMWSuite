CREATE TABLE [dbo].[PayeePaytypeSets]
(
[pps_id] [int] NOT NULL IDENTITY(1, 1),
[pps_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_Set_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[brn_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyt_itemcode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_type1] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_type2] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_type3] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_type4] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_created_date] [datetime] NULL,
[pps_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_comment] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_assetlist] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_payment_date] [datetime] NULL,
[pyd_quantity] [float] NULL,
[pyd_description] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnumtype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_refnum] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_payto] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pps_actg_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_employeetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PayeePaytypeSets] ADD CONSTRAINT [PK__PayeePaytypeSets__554BE6E7] PRIMARY KEY CLUSTERED ([pps_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PayeePaytypeSets] TO [public]
GO
GRANT INSERT ON  [dbo].[PayeePaytypeSets] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PayeePaytypeSets] TO [public]
GO
GRANT SELECT ON  [dbo].[PayeePaytypeSets] TO [public]
GO
GRANT UPDATE ON  [dbo].[PayeePaytypeSets] TO [public]
GO
