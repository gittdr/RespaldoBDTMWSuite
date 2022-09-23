CREATE TABLE [dbo].[fuelsolutiondetail]
(
[lgh_number] [int] NOT NULL,
[seq] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[highway_seg] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[highway_seg_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[miles_from_origin] [decimal] (7, 1) NULL,
[fuel_loc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_loc_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_loc_city] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_purchase] [int] NULL,
[act_purchase_price] [decimal] (6, 4) NULL,
[act_purchase_cost] [decimal] (6, 2) NULL,
[eff_purchase_price] [decimal] (6, 4) NULL,
[eff_purchase_cost] [decimal] (6, 2) NULL,
[remain_fuel_level] [int] NULL,
[range_ind] [int] NULL,
[fill_tank] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fuel_loc_type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[exit_number] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[street_addr] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[phone_no] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[latitude] [int] NULL,
[longitude] [int] NULL,
[request_id] [int] NULL,
[def_fill] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fuelsolutiondetail] ADD CONSTRAINT [pk_fuelsolutiondetail] UNIQUE NONCLUSTERED ([lgh_number], [request_id], [seq]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fuelsolutiondetail] TO [public]
GO
GRANT INSERT ON  [dbo].[fuelsolutiondetail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fuelsolutiondetail] TO [public]
GO
GRANT SELECT ON  [dbo].[fuelsolutiondetail] TO [public]
GO
GRANT UPDATE ON  [dbo].[fuelsolutiondetail] TO [public]
GO
