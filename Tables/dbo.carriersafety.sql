CREATE TABLE [dbo].[carriersafety]
(
[csa_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csa_misc1] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_misc2] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_misc3] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csa_misc4] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carriersafety] ADD CONSTRAINT [pk_carriersafety_csa_id] PRIMARY KEY CLUSTERED ([csa_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriersafety_car_id] ON [dbo].[carriersafety] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriersafety] TO [public]
GO
GRANT INSERT ON  [dbo].[carriersafety] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriersafety] TO [public]
GO
GRANT SELECT ON  [dbo].[carriersafety] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriersafety] TO [public]
GO
