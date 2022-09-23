CREATE TABLE [dbo].[Permit_Route]
(
[PRT_ID] [int] NOT NULL IDENTITY(1, 1),
[PIA_ID] [int] NOT NULL,
[PRT_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PRT_OriginCounty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginNmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginCity] [int] NULL,
[PRT_OriginState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginRoute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginDirection] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_OriginMilesBefore] [int] NULL,
[PRT_DestinationCounty] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationNmstct] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationCity] [int] NULL,
[PRT_DestinationState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationRoute] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationDirection] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationIntersection] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_DestinationMilesAfter] [int] NULL,
[prt_origincompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prt_destinationcompany] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PRT_timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route] ADD CONSTRAINT [PK_Permit_Route] PRIMARY KEY CLUSTERED ([PRT_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route] ADD CONSTRAINT [IX_Permit_Route_PRT_Name] UNIQUE NONCLUSTERED ([PRT_Name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permit_Route] ADD CONSTRAINT [FK_Permit_Route_Permit_Issuing_Authority] FOREIGN KEY ([PIA_ID]) REFERENCES [dbo].[Permit_Issuing_Authority] ([PIA_ID])
GO
GRANT DELETE ON  [dbo].[Permit_Route] TO [public]
GO
GRANT INSERT ON  [dbo].[Permit_Route] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permit_Route] TO [public]
GO
GRANT SELECT ON  [dbo].[Permit_Route] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permit_Route] TO [public]
GO
