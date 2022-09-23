CREATE TABLE [dbo].[TMSLaneHeader]
(
[LaneID] [int] NOT NULL IDENTITY(1, 1),
[LaneKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLaneHeader] ADD CONSTRAINT [PK_TMSLaneHeader] PRIMARY KEY CLUSTERED ([LaneID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSLaneHeader] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSLaneHeader] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSLaneHeader] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSLaneHeader] TO [public]
GO
