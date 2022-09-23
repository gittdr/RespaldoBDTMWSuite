CREATE TABLE [dbo].[tblCEData]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[tractorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unitAddress] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventDateTime] [datetime] NOT NULL,
[orderNbr] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trailerID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driverID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[eventLocation] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[criticalEvent] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedOn] [datetime] NOT NULL,
[eventKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__tblCEData__event__1275501D] DEFAULT ((0)),
[parentMsg] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCEData] ADD CONSTRAINT [PK_tblCEData] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCEData_Driver_Date] ON [dbo].[tblCEData] ([driverID], [eventDateTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tblCEData_Tractor_Date] ON [dbo].[tblCEData] ([tractorID], [eventDateTime]) ON [PRIMARY]
GO
