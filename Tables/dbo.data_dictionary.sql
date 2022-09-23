CREATE TABLE [dbo].[data_dictionary]
(
[ddy_tblnam] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ddy_colnam] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ddy_coldsc] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colsysctlid] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colminmax] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_coldefval] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colden] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colprikey] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colfgnkey] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_coliniscn] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_collbl] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_collblcodrng] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ddy_colcom] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [ddy_primary] ON [dbo].[data_dictionary] ([ddy_tblnam], [ddy_colnam]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[data_dictionary] TO [public]
GO
GRANT INSERT ON  [dbo].[data_dictionary] TO [public]
GO
GRANT REFERENCES ON  [dbo].[data_dictionary] TO [public]
GO
GRANT SELECT ON  [dbo].[data_dictionary] TO [public]
GO
GRANT UPDATE ON  [dbo].[data_dictionary] TO [public]
GO
