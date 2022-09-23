CREATE TABLE [dbo].[ProductMarkupProfile]
(
[MarkupType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AmountType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Amount] [decimal] (18, 4) NOT NULL CONSTRAINT [DF_ProductMarkupProfile_Amount] DEFAULT ((0.0000)),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarkupProfile_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarkupProfile_ModifiedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupProfile] ADD CONSTRAINT [PK_ProductMarkupProfile] PRIMARY KEY CLUSTERED ([MarkupType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductMarkupProfile] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductMarkupProfile] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductMarkupProfile] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductMarkupProfile] TO [public]
GO
