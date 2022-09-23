CREATE TABLE [dbo].[tblCEDriverResponse]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[tractorID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driverID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[unitAddress] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[driverResponseDateTime] [datetime] NOT NULL,
[driverResponse] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[updatedOn] [datetime] NOT NULL,
[eventKey] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCEDriverResponse] ADD CONSTRAINT [PK_tblCEDriverResponse] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
