CREATE TABLE [dbo].[MobileCommMessageDateType]
(
[MessageDateTypeId] [int] NOT NULL,
[Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommMessageDateType] ADD CONSTRAINT [PK_MobileCommMessageDateType] PRIMARY KEY CLUSTERED ([MessageDateTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommMessageDateType] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommMessageDateType] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommMessageDateType] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommMessageDateType] TO [public]
GO
