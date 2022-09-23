CREATE TABLE [dbo].[stateprofile]
(
[st_abbr] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[st_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_diesel_rate] [float] NULL,
[st_pump_rate] [float] NULL,
[st_2nd_tier_rate] [float] NULL,
[st_2nd_tier_descr] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_gas_rate] [float] NULL,
[st_gas_descr] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_other_rate] [float] NULL,
[st_other_descr] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_fuel_surcharge] [float] NULL,
[st_refunds] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_method] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[st_mpg] [float] NULL,
[st_ifta_yn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[stateprofile] TO [public]
GO
GRANT INSERT ON  [dbo].[stateprofile] TO [public]
GO
GRANT REFERENCES ON  [dbo].[stateprofile] TO [public]
GO
GRANT SELECT ON  [dbo].[stateprofile] TO [public]
GO
GRANT UPDATE ON  [dbo].[stateprofile] TO [public]
GO
