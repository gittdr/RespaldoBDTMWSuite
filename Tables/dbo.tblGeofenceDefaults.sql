CREATE TABLE [dbo].[tblGeofenceDefaults]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ID_Type] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Event] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Radius] [decimal] (7, 2) NULL,
[Radius_Units] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Latitude_seconds] [int] NULL,
[Longitude_seconds] [int] NULL,
[Begin_Early_Tolerance_min] [int] NULL,
[Begin_Late_Tolerance_min] [int] NULL,
[Arrive_Early_Tolerance_min] [int] NULL,
[Arrive_Late_Tolerance_min] [int] NULL,
[Depart_Early_Tolerance_min] [int] NULL,
[Depart_Late_Tolerance_min] [int] NULL,
[DepartTimeOut] [int] NULL,
[MCVendor] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGeofenceDefaults] ADD CONSTRAINT [Geofence_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Geofence_Main] ON [dbo].[tblGeofenceDefaults] ([ID], [ID_Type], [Event], [Type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblGeofenceDefaults] TO [public]
GO
GRANT INSERT ON  [dbo].[tblGeofenceDefaults] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblGeofenceDefaults] TO [public]
GO
GRANT SELECT ON  [dbo].[tblGeofenceDefaults] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblGeofenceDefaults] TO [public]
GO
