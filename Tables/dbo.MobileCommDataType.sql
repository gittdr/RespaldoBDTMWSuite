CREATE TABLE [dbo].[MobileCommDataType]
(
[DatatypeId] [int] NOT NULL,
[Datatype] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileCommDataType] ADD CONSTRAINT [PK_dbo_MobileCommDataType] PRIMARY KEY CLUSTERED ([DatatypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileCommDataType] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileCommDataType] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileCommDataType] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileCommDataType] TO [public]
GO
