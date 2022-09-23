CREATE TABLE [dbo].[manpowerprofile_perdiem_history]
(
[mph_id] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_perdiem_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_perdiem_eff_date] [datetime] NOT NULL,
[mph_updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mph_updated_on] [datetime] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [pk_manpowerprofile_perdiem_history_mph_id] ON [dbo].[manpowerprofile_perdiem_history] ([mph_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_manpowerprofile_perdiem_history_mpp_id] ON [dbo].[manpowerprofile_perdiem_history] ([mpp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manpowerprofile_perdiem_history] TO [public]
GO
GRANT INSERT ON  [dbo].[manpowerprofile_perdiem_history] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manpowerprofile_perdiem_history] TO [public]
GO
GRANT SELECT ON  [dbo].[manpowerprofile_perdiem_history] TO [public]
GO
GRANT UPDATE ON  [dbo].[manpowerprofile_perdiem_history] TO [public]
GO
