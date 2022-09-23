CREATE TABLE [dbo].[uncodes]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[un_number] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[shipping_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[class] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[subsidiary_class] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compatibility_group] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[packing_group] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[explosive_limit] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[erap_index] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[passenger_carry_ship] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[passenger_carry_road] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[marine_pollutant] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rq] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__uncodes__rq__11492A57] DEFAULT ('F'),
[pass_air_rail] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cargo_air] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[location] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[other] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[uncodes] ADD CONSTRAINT [PK__uncodes__3213E83FFA139FE9] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[uncodes] TO [public]
GO
GRANT INSERT ON  [dbo].[uncodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[uncodes] TO [public]
GO
GRANT SELECT ON  [dbo].[uncodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[uncodes] TO [public]
GO
