CREATE TABLE [dbo].[notesiconrulesmodes]
(
[nrm_id] [int] NOT NULL IDENTITY(1, 1),
[nrm_mode_id] [int] NULL,
[nrm_nir_id] [int] NULL,
[nrm_created_date] [datetime] NULL,
[nrm_created_user] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[notesiconrulesmodes] ADD CONSTRAINT [PK_notesiconrulesmodes] PRIMARY KEY CLUSTERED ([nrm_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[notesiconrulesmodes] TO [public]
GO
GRANT INSERT ON  [dbo].[notesiconrulesmodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[notesiconrulesmodes] TO [public]
GO
GRANT SELECT ON  [dbo].[notesiconrulesmodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[notesiconrulesmodes] TO [public]
GO
