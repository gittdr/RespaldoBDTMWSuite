CREATE TABLE [dbo].[Import_Terminalzipcode]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode_high] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zipcode_low] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_carrier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_days] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[xdock_carrier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_carrier] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_days] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[monday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tuesday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[wednesday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[thursday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[friday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[saturday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sunday_serv] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[svclevel] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_pos] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[state_c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_c] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isloaded] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Import_Te__isloa__5AED19A6] DEFAULT ('N'),
[err_msg] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Import_Terminalzipcode] ADD CONSTRAINT [PK__Import_T__3213E83FEF7C6560] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Import_Terminalzipcode] TO [public]
GO
GRANT INSERT ON  [dbo].[Import_Terminalzipcode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Import_Terminalzipcode] TO [public]
GO
GRANT SELECT ON  [dbo].[Import_Terminalzipcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[Import_Terminalzipcode] TO [public]
GO
