CREATE TABLE [dbo].[InvServicesMapping]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[RecordType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MappingType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Key1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TMWKey1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_InvServicesMapping_ModifiedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_InvServicesMapping_CreatedDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvServicesMapping] ADD CONSTRAINT [PK_InvServicesMapping] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvServicesMapping] ADD CONSTRAINT [IX_InvServicesMapping] UNIQUE NONCLUSTERED ([RecordType], [MappingType], [Key1]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[InvServicesMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[InvServicesMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[InvServicesMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvServicesMapping] TO [public]
GO
