CREATE TABLE [dbo].[TMSRegion]
(
[RegId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RawData] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TMSRegion] ADD CONSTRAINT [PK_TMSRegion] PRIMARY KEY CLUSTERED ([RegId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TMSRegion] TO [public]
GO
GRANT INSERT ON  [dbo].[TMSRegion] TO [public]
GO
GRANT SELECT ON  [dbo].[TMSRegion] TO [public]
GO
GRANT UPDATE ON  [dbo].[TMSRegion] TO [public]
GO
