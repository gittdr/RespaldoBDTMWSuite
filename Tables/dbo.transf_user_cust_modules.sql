CREATE TABLE [dbo].[transf_user_cust_modules]
(
[transf_user_id] [int] NOT NULL,
[module_id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[module_name] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[edit_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transf_user_cust_modules] ADD CONSTRAINT [PK_transf_user_modules] PRIMARY KEY CLUSTERED ([transf_user_id], [module_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[transf_user_cust_modules] TO [public]
GO
GRANT INSERT ON  [dbo].[transf_user_cust_modules] TO [public]
GO
GRANT SELECT ON  [dbo].[transf_user_cust_modules] TO [public]
GO
GRANT UPDATE ON  [dbo].[transf_user_cust_modules] TO [public]
GO
