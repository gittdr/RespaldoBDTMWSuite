CREATE TABLE [dbo].[drivershift]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shift_id] [int] NOT NULL,
[shift_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[login_time] [datetime] NOT NULL,
[logout_time] [datetime] NULL,
[start_time] [datetime] NULL,
[end_time] [datetime] NULL,
[chk_sum] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[drivershift] ADD CONSTRAINT [PK__driversh__C223E0BF76B0BF8B] PRIMARY KEY CLUSTERED ([mpp_id], [shift_id], [login_time]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[drivershift] TO [public]
GO
GRANT INSERT ON  [dbo].[drivershift] TO [public]
GO
GRANT REFERENCES ON  [dbo].[drivershift] TO [public]
GO
GRANT SELECT ON  [dbo].[drivershift] TO [public]
GO
GRANT UPDATE ON  [dbo].[drivershift] TO [public]
GO
