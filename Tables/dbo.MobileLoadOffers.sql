CREATE TABLE [dbo].[MobileLoadOffers]
(
[Id] [bigint] NOT NULL IDENTITY(1, 1),
[LegNumber] [int] NOT NULL,
[OrderHeaderNumber] [int] NOT NULL,
[AsgnId] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AsgnTypeId] [smallint] NOT NULL,
[DispatcherId] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StatusTypeId] [smallint] NOT NULL,
[OfferDate] [datetime] NOT NULL,
[AcknowledgeDate] [datetime] NULL,
[RejectReason] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Comment] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileLoadOffers] ADD CONSTRAINT [PK_MobileLoadOffers] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileLoadOffers] ADD CONSTRAINT [FK_MobileLoadOffers_MobileAssignmentTypes] FOREIGN KEY ([AsgnTypeId]) REFERENCES [dbo].[MobileAssignmentTypes] ([Id])
GO
ALTER TABLE [dbo].[MobileLoadOffers] ADD CONSTRAINT [FK_MobileLoadOffers_MobileOfferStatusTypes] FOREIGN KEY ([StatusTypeId]) REFERENCES [dbo].[MobileOfferStatusTypes] ([Id])
GO
GRANT DELETE ON  [dbo].[MobileLoadOffers] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileLoadOffers] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileLoadOffers] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileLoadOffers] TO [public]
GO
