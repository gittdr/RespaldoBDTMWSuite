CREATE TABLE [dbo].[PlantDock]
(
[pd_plant] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pd_dock] [char] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pd_dock_name] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pd_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlantDock] TO [public]
GO
GRANT INSERT ON  [dbo].[PlantDock] TO [public]
GO
GRANT REFERENCES ON  [dbo].[PlantDock] TO [public]
GO
GRANT SELECT ON  [dbo].[PlantDock] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlantDock] TO [public]
GO
