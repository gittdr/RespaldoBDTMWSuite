CREATE TABLE [dbo].[carriertractor]
(
[ctr_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctr_drivers] [int] NULL,
[ctr_owneroperators] [int] NULL,
[ctr_misc1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctr_misc2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctr_misc3] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ctr_misc4] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carriertractor] ADD CONSTRAINT [pk_carriertractor_ctr_id] PRIMARY KEY CLUSTERED ([ctr_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriertractor_car_id] ON [dbo].[carriertractor] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriertractor] TO [public]
GO
GRANT INSERT ON  [dbo].[carriertractor] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriertractor] TO [public]
GO
GRANT SELECT ON  [dbo].[carriertractor] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriertractor] TO [public]
GO
