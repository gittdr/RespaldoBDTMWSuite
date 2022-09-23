CREATE TABLE [dbo].[tblFilterTrucks]
(
[ftr_ID] [int] NOT NULL,
[ftr_TruckID] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblFilterTrucks] ON [dbo].[tblFilterTrucks] ([ftr_ID], [ftr_TruckID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblFilterTrucks] TO [public]
GO
GRANT INSERT ON  [dbo].[tblFilterTrucks] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblFilterTrucks] TO [public]
GO
GRANT SELECT ON  [dbo].[tblFilterTrucks] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblFilterTrucks] TO [public]
GO
