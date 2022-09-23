CREATE TABLE [dbo].[carrierequipment]
(
[ceq_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceq_equipment_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ceq_units] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierequipment] ADD CONSTRAINT [pk_carrierequipment_ceq_id] PRIMARY KEY CLUSTERED ([ceq_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierequipment_car_id] ON [dbo].[carrierequipment] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierequipment] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierequipment] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierequipment] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierequipment] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierequipment] TO [public]
GO
