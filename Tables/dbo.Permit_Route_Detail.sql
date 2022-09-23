CREATE TABLE [dbo].[Permit_Route_Detail]
(
[PRD_ID] [int] NOT NULL IDENTITY(1, 1),
[PRT_ID] [int] NOT NULL,
[PDR_Sequence] [int] NOT NULL,
[PDR_Route] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDR_Direction] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PDR_ToIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Detail] ADD CONSTRAINT [PK_IE_Route] PRIMARY KEY CLUSTERED ([PRD_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Detail] ADD CONSTRAINT [FK_Permit_Route_Detail_Permit_Route] FOREIGN KEY ([PRT_ID]) REFERENCES [dbo].[Permit_Route] ([PRT_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Route_Detail] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Route_Detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Route_Detail] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Route_Detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Route_Detail] TO [public]
GO
