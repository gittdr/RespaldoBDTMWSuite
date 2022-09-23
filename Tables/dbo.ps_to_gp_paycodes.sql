CREATE TABLE [dbo].[ps_to_gp_paycodes]
(
[psgp_PS_paycode] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psgp_GP_paycode] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psgp_GP_reltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psgp_identity] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ps_to_gp_paycodes] ADD CONSTRAINT [pk_ps_to_gp_paycodes] PRIMARY KEY CLUSTERED ([psgp_PS_paycode], [psgp_GP_paycode]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_pstogpid] ON [dbo].[ps_to_gp_paycodes] ([psgp_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ps_to_gp_paycodes] TO [public]
GO
GRANT INSERT ON  [dbo].[ps_to_gp_paycodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ps_to_gp_paycodes] TO [public]
GO
GRANT SELECT ON  [dbo].[ps_to_gp_paycodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[ps_to_gp_paycodes] TO [public]
GO
