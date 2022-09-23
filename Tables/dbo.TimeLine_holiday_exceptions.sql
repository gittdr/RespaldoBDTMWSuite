CREATE TABLE [dbo].[TimeLine_holiday_exceptions]
(
[holiday] [datetime] NOT NULL,
[description] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[year] [int] NULL,
[tlh_number] [int] NULL,
[holiday_id] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TimeLine_holiday_exceptions] ADD CONSTRAINT [pk_TimeLine_holiday_exceptions] PRIMARY KEY CLUSTERED ([holiday_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TimeLine_holiday_exceptions] TO [public]
GO
GRANT INSERT ON  [dbo].[TimeLine_holiday_exceptions] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TimeLine_holiday_exceptions] TO [public]
GO
GRANT SELECT ON  [dbo].[TimeLine_holiday_exceptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[TimeLine_holiday_exceptions] TO [public]
GO
