CREATE TABLE [dbo].[company_holiday]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[holiday_id] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_holiday] ADD CONSTRAINT [PK_company_holiday] PRIMARY KEY CLUSTERED ([cmp_id], [holiday_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_holiday] ADD CONSTRAINT [FK_company_holiday_company] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[company_holiday] TO [public]
GO
GRANT INSERT ON  [dbo].[company_holiday] TO [public]
GO
GRANT REFERENCES ON  [dbo].[company_holiday] TO [public]
GO
GRANT SELECT ON  [dbo].[company_holiday] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_holiday] TO [public]
GO
