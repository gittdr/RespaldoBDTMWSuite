CREATE TABLE [dbo].[TmwGPProfileCardMapping]
(
[AccountingProfileMappingId] [int] NOT NULL IDENTITY(1, 1),
[SequenceNumber] [int] NOT NULL,
[Source1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Field1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Field2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SyncType] [int] NOT NULL,
[OverrideBlank] [bit] NOT NULL CONSTRAINT [df_TmwGPProfileCardMapping_OverrideBlank] DEFAULT ((0)),
[UpdateType] [int] NOT NULL,
[LastUpdateDate] [datetime2] (3) NULL CONSTRAINT [df_TmwGPProfileCardMapping_LastUpdateDate] DEFAULT (getdate()),
[LastUpdateBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_TmwGPProfileCardMapping_LastUpdateBy] DEFAULT (suser_name()),
[CreatedDate] [datetime2] (3) NULL CONSTRAINT [df_TmwGPProfileCardMapping_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_TmwGPProfileCardMapping_CreatedBy] DEFAULT (suser_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TmwGPProfileCardMapping] ADD CONSTRAINT [ix_TmwGPProfileCardMapping_AccountingProfileMappingId] PRIMARY KEY CLUSTERED ([AccountingProfileMappingId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TmwGPProfileCardMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[TmwGPProfileCardMapping] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TmwGPProfileCardMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[TmwGPProfileCardMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[TmwGPProfileCardMapping] TO [public]
GO
