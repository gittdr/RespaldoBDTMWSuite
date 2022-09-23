CREATE TABLE [dbo].[expp2_log]
(
[fechasnap] [datetime] NULL,
[semana] [int] NULL,
[tractor] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[flota] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[expdate] [datetime] NULL,
[dif] [int] NULL,
[status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exp_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[semanastring] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[type] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
