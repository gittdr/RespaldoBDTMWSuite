CREATE TABLE [dbo].[carrierdiversityclasses]
(
[cdc_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cdc_business_class] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cdc_comment] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrierdiversityclasses] ADD CONSTRAINT [pk_carrierdiversityclasses_cdc_id] PRIMARY KEY CLUSTERED ([cdc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierdiversityclasses_car_id] ON [dbo].[carrierdiversityclasses] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierdiversityclasses] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierdiversityclasses] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierdiversityclasses] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierdiversityclasses] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierdiversityclasses] TO [public]
GO
