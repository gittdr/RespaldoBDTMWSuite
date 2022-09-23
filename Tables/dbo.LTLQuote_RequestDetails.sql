CREATE TABLE [dbo].[LTLQuote_RequestDetails]
(
[QuoteID] [bigint] NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_QuoteID] DEFAULT ((0)),
[BillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_BillTo] DEFAULT (''),
[PickupDate] [datetime] NULL,
[Shipper] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_Shipper] DEFAULT (''),
[ShipperCtyCode] [int] NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ShipperCtyCode] DEFAULT ((0)),
[ShipperState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ShipperState] DEFAULT ('XX'),
[ShipperZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ShipperZipCode] DEFAULT (''),
[Consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_Consignee] DEFAULT (''),
[ConsigneeCtyCode] [int] NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ConsigneeCtyCode] DEFAULT ((0)),
[ConsigneeZipCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ConsigneeZipCode] DEFAULT (''),
[ConsigneeState] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestDetails_ConsigneeState] DEFAULT ('XX'),
[CarrierID] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LTLQuote_RequestDetails_CarrierID] DEFAULT (NULL),
[DeclaredValue] [money] NOT NULL CONSTRAINT [DF__LTLQuote___Decla__501D1D76] DEFAULT ((0)),
[ShipperDeliveryNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Shipp__511141AF] DEFAULT (''),
[ConsigneeDeliveryNotes] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Consi__520565E8] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTLQuote_RequestDetails] TO [public]
GO
GRANT INSERT ON  [dbo].[LTLQuote_RequestDetails] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTLQuote_RequestDetails] TO [public]
GO
GRANT SELECT ON  [dbo].[LTLQuote_RequestDetails] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTLQuote_RequestDetails] TO [public]
GO
