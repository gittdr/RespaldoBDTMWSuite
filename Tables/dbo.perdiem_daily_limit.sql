CREATE TABLE [dbo].[perdiem_daily_limit]
(
[pdl_id] [int] NOT NULL IDENTITY(1, 1),
[pdl_eff_date] [datetime] NOT NULL,
[pdl_daily_limit] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_perdiem_daily_limit_pdl_eff_date] ON [dbo].[perdiem_daily_limit] ([pdl_eff_date]) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [pk_perdiem_daily_limit_pdl_id] ON [dbo].[perdiem_daily_limit] ([pdl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[perdiem_daily_limit] TO [public]
GO
GRANT INSERT ON  [dbo].[perdiem_daily_limit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[perdiem_daily_limit] TO [public]
GO
GRANT SELECT ON  [dbo].[perdiem_daily_limit] TO [public]
GO
GRANT UPDATE ON  [dbo].[perdiem_daily_limit] TO [public]
GO
