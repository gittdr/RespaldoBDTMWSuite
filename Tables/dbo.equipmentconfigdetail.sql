CREATE TABLE [dbo].[equipmentconfigdetail]
(
[ech_id] [int] NOT NULL,
[ecd_id] [int] NOT NULL,
[ecd_compartm_number] [int] NULL,
[ecd_grp1_percent] [float] NULL,
[ecd_grp2_percent] [float] NULL,
[ecd_grp3_percent] [float] NULL,
[ecd_grp4_percent] [float] NULL,
[ecd_grp5_percent] [float] NULL,
[ecd_compartm_from] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[equipmentconfigdetail] ADD CONSTRAINT [pk_equipmentconfigdetail] PRIMARY KEY CLUSTERED ([ech_id], [ecd_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[equipmentconfigdetail] TO [public]
GO
GRANT INSERT ON  [dbo].[equipmentconfigdetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[equipmentconfigdetail] TO [public]
GO
GRANT SELECT ON  [dbo].[equipmentconfigdetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[equipmentconfigdetail] TO [public]
GO
