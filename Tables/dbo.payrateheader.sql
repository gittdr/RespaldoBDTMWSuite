CREATE TABLE [dbo].[payrateheader]
(
[timestamp] [timestamp] NULL,
[prh_number] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prh_basis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_compmethod] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[prh_unitbasis] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_unit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_rateunit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_minimum] [money] NULL,
[pyt_itemcode] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_remark] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_name] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_distbasis] [tinyint] NULL,
[prh_distplus] [float] NULL,
[prh_brkpt] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_teamsplit] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_revreduction] [float] NULL,
[prh_config] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_usedb] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prh_companyminimum] [money] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_number] ON [dbo].[payrateheader] ([prh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[payrateheader] TO [public]
GO
GRANT INSERT ON  [dbo].[payrateheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[payrateheader] TO [public]
GO
GRANT SELECT ON  [dbo].[payrateheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[payrateheader] TO [public]
GO
