CREATE TABLE [dbo].[MasterBillStyle]
(
[MasterBillStyleId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__Creat__185221E6] DEFAULT (suser_name()),
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__Creat__1946461F] DEFAULT (getdate()),
[LastUpdateDate] [datetime] NOT NULL CONSTRAINT [DF__MasterBil__LastU__1A3A6A58] DEFAULT (getdate()),
[LastUpdateBy] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__MasterBil__LastU__1B2E8E91] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MasterBillStyle] ADD CONSTRAINT [PK_dbo.MasterBillStyle] PRIMARY KEY CLUSTERED ([MasterBillStyleId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MasterBillStyle] TO [public]
GO
GRANT INSERT ON  [dbo].[MasterBillStyle] TO [public]
GO
GRANT SELECT ON  [dbo].[MasterBillStyle] TO [public]
GO
GRANT UPDATE ON  [dbo].[MasterBillStyle] TO [public]
GO
