CREATE TABLE [dbo].[OrderImportDedicated]
(
[CustID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustName] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadID] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationCity] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationState] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationZip] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNumber] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalTime] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartureTime] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DeliveryDate] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[importdate] [datetime] NULL,
[fileseq] [int] NULL,
[sfilename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[OrderImportDedicated] TO [public]
GO
GRANT INSERT ON  [dbo].[OrderImportDedicated] TO [public]
GO
GRANT REFERENCES ON  [dbo].[OrderImportDedicated] TO [public]
GO
GRANT SELECT ON  [dbo].[OrderImportDedicated] TO [public]
GO
GRANT UPDATE ON  [dbo].[OrderImportDedicated] TO [public]
GO
