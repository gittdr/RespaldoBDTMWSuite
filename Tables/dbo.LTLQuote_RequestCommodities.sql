CREATE TABLE [dbo].[LTLQuote_RequestCommodities]
(
[QuoteID] [bigint] NOT NULL CONSTRAINT [DF_LTLQuote_RequestCommodities_QuoteID] DEFAULT ((0)),
[NMFC] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestCommodities_NMFC] DEFAULT (''),
[Weight] [decimal] (12, 2) NOT NULL CONSTRAINT [DF_LTLQuote_RequestCommodities_Weight] DEFAULT ((0)),
[WeightUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LTLQuote_RequestCommodities_WeightUnits] DEFAULT (''),
[Height] [decimal] (12, 2) NOT NULL CONSTRAINT [DF__LTLQuote___Heigh__52F98A21] DEFAULT ((0)),
[HeightUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Heigh__53EDAE5A] DEFAULT (''),
[Width] [decimal] (12, 2) NOT NULL CONSTRAINT [DF__LTLQuote___Width__54E1D293] DEFAULT ((0)),
[WidthUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Width__55D5F6CC] DEFAULT (''),
[Length] [decimal] (12, 2) NOT NULL CONSTRAINT [DF__LTLQuote___Lengt__56CA1B05] DEFAULT ((0)),
[LengthUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Lengt__57BE3F3E] DEFAULT (''),
[Count] [decimal] (12, 2) NOT NULL CONSTRAINT [DF__LTLQuote___Count__58B26377] DEFAULT ((0)),
[CountUnits] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Count__59A687B0] DEFAULT (''),
[Hazardous] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Hazar__5A9AABE9] DEFAULT ('N'),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__LTLQuote___Descr__5B8ED022] DEFAULT ('')
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LTLQuote_RequestCommodities] TO [public]
GO
GRANT INSERT ON  [dbo].[LTLQuote_RequestCommodities] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LTLQuote_RequestCommodities] TO [public]
GO
GRANT SELECT ON  [dbo].[LTLQuote_RequestCommodities] TO [public]
GO
GRANT UPDATE ON  [dbo].[LTLQuote_RequestCommodities] TO [public]
GO
