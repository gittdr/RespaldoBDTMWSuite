CREATE TABLE [dbo].[accessory]
(
[acc_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acc_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[acc_weight] [float] NULL,
[acc_weight_uom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acc_height] [float] NULL,
[acc_height_uom] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acc_length] [float] NULL,
[acc_width] [float] NULL,
[acc_cost] [money] NULL,
[acc_type1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acc_type2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acc_type3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[acc_type4] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[accessory] TO [public]
GO
GRANT INSERT ON  [dbo].[accessory] TO [public]
GO
GRANT REFERENCES ON  [dbo].[accessory] TO [public]
GO
GRANT SELECT ON  [dbo].[accessory] TO [public]
GO
GRANT UPDATE ON  [dbo].[accessory] TO [public]
GO
