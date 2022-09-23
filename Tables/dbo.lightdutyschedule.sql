CREATE TABLE [dbo].[lightdutyschedule]
(
[id_num] [int] NOT NULL IDENTITY(1, 1),
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lds_shift] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lds_costcenter] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lds_date] [datetime] NULL,
[lds_hours] [decimal] (4, 2) NOT NULL,
[lds_activity] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lds_comment] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lightdutyschedule] ADD CONSTRAINT [pk_lightdutyschedule_id_num] PRIMARY KEY CLUSTERED ([id_num]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lightdutyschedule_lds_date] ON [dbo].[lightdutyschedule] ([lds_date]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[lightdutyschedule] TO [public]
GO
GRANT INSERT ON  [dbo].[lightdutyschedule] TO [public]
GO
GRANT REFERENCES ON  [dbo].[lightdutyschedule] TO [public]
GO
GRANT SELECT ON  [dbo].[lightdutyschedule] TO [public]
GO
GRANT UPDATE ON  [dbo].[lightdutyschedule] TO [public]
GO
