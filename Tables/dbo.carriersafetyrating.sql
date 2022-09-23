CREATE TABLE [dbo].[carriersafetyrating]
(
[csr_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csr_safety_rating] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csr_ratingdt] [datetime] NULL,
[csr_safety_rating_dt] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carriersafetyrating] ADD CONSTRAINT [pk_carriersafetyrating_csr_id] PRIMARY KEY CLUSTERED ([csr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriersafetyrating_car_id] ON [dbo].[carriersafetyrating] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriersafetyrating] TO [public]
GO
GRANT INSERT ON  [dbo].[carriersafetyrating] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriersafetyrating] TO [public]
GO
GRANT SELECT ON  [dbo].[carriersafetyrating] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriersafetyrating] TO [public]
GO
