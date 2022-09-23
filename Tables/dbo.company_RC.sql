CREATE TABLE [dbo].[company_RC]
(
[tmw_company_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rc_nombre_cmp] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_RC] ADD CONSTRAINT [PK__company_RC__5DC2C805] PRIMARY KEY CLUSTERED ([tmw_company_id]) ON [PRIMARY]
GO
