CREATE TABLE [dbo].[WebSystemsLinkPublicKey]
(
[PublicKeyID] [int] NOT NULL,
[PublicKey] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SignedKeyBase64] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Source] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WebSystemsLinkPublicKey] ADD CONSTRAINT [PK_WebSystemsLinkPublicKey] PRIMARY KEY CLUSTERED ([PublicKeyID]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[WebSystemsLinkPublicKey] TO [public]
GO
