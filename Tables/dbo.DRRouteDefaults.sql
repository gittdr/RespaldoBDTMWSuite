CREATE TABLE [dbo].[DRRouteDefaults]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ColumnName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CompanyName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Longitude] [int] NULL,
[Latitude] [int] NULL,
[Available] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OneWay] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Redispatch] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weight] [decimal] (10, 2) NULL,
[Cubes] [int] NULL,
[Pallets] [int] NULL,
[MinTm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TurnTm] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UnldPerf] [int] NULL,
[MiCost] [decimal] (10, 2) NULL,
[HrCost] [decimal] (10, 2) NULL,
[OTCost1] [money] NULL,
[OTCost2] [money] NULL,
[OTCost3] [money] NULL,
[OTCost4] [money] NULL,
[OTHrs1] [int] NULL,
[OTHrs2] [int] NULL,
[OTHrs3] [int] NULL,
[OTHrs4] [int] NULL,
[UnldHrCost] [decimal] (10, 2) NULL,
[DropCost] [decimal] (10, 2) NULL,
[WaitHrCost] [decimal] (10, 2) NULL,
[UnitCost] [decimal] (10, 2) NULL,
[FixedCost] [decimal] (10, 2) NULL,
[LayoverCost] [decimal] (10, 2) NULL,
[LatStart] [int] NULL,
[WorkDay] [int] NULL,
[NormalStart] [datetime] NULL,
[Brk1Start] [int] NULL,
[Brk1Duration] [decimal] (18, 5) NULL,
[Brk2Start] [int] NULL,
[Brk2Duration] [decimal] (18, 5) NULL,
[Brk3Start] [int] NULL,
[Brk3Duration] [decimal] (18, 5) NULL,
[Brk4Start] [int] NULL,
[Brk4Duration] [decimal] (18, 5) NULL,
[Brk5Start] [int] NULL,
[Brk5Duration] [decimal] (18, 5) NULL,
[MaxWorkTm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TargetWrkTm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxDriveTm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinLayoverTm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxLayover] [int] NULL,
[MaxDrvTmB4Layover] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxLayovers] [int] NULL,
[Zone] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Symbol] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Size] [int] NULL,
[Color] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PreTripTm] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostTrip] [int] NULL,
[AMStart] [datetime] NULL,
[AMEnd] [datetime] NULL,
[AMAdj] [int] NULL,
[PMStart] [int] NULL,
[PMEnd] [int] NULL,
[PMAdj] [int] NULL,
[useTMWLatitudeAndLongitude] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DRRouteDefaults] ADD CONSTRAINT [PK_DRRoutedefaults] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DRRouteDefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[DRRouteDefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DRRouteDefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[DRRouteDefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[DRRouteDefaults] TO [public]
GO
