CREATE TABLE [dbo].[MobileCommDirection]
(
[DirectionId] [int] NOT NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommDirection] ADD CONSTRAINT [PK_MobileCommDirection] PRIMARY KEY CLUSTERED ([DirectionId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommDirection] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommDirection] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommDirection] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommDirection] TO [public]
GO
