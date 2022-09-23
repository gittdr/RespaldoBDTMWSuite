CREATE TABLE [dbo].[MetricSchedule]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[MinutesApart] [int] NULL,
[HoursApart] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MetricSchedule] ADD CONSTRAINT [PK__MetricSchedule__2241442D] PRIMARY KEY NONCLUSTERED ([sn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MetricSchedule] TO [public]
GO
GRANT INSERT ON  [dbo].[MetricSchedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MetricSchedule] TO [public]
GO
GRANT SELECT ON  [dbo].[MetricSchedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[MetricSchedule] TO [public]
GO
