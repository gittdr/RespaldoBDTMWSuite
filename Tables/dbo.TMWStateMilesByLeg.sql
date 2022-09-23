CREATE TABLE [dbo].[TMWStateMilesByLeg]
(
[stmlsleg_originlocation] [int] NOT NULL,
[stmlsleg_destinationlocation] [int] NOT NULL,
[stmlsleg_legtype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stmlsleg_mileageinterface] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stmlsleg_mileageinterfaceversion] [float] NOT NULL,
[stmlsleg_mileagetype] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stmlsleg_origincitystateorzip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stmlsleg_destinationcitystateorzip] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stmlsleg_originzip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stmlsleg_destinationzip] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stmlsleg_state] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stmlsleg_statetotalmiles] [float] NULL,
[stmlsleg_statetollmiles] [float] NULL,
[stmlsleg_statefreemiles] [float] NULL,
[stmlsleg_stateferrymiles] [float] NULL,
[stmlsleg_lookupstatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stmlsleg_errdescription] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMWStateMilesByLeg] ADD CONSTRAINT [PK_TMWStateMilesByLeg] PRIMARY KEY CLUSTERED ([stmlsleg_originlocation], [stmlsleg_destinationlocation], [stmlsleg_legtype], [stmlsleg_mileageinterface], [stmlsleg_mileageinterfaceversion], [stmlsleg_mileagetype], [stmlsleg_state]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMWStateMilesByLeg] TO [public]
GO
GRANT INSERT ON  [dbo].[TMWStateMilesByLeg] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TMWStateMilesByLeg] TO [public]
GO
GRANT SELECT ON  [dbo].[TMWStateMilesByLeg] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMWStateMilesByLeg] TO [public]
GO
