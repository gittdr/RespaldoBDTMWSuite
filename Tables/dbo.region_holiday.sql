CREATE TABLE [dbo].[region_holiday]
(
[region_id] [int] NOT NULL,
[holiday_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[region_holiday] ADD CONSTRAINT [PK_region_holiday] PRIMARY KEY CLUSTERED ([region_id], [holiday_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[region_holiday] ADD CONSTRAINT [FK_region_holiday_holidays] FOREIGN KEY ([holiday_id]) REFERENCES [dbo].[holidays] ([holiday_id])
GO
ALTER TABLE [dbo].[region_holiday] ADD CONSTRAINT [FK_region_holiday_region] FOREIGN KEY ([region_id]) REFERENCES [dbo].[ttrheader] ([ttr_number])
GO
GRANT DELETE ON  [dbo].[region_holiday] TO [public]
GO
GRANT INSERT ON  [dbo].[region_holiday] TO [public]
GO
GRANT REFERENCES ON  [dbo].[region_holiday] TO [public]
GO
GRANT SELECT ON  [dbo].[region_holiday] TO [public]
GO
GRANT UPDATE ON  [dbo].[region_holiday] TO [public]
GO
