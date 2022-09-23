CREATE TABLE [dbo].[equipmentconfigheader]
(
[ech_id] [int] NOT NULL,
[ech_trc_loading_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ech_lead_trl_loading_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_pup_trl_loading_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_train_config] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ech_trc_front_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_trc_rear_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_lead_trl_front_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_lead_trl_rear_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_pup_trl_front_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_pup_trl_rear_axl_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ech_trc_compartm_number] [int] NULL,
[ech_lead_trl_compartm_number] [int] NULL,
[ech_pup_trl_compartm_number] [int] NULL,
[ech_axles] [smallint] NULL,
[cmd_class] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[equipmentconfigheader] ADD CONSTRAINT [pk_equipmentconfigheader] PRIMARY KEY CLUSTERED ([ech_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[equipmentconfigheader] TO [public]
GO
GRANT INSERT ON  [dbo].[equipmentconfigheader] TO [public]
GO
GRANT REFERENCES ON  [dbo].[equipmentconfigheader] TO [public]
GO
GRANT SELECT ON  [dbo].[equipmentconfigheader] TO [public]
GO
GRANT UPDATE ON  [dbo].[equipmentconfigheader] TO [public]
GO
