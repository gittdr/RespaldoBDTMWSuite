CREATE TABLE [dbo].[country_holiday]
(
[code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[holiday_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[country_holiday] ADD CONSTRAINT [PK_country_holiday] PRIMARY KEY CLUSTERED ([code], [holiday_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[country_holiday] TO [public]
GO
GRANT INSERT ON  [dbo].[country_holiday] TO [public]
GO
GRANT REFERENCES ON  [dbo].[country_holiday] TO [public]
GO
GRANT SELECT ON  [dbo].[country_holiday] TO [public]
GO
GRANT UPDATE ON  [dbo].[country_holiday] TO [public]
GO
