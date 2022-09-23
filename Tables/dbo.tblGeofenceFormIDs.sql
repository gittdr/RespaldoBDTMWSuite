CREATE TABLE [dbo].[tblGeofenceFormIDs]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[GF_SN] [int] NOT NULL,
[Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ItemID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Item] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormID] [int] NULL,
[MCID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblGeofenceFormIDs] ADD CONSTRAINT [GeofenceFormID_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GeofenceFormID_Main] ON [dbo].[tblGeofenceFormIDs] ([GF_SN], [Type], [ItemID], [FormID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblGeofenceFormIDs] TO [public]
GO
GRANT INSERT ON  [dbo].[tblGeofenceFormIDs] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblGeofenceFormIDs] TO [public]
GO
GRANT SELECT ON  [dbo].[tblGeofenceFormIDs] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblGeofenceFormIDs] TO [public]
GO
