CREATE TABLE [dbo].[CarrierCsaDocument]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[docid] [int] NOT NULL,
[doctype] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[provider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[car_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[external_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime2] NULL CONSTRAINT [df_CarrierCsaDocument_lastupdatedate] DEFAULT (getdate()),
[lastupdateuser] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_CarrierCsaDocument_lastupdateuser] DEFAULT (suser_sname()),
[createddate] [datetime2] NULL CONSTRAINT [df_CarrierCsaDocument_createddate] DEFAULT (getdate()),
[createdby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [df_CarrierCsaDocument_createdby] DEFAULT (user_name())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CarrierCsaDocument] ADD CONSTRAINT [pk_CarrierCsaDocument] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[CarrierCsaDocument] TO [public]
GO
GRANT INSERT ON  [dbo].[CarrierCsaDocument] TO [public]
GO
GRANT REFERENCES ON  [dbo].[CarrierCsaDocument] TO [public]
GO
GRANT SELECT ON  [dbo].[CarrierCsaDocument] TO [public]
GO
GRANT UPDATE ON  [dbo].[CarrierCsaDocument] TO [public]
GO
