CREATE TABLE [dbo].[InterestTypeLookup]
(
[Id] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InterestTypeLookup] ADD CONSTRAINT [PK_dbo.InterestTypeLookup] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
