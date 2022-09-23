CREATE TABLE [dbo].[tngPlannerGridParms]
(
[grid_id] [int] NOT NULL,
[parm_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_sequence] [int] NOT NULL,
[parm_datatype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_edit_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_edit_type2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[parm_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tngPlannerGridParms] ADD CONSTRAINT [pk_tngPlannerGridParms_id_name] PRIMARY KEY CLUSTERED ([grid_id], [parm_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tngPlannerGridParms] ADD CONSTRAINT [fk_tngPlannerGrid_id] FOREIGN KEY ([grid_id]) REFERENCES [dbo].[tngPlannerGrid] ([grid_id])
GO
GRANT DELETE ON  [dbo].[tngPlannerGridParms] TO [public]
GO
GRANT INSERT ON  [dbo].[tngPlannerGridParms] TO [public]
GO
GRANT SELECT ON  [dbo].[tngPlannerGridParms] TO [public]
GO
GRANT UPDATE ON  [dbo].[tngPlannerGridParms] TO [public]
GO
