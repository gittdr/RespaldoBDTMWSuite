CREATE TABLE [dbo].[tblHistory_archive]
(
[SN] [int] NOT NULL,
[DriverSN] [int] NULL,
[TruckSN] [int] NULL,
[MsgSN] [int] NULL,
[Chached] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHistory_archive] ADD CONSTRAINT [PK_tblHistory_archive] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
