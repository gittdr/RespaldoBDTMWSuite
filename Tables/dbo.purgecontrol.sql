CREATE TABLE [dbo].[purgecontrol]
(
[from_date] [datetime] NOT NULL,
[thru_date] [datetime] NOT NULL,
[start_date] [datetime] NULL,
[end_date] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purgecontrol] TO [public]
GO
GRANT INSERT ON  [dbo].[purgecontrol] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purgecontrol] TO [public]
GO
GRANT SELECT ON  [dbo].[purgecontrol] TO [public]
GO
GRANT UPDATE ON  [dbo].[purgecontrol] TO [public]
GO
