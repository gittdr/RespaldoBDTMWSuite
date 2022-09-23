CREATE TABLE [dbo].[scheduleparms]
(
[ord_subcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[scv_id] [int] NOT NULL,
[scp_processind] [int] NULL,
[scp_overrideind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scp_fromdate] [datetime] NULL,
[scp_todate] [datetime] NULL,
[scp_weekendind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[scp_holidayind] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[scheduleparms] TO [public]
GO
GRANT INSERT ON  [dbo].[scheduleparms] TO [public]
GO
GRANT REFERENCES ON  [dbo].[scheduleparms] TO [public]
GO
GRANT SELECT ON  [dbo].[scheduleparms] TO [public]
GO
GRANT UPDATE ON  [dbo].[scheduleparms] TO [public]
GO
