CREATE TABLE [dbo].[userdatawindow]
(
[udw_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[udw_dataobject] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[grp_group] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[usr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[udw_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_type] ON [dbo].[userdatawindow] ([udw_type], [grp_group], [usr_id], [udw_dataobject]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[userdatawindow] TO [public]
GO
GRANT INSERT ON  [dbo].[userdatawindow] TO [public]
GO
GRANT REFERENCES ON  [dbo].[userdatawindow] TO [public]
GO
GRANT SELECT ON  [dbo].[userdatawindow] TO [public]
GO
GRANT UPDATE ON  [dbo].[userdatawindow] TO [public]
GO
