CREATE TABLE [dbo].[core_lanefilter]
(
[LaneFilterId] [int] NOT NULL IDENTITY(1, 1),
[LaneId] [int] NOT NULL,
[FilterKey] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsExclude] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanefilter] ADD CONSTRAINT [PK_core_lanefilter] PRIMARY KEY CLUSTERED ([LaneFilterId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[core_lanefilter] ADD CONSTRAINT [FK_core_lanefilter_core_lane] FOREIGN KEY ([LaneId]) REFERENCES [dbo].[core_lane] ([laneid]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[core_lanefilter] TO [public]
GO
GRANT INSERT ON  [dbo].[core_lanefilter] TO [public]
GO
GRANT SELECT ON  [dbo].[core_lanefilter] TO [public]
GO
GRANT UPDATE ON  [dbo].[core_lanefilter] TO [public]
GO
