CREATE TABLE [dbo].[company_delivery_instructions]
(
[cdi_id] [int] NOT NULL IDENTITY(1, 1),
[cdi_company] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_commodity] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_stop_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_desc] [varchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_createdt] [datetime] NULL,
[cdi_lastupdateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdi_lastupdatedt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[company_delivery_instructions] ADD CONSTRAINT [pk_cdi_id] PRIMARY KEY CLUSTERED ([cdi_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_cdi_company] ON [dbo].[company_delivery_instructions] ([cdi_company]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [dk_cdi_id] ON [dbo].[company_delivery_instructions] ([cdi_company], [cdi_commodity], [cdi_stop_type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[company_delivery_instructions] TO [public]
GO
GRANT INSERT ON  [dbo].[company_delivery_instructions] TO [public]
GO
GRANT SELECT ON  [dbo].[company_delivery_instructions] TO [public]
GO
GRANT UPDATE ON  [dbo].[company_delivery_instructions] TO [public]
GO
