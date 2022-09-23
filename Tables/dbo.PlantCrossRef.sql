CREATE TABLE [dbo].[PlantCrossRef]
(
[pcr_identity] [int] NOT NULL IDENTITY(1, 1),
[pcr_plant] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pcr_cmp_id] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pcr_branch] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[PlantCrossRef] TO [public]
GO
GRANT INSERT ON  [dbo].[PlantCrossRef] TO [public]
GO
GRANT SELECT ON  [dbo].[PlantCrossRef] TO [public]
GO
GRANT UPDATE ON  [dbo].[PlantCrossRef] TO [public]
GO
