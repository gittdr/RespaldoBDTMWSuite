CREATE TABLE [dbo].[GP_MEMSetup]
(
[gp_mem_id] [int] NOT NULL IDENTITY(1, 1),
[gp_mem_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_mem_gl_start] [int] NULL,
[gp_mem_gl_length] [int] NULL,
[gp_mem_customer_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_mem_vendor_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gp_mem_entity_id] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GP_MEMSetup] ADD CONSTRAINT [GP_MEM_id] PRIMARY KEY CLUSTERED ([gp_mem_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[GP_MEMSetup] TO [public]
GO
GRANT INSERT ON  [dbo].[GP_MEMSetup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[GP_MEMSetup] TO [public]
GO
GRANT SELECT ON  [dbo].[GP_MEMSetup] TO [public]
GO
GRANT UPDATE ON  [dbo].[GP_MEMSetup] TO [public]
GO
