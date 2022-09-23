CREATE TABLE [dbo].[MasterBillType]
(
[MasterBillTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__12994890] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__138D6CC9] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__14819102] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__1575B53B] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillType] ADD CONSTRAINT [PK_dbo.MasterBillType] PRIMARY KEY CLUSTERED ([MasterBillTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MasterBillType] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillType] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillType] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillType] TO [public]
GO
