CREATE TABLE [dbo].[averagefuelpricebackup]
(
[afp_date] [datetime] NULL,
[afp_price] [money] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[averagefuelpricebackup] TO [public]
GO
GRANT INSERT ON  [dbo].[averagefuelpricebackup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[averagefuelpricebackup] TO [public]
GO
GRANT SELECT ON  [dbo].[averagefuelpricebackup] TO [public]
GO
GRANT UPDATE ON  [dbo].[averagefuelpricebackup] TO [public]
GO
