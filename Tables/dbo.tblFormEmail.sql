CREATE TABLE [dbo].[tblFormEmail]
(
[IdFormEmail] [int] NOT NULL IDENTITY(1, 1),
[IdForm] [int] NULL,
[Email] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Telefono] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
