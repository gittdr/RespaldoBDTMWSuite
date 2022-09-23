CREATE TABLE [dbo].[Permit_Route_Altered]
(
[PRTA_ID] [int] NOT NULL IDENTITY(1, 1),
[P_ID] [int] NOT NULL,
[PRTA_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginCounty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginNmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginCity] [int] NULL,
[PRTA_OriginState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginRoute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginDirection] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_OriginMilesBefore] [int] NULL,
[PRTA_DestinationCounty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationNmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationCity] [int] NULL,
[PRTA_DestinationState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationRoute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationDirection] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRTA_DestinationMilesAfter] [int] NULL,
[prta_origincompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prta_destinationcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Altered] ADD CONSTRAINT [PK_Permit_Route_Altered] PRIMARY KEY CLUSTERED ([PRTA_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_Permit_Route_Altered] ON [dbo].[Permit_Route_Altered] ([P_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route_Altered] ADD CONSTRAINT [FK_Permit_Route_Permits] FOREIGN KEY ([P_ID]) REFERENCES [dbo].[Permits] ([P_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Route_Altered] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Route_Altered] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Route_Altered] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Route_Altered] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Route_Altered] TO [public]
GO
