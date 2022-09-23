CREATE TABLE [dbo].[MR_ObjectSecureFields]
(
[secfld_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[secfld_object] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[secfld_scanYN] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MR_ObjectSecureFields] ADD CONSTRAINT [PK_MR_ObjectSecureFields] PRIMARY KEY CLUSTERED ([secfld_object], [secfld_name]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[MR_ObjectSecureFields] TO [public]
GO
