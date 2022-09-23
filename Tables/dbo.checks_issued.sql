CREATE TABLE [dbo].[checks_issued]
(
[check_number] [int] NOT NULL,
[check_description] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[check_date] [datetime] NOT NULL,
[check_amount] [float] NOT NULL,
[check_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reissue_number] [int] NULL,
[user_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pay_period] [datetime] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [u_checkno] ON [dbo].[checks_issued] ([check_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [user_ix] ON [dbo].[checks_issued] ([user_name]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[checks_issued] TO [public]
GO
GRANT INSERT ON  [dbo].[checks_issued] TO [public]
GO
GRANT REFERENCES ON  [dbo].[checks_issued] TO [public]
GO
GRANT SELECT ON  [dbo].[checks_issued] TO [public]
GO
GRANT UPDATE ON  [dbo].[checks_issued] TO [public]
GO
