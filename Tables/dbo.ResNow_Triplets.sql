CREATE TABLE [dbo].[ResNow_Triplets]
(
[sn] [int] NOT NULL IDENTITY(1, 1),
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[ord_hdrnumber] [int] NULL,
[lgh_tractor] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer1] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer2] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_totalmiles] [float] NULL,
[ord_bookdate] [datetime] NULL,
[ord_startdate] [datetime] NULL,
[ord_completiondate] [datetime] NULL,
[lgh_startdate] [datetime] NULL,
[lgh_enddate] [datetime] NULL,
[LegTravelMiles] [float] NULL,
[LegLoadedMiles] [float] NULL,
[LegEmptyMiles] [float] NULL,
[MoveStartDate] [datetime] NULL,
[MoveEndDate] [datetime] NULL,
[MoveCreateDate] [datetime] NULL,
[CountOfOrdersOnThisLeg] [float] NULL,
[CountOfLegsForThisOrder] [float] NULL,
[GrossLegMilesForOrder] [float] NULL,
[GrossLDLegMilesForOrder] [float] NULL,
[GrossBillMilesForLeg] [float] NULL,
[Date_Updated] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ResNow_Triplets] ADD CONSTRAINT [AutoPK_ResNow_Triplets_SN] PRIMARY KEY CLUSTERED ([sn]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_lghenddate] ON [dbo].[ResNow_Triplets] ([lgh_enddate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_lghendstart] ON [dbo].[ResNow_Triplets] ([lgh_enddate], [lgh_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_lghnumber] ON [dbo].[ResNow_Triplets] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_lghstartdate] ON [dbo].[ResNow_Triplets] ([lgh_startdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_movnumber] ON [dbo].[ResNow_Triplets] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_MoveEndDate] ON [dbo].[ResNow_Triplets] ([MoveEndDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_MoveStartDate] ON [dbo].[ResNow_Triplets] ([MoveStartDate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_BookDate] ON [dbo].[ResNow_Triplets] ([ord_bookdate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_ordcompletiondate] ON [dbo].[ResNow_Triplets] ([ord_completiondate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_ordhdrnumber] ON [dbo].[ResNow_Triplets] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ResNowTriplets_ordstartdate] ON [dbo].[ResNow_Triplets] ([ord_startdate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ResNow_Triplets] TO [public]
GO
GRANT INSERT ON  [dbo].[ResNow_Triplets] TO [public]
GO
GRANT SELECT ON  [dbo].[ResNow_Triplets] TO [public]
GO
GRANT UPDATE ON  [dbo].[ResNow_Triplets] TO [public]
GO
