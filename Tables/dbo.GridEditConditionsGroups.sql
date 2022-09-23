CREATE TABLE [dbo].[GridEditConditionsGroups]
(
[ConditionGroupID] [int] NOT NULL IDENTITY(1, 1),
[GridName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ColumnName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JoinType] [tinyint] NOT NULL,
[ParentConditionID] [int] NOT NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GridLayoutID] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridIndex] ON [dbo].[GridEditConditionsGroups] ([GridName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GridAndColumnIndex] ON [dbo].[GridEditConditionsGroups] ([GridName], [ColumnName]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GridEditConditionsGroups] TO [public]
GO
GRANT INSERT ON  [dbo].[GridEditConditionsGroups] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GridEditConditionsGroups] TO [public]
GO
GRANT SELECT ON  [dbo].[GridEditConditionsGroups] TO [public]
GO
GRANT UPDATE ON  [dbo].[GridEditConditionsGroups] TO [public]
GO
