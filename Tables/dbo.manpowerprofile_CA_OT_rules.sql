CREATE TABLE [dbo].[manpowerprofile_CA_OT_rules]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mpp_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_caot_mpp_updatedby] DEFAULT (suser_sname()),
[mpp_updatedon] [datetime] NULL CONSTRAINT [df_caot_mpp_updatedon] DEFAULT (getdate()),
[mpp_day15_ot_min] [money] NULL,
[mpp_day15_ot_max] [money] NULL,
[mpp_day6_ot_min] [money] NULL,
[mpp_day6_ot_max] [money] NULL,
[mpp_day7_ot_min] [money] NULL,
[mpp_day7_ot_max] [money] NULL,
[mpp_day16_dblt_min] [money] NULL,
[mpp_day7_dblt_min] [money] NULL,
[mpp_day15_rt_min] [money] NULL,
[mpp_OT_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_OT_miles] [float] NULL,
[mpp_OTRules_ID] [int] NOT NULL IDENTITY(1, 1),
[mpp_SetDefaultForState] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[manpowerprofile_CA_OT_rules] ADD CONSTRAINT [pk_mpp_OTRules_ID] PRIMARY KEY CLUSTERED ([mpp_OTRules_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_mpp_OTRules_ID] ON [dbo].[manpowerprofile_CA_OT_rules] ([mpp_OTRules_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[manpowerprofile_CA_OT_rules] ADD CONSTRAINT [fk_caot_mpp_id] FOREIGN KEY ([mpp_id]) REFERENCES [dbo].[manpowerprofile] ([mpp_id])
GO
GRANT DELETE ON  [dbo].[manpowerprofile_CA_OT_rules] TO [public]
GO
GRANT INSERT ON  [dbo].[manpowerprofile_CA_OT_rules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manpowerprofile_CA_OT_rules] TO [public]
GO
GRANT SELECT ON  [dbo].[manpowerprofile_CA_OT_rules] TO [public]
GO
GRANT UPDATE ON  [dbo].[manpowerprofile_CA_OT_rules] TO [public]
GO
