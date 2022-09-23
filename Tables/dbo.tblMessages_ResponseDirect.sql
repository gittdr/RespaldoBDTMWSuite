CREATE TABLE [dbo].[tblMessages_ResponseDirect]
(
[Id] [int] NOT NULL,
[IdHandleResponse] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IdResponse] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Mensaje] [varchar] (5000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Fecha] [datetime] NULL
) ON [PRIMARY]
GO
