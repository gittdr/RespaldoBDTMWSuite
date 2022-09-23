CREATE TABLE [dbo].[MetricTempEmails]
(
[email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricTempEmails_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricTempEmails] ADD CONSTRAINT [prkey_MetricTempEmails] PRIMARY KEY CLUSTERED ([MetricTempEmails_ident]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricTempEmails] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricTempEmails] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricTempEmails] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricTempEmails] TO [public]
GO
