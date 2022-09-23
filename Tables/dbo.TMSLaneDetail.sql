CREATE TABLE [dbo].[TMSLaneDetail]
(
[LaneDetailID] [int] NOT NULL IDENTITY(1, 1),
[LaneID] [int] NOT NULL,
[BranchID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Priority] [int] NOT NULL,
[OriginRegion] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestRegion] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginCompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestCompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginState] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestState] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginZip1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestZip1] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginZip2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestZip2] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLaneDetail] ADD CONSTRAINT [PK_TMSLaneDetail] PRIMARY KEY CLUSTERED ([LaneDetailID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSLaneDetail] ADD CONSTRAINT [FK_TMSLaneDetail_TMSLaneHeader] FOREIGN KEY ([LaneID]) REFERENCES [dbo].[TMSLaneHeader] ([LaneID])
GO
GRANT DELETE ON  [dbo].[TMSLaneDetail] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSLaneDetail] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSLaneDetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSLaneDetail] TO [public]
GO
