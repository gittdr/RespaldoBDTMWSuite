CREATE TABLE [dbo].[RateQuotes]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[BillToID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OriginCompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginCityCode] [int] NULL,
[OriginState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginPostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OriginCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationCompanyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationCityCode] [int] NULL,
[DestinationState] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationPostalCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationCountry] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PickupDate] [date] NOT NULL,
[DeliveryDate] [date] NOT NULL,
[CreatedDateTime] [datetime] NOT NULL,
[CreateByUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[RateQuotes] TO [public]
GO
GRANT INSERT ON  [dbo].[RateQuotes] TO [public]
GO
GRANT SELECT ON  [dbo].[RateQuotes] TO [public]
GO
GRANT UPDATE ON  [dbo].[RateQuotes] TO [public]
GO
