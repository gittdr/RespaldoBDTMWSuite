CREATE TABLE [dbo].[MobileOfferStatusTypes]
(
[Id] [smallint] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileOfferStatusTypes] ADD CONSTRAINT [PK_MobileOfferStatusTypes] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileOfferStatusTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileOfferStatusTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileOfferStatusTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileOfferStatusTypes] TO [public]
GO
