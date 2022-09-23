CREATE TABLE [dbo].[DOE_FUEL_EXTRACT_LSD]
(
[FuelDate] [datetime] NULL,
[UsAvg] [money] NULL,
[EastCoast] [money] NULL,
[NewEngland] [money] NULL,
[CentralAtlantic] [money] NULL,
[LowerAtlantic] [money] NULL,
[Midwest] [money] NULL,
[GulfCoast] [money] NULL,
[RockyMountain] [money] NULL,
[WestCoast] [money] NULL,
[CA] [money] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DOE_FUEL_EXTRACT_LSD] TO [public]
GO
GRANT INSERT ON  [dbo].[DOE_FUEL_EXTRACT_LSD] TO [public]
GO
GRANT SELECT ON  [dbo].[DOE_FUEL_EXTRACT_LSD] TO [public]
GO
GRANT UPDATE ON  [dbo].[DOE_FUEL_EXTRACT_LSD] TO [public]
GO
