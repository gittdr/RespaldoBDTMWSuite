CREATE TABLE [dbo].[tmwams_auditpaydetail]
(
[auditid] [int] NOT NULL IDENTITY(1, 1),
[amspoinvoicid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amsorderid] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amsordernumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[suiteleg] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[roadcall] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driver] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unidad] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[amtbilled] [float] NULL,
[fechaanticipo] [datetime] NULL,
[comprobado] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fechacomprobado] [datetime] NULL
) ON [PRIMARY]
GO
