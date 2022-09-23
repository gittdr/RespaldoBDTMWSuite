CREATE TABLE [dbo].[MetricLocale]
(
[LocaleName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocaleID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricLocale] ADD CONSTRAINT [PK_MetricLocale] PRIMARY KEY CLUSTERED ([LocaleName], [LocaleID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricLocale] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricLocale] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricLocale] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricLocale] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricLocale] TO [public]
GO
