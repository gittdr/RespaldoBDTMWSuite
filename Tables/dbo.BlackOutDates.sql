CREATE TABLE [dbo].[BlackOutDates]
(
[bod_id] [int] NOT NULL IDENTITY(1, 1),
[bod_datetime] [datetime] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[BlackOutDates] TO [public]
GO
GRANT INSERT ON  [dbo].[BlackOutDates] TO [public]
GO
GRANT REFERENCES ON  [dbo].[BlackOutDates] TO [public]
GO
GRANT SELECT ON  [dbo].[BlackOutDates] TO [public]
GO
GRANT UPDATE ON  [dbo].[BlackOutDates] TO [public]
GO
