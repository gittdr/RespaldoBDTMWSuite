CREATE TABLE [dbo].[tariff_expired_report]
(
[ord_billto] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_completiondate] [datetime] NULL,
[ord_totalcharge] [float] NULL,
[ord_shipper] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_consignee] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciudadorigen] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ciudaddestino] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_origincity] [int] NULL,
[ord_destcity] [int] NULL,
[copiade] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tarifa] [int] NULL,
[row] [int] NULL,
[column] [int] NULL,
[vencio] [datetime] NULL,
[updated_on] [datetime] NULL,
[updated_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
