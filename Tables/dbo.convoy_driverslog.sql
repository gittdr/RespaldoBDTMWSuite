CREATE TABLE [dbo].[convoy_driverslog]
(
[UniqueID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OSVersion] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MobileClientVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastAccessAt] [datetime] NULL,
[DaysLoggedIn] [int] NULL,
[DocumentsScanned] [int] NULL
) ON [PRIMARY]
GO
