CREATE TABLE [dbo].[schedule_holidays]
(
[sch_number] [int] NOT NULL,
[holiday_id] [int] NOT NULL,
[deliver_when] [smallint] NOT NULL,
[holiday_code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[holiday_country] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schedule_holidays] ADD CONSTRAINT [pk_schedule_holidays] PRIMARY KEY CLUSTERED ([sch_number], [holiday_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[schedule_holidays] ADD CONSTRAINT [fk_holiday] FOREIGN KEY ([holiday_id]) REFERENCES [dbo].[holidays] ([holiday_id])
GO
GRANT DELETE ON  [dbo].[schedule_holidays] TO [public]
GO
GRANT INSERT ON  [dbo].[schedule_holidays] TO [public]
GO
GRANT REFERENCES ON  [dbo].[schedule_holidays] TO [public]
GO
GRANT SELECT ON  [dbo].[schedule_holidays] TO [public]
GO
GRANT UPDATE ON  [dbo].[schedule_holidays] TO [public]
GO
