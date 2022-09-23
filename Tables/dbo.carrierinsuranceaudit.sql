CREATE TABLE [dbo].[carrierinsuranceaudit]
(
[cia_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cai_insurance_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cia_action] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cia_update_dt] [datetime] NULL,
[cia_update_by] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cia_update_field] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cia_original_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cia_new_value] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierinsuranceaudit] ADD CONSTRAINT [pk_carrierinsuranceaudit_cia_id] PRIMARY KEY CLUSTERED ([cia_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierinsuranceaudit_car_id] ON [dbo].[carrierinsuranceaudit] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierinsuranceaudit] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierinsuranceaudit] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierinsuranceaudit] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierinsuranceaudit] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierinsuranceaudit] TO [public]
GO
