CREATE TABLE [dbo].[gdi_log]
(
[gdl_id] [int] NOT NULL IDENTITY(1, 1),
[gdl_session] [int] NOT NULL,
[gdl_sequence] [int] NOT NULL,
[gdl_class] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gdl_location] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[gdl_message] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[gdl_user_handles] [int] NOT NULL,
[gdl_gdi_handles] [int] NOT NULL,
[gdl_time] [datetime] NOT NULL CONSTRAINT [DF__gdi_log__gdl_tim__42BB62BC] DEFAULT (getdate()),
[gdl_user] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__gdi_log__gdl_use__43AF86F5] DEFAULT (suser_name()),
[gdl_pagefault] [int] NULL,
[gdl_peakws] [int] NULL,
[gdl_ws] [int] NULL,
[gdl_peakpaged] [int] NULL,
[gdl_paged] [int] NULL,
[gdl_peaknonpaged] [int] NULL,
[gdl_nonpaged] [int] NULL,
[gdl_pagefile] [int] NULL,
[gdl_peakpagefile] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gdi_log] ADD CONSTRAINT [PK__gdi_log__41C73E83] PRIMARY KEY CLUSTERED ([gdl_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[gdi_log] TO [public]
GO
GRANT INSERT ON  [dbo].[gdi_log] TO [public]
GO
GRANT SELECT ON  [dbo].[gdi_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[gdi_log] TO [public]
GO
