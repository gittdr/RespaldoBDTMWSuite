CREATE TABLE [dbo].[Permit_Route_Detail_Altered]
(
[PRDA_ID] [int] NOT NULL IDENTITY(1, 1),
[PRTA_ID] [int] NOT NULL,
[PRDA_Sequence] [int] NOT NULL,
[PRDA_Route] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRDA_Direction] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRDA_ToIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Detail_Altered] ADD CONSTRAINT [PK_Route] PRIMARY KEY CLUSTERED ([PRDA_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Detail_Altered] ADD CONSTRAINT [FK_Permit_Route_Detail_Altered_Permit_Route] FOREIGN KEY ([PRTA_ID]) REFERENCES [dbo].[Permit_Route_Altered] ([PRTA_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Route_Detail_Altered] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Route_Detail_Altered] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Route_Detail_Altered] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Route_Detail_Altered] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Route_Detail_Altered] TO [public]
GO
