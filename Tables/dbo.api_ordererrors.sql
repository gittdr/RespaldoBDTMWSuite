CREATE TABLE [dbo].[api_ordererrors]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[norder] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msg] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[created_at] [datetime] NULL CONSTRAINT [DF__api_order__creat__0835EC25] DEFAULT (getdate())
) ON [PRIMARY]
GO
