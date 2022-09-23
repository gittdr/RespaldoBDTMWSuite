CREATE TABLE [dbo].[terminalzipcode]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zipcode_low] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[zipcode_high] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state_c] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[country_c] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[route_id] [int] NULL CONSTRAINT [DF__terminalz__route__412D47A3] DEFAULT ((0)),
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__unit___42216BDC] DEFAULT (''),
[advance_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[advance_days] [int] NULL CONSTRAINT [DF__terminalz__advan__43159015] DEFAULT ((0)),
[xdock_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_days] [int] NULL CONSTRAINT [DF__terminalz__beyon__4409B44E] DEFAULT ((0)),
[monday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__monda__44FDD887] DEFAULT ('Y'),
[tuesday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__tuesd__45F1FCC0] DEFAULT ('Y'),
[wednesday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__wedne__46E620F9] DEFAULT ('Y'),
[thursday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__thurs__47DA4532] DEFAULT ('Y'),
[friday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__frida__48CE696B] DEFAULT ('Y'),
[saturday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__satur__49C28DA4] DEFAULT ('N'),
[sunday_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__sunda__4AB6B1DD] DEFAULT ('N'),
[svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__terminalz__svcle__4BAAD616] DEFAULT (''),
[rowchgts] [timestamp] NOT NULL,
[bill_to] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cty_code] [int] NULL,
[advance_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[beyond_serv] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[requestor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[delivery_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateddate] [datetime] NULL,
[comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminalzipcode] ADD CONSTRAINT [PK__terminal__3213E83F7DC000C3] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [termzip_zip] ON [dbo].[terminalzipcode] ([cmp_id], [zipcode_low], [svclevel]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [termzip_zipcodes] ON [dbo].[terminalzipcode] ([zipcode_low], [zipcode_high], [cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminalzipcode] TO [public]
GO
GRANT INSERT ON  [dbo].[terminalzipcode] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminalzipcode] TO [public]
GO
GRANT SELECT ON  [dbo].[terminalzipcode] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminalzipcode] TO [public]
GO
