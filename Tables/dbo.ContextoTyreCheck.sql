CREATE TABLE [dbo].[ContextoTyreCheck]
(
[idContextoTyreCheck] [int] NOT NULL IDENTITY(1, 1),
[Fleet] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Taller] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FleetName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationName] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
