CREATE TABLE [dbo].[CarrierHubIVRUserMapping]
(
[CarrierHubUser] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IVRID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IVRPassword] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedDate] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastLoginDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierHubIVRUserMapping] ADD CONSTRAINT [PK_CarrierHubUserMapping] PRIMARY KEY CLUSTERED ([CarrierHubUser]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_CarrierHubIVRUserMapping_IVRID] ON [dbo].[CarrierHubIVRUserMapping] ([IVRID]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierHubIVRUserMapping] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierHubIVRUserMapping] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierHubIVRUserMapping] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierHubIVRUserMapping] TO [public]
GO
