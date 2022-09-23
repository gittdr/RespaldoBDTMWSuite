CREATE TABLE [dbo].[DatePropertyType]
(
[DatePropertyTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DatePrope__Creat__586CA6FB] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__DatePrope__Creat__5960CB34] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__DatePrope__LastU__5A54EF6D] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__DatePrope__LastU__5B4913A6] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DatePropertyType] ADD CONSTRAINT [PK_dbo.DatePropertyType] PRIMARY KEY CLUSTERED ([DatePropertyTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DatePropertyType] TO [public]
GO
GRANT INSERT ON  [dbo].[DatePropertyType] TO [public]
GO
GRANT SELECT ON  [dbo].[DatePropertyType] TO [public]
GO
GRANT UPDATE ON  [dbo].[DatePropertyType] TO [public]
GO
