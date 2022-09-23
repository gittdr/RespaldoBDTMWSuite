CREATE TABLE [dbo].[staticloadplan]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[brn_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[option_number] [int] NULL CONSTRAINT [DF__staticloa__optio__7A9ACF29] DEFAULT ((0)),
[origin_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dest_terminal] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[door] [int] NULL CONSTRAINT [DF__staticload__door__7B8EF362] DEFAULT ((0)),
[service_days] [int] NULL CONSTRAINT [DF__staticloa__servi__7C83179B] DEFAULT ((0)),
[unit_qtr] [int] NULL CONSTRAINT [DF__staticloa__unit___7D773BD4] DEFAULT ((0)),
[unit_pos] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__staticloa__unit___7E6B600D] DEFAULT (''),
[hub_1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_4] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_5] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_6] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_7] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_8] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_9] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hub_10] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[is_active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__staticloa__is_ac__7F5F8446] DEFAULT ('Y'),
[svclevel] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[staticloadplan] ADD CONSTRAINT [PK__staticlo__3213E83F6D4A85ED] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[staticloadplan] TO [public]
GO
GRANT INSERT ON  [dbo].[staticloadplan] TO [public]
GO
GRANT REFERENCES ON  [dbo].[staticloadplan] TO [public]
GO
GRANT SELECT ON  [dbo].[staticloadplan] TO [public]
GO
GRANT UPDATE ON  [dbo].[staticloadplan] TO [public]
GO
