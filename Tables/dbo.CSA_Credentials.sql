CREATE TABLE [dbo].[CSA_Credentials]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[EncryptedCredentials] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DOT] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedOn] [datetime] NOT NULL,
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UpdatedOn] [datetime] NULL,
[UpdatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CSA_Credentials] ADD CONSTRAINT [PK_CSA_Credentials] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
GRANT INSERT ON  [dbo].[CSA_Credentials] TO [public]
GO
GRANT SELECT ON  [dbo].[CSA_Credentials] TO [public]
GO
GRANT UPDATE ON  [dbo].[CSA_Credentials] TO [public]
GO
