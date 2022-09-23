CREATE TABLE [dbo].[tblHistory]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[DriverSN] [int] NULL,
[TruckSN] [int] NULL,
[MsgSN] [int] NULL,
[Chached] [bit] NOT NULL CONSTRAINT [DF_tblHistory_Chached] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHistory] ADD CONSTRAINT [pk_tblHistorynew] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHistory] ADD CONSTRAINT [FK__Temporary__Drive__4A2E0B0B1] FOREIGN KEY ([DriverSN]) REFERENCES [dbo].[tblDrivers] ([SN])
GO
ALTER TABLE [dbo].[tblHistory] ADD CONSTRAINT [FK__Temporary__MsgSN__4C16537D1] FOREIGN KEY ([MsgSN]) REFERENCES [dbo].[tblMessages] ([SN])
GO
ALTER TABLE [dbo].[tblHistory] ADD CONSTRAINT [FK__Temporary__Truck__4B222F441] FOREIGN KEY ([TruckSN]) REFERENCES [dbo].[tblTrucks] ([SN])
GO
