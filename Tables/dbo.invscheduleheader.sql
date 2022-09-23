CREATE TABLE [dbo].[invscheduleheader]
(
[ish_id] [int] NOT NULL,
[ish_status] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ish_start_date] [datetime] NULL,
[ish_end_date] [datetime] NULL,
[ish_revenue_date] [datetime] NULL,
[ish_name] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ish_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ish_period] [int] NULL,
[ish_year] [int] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ish_id] ON [dbo].[invscheduleheader] ([ish_id], [ish_revtype4]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[invscheduleheader] TO [public]
GO
GRANT INSERT ON  [dbo].[invscheduleheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[invscheduleheader] TO [public]
GO
GRANT SELECT ON  [dbo].[invscheduleheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[invscheduleheader] TO [public]
GO
