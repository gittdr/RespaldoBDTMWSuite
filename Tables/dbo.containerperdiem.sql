CREATE TABLE [dbo].[containerperdiem]
(
[cpd_id] [int] NOT NULL IDENTITY(1, 1),
[cpd_sequence] [int] NULL,
[cpd_owner] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_port] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_customer] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_freedays] [int] NULL,
[cpd_days1] [int] NULL,
[cpd_charge1] [money] NULL,
[cpd_days2] [int] NULL,
[cpd_charge2] [money] NULL,
[cpd_days3] [int] NULL,
[cpd_charge3] [money] NULL,
[cpd_days4] [int] NULL,
[cpd_charge4] [money] NULL,
[cpd_maxcharge] [money] NULL,
[cpd_incremental] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_created_date] [datetime] NOT NULL,
[cpd_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpd_modified_date] [datetime] NOT NULL,
[cpd_modified_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cpd_count_saturday_freedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_count_sunday_freedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_count_holiday_freedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_count_saturday_chargedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_count_sunday_chargedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_count_holiday_chargedays] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_eff_date] [datetime] NULL,
[cpd_exp_date] [datetime] NULL,
[cpd_trltype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_trltype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_trltype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_trltype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_admin_fee] [money] NULL CONSTRAINT [DF__container__cpd_a__2F9F9B92] DEFAULT ((0)),
[cpd_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_iso_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cpd_length] [float] NULL CONSTRAINT [DF__container__cpd_l__3093BFCB] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[containerperdiem] ADD CONSTRAINT [PK_containerperdiem] PRIMARY KEY CLUSTERED ([cpd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[containerperdiem] TO [public]
GO
GRANT INSERT ON  [dbo].[containerperdiem] TO [public]
GO
GRANT REFERENCES ON  [dbo].[containerperdiem] TO [public]
GO
GRANT SELECT ON  [dbo].[containerperdiem] TO [public]
GO
GRANT UPDATE ON  [dbo].[containerperdiem] TO [public]
GO
