CREATE TABLE [dbo].[lgh_routesync]
(
[lrs_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[mov_number] [int] NOT NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrs_managed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__lgh_route__lrs_m__0CF7AE0E] DEFAULT ('Y'),
[lrs_distance] [decimal] (4, 1) NOT NULL,
[lrs_compliance] [int] NOT NULL,
[lrs_date_calculated] [datetime] NOT NULL CONSTRAINT [DF__lgh_route__lrs_d__0DEBD247] DEFAULT (getdate()),
[lrs_date_sent] [datetime] NULL,
[lrs_message] [varbinary] (max) NULL,
[lrs_response_code] [int] NULL,
[lrs_error_text] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrs_error_date] [datetime] NULL,
[lrs_omnitracs_key] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lrs_status] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lgh_routesync] ADD CONSTRAINT [PK__lgh_routesync__0C0389D5] PRIMARY KEY CLUSTERED ([lrs_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [lgh_lrs_legheader] ON [dbo].[lgh_routesync] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ix_lrs_status] ON [dbo].[lgh_routesync] ([lrs_status]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[lgh_routesync] TO [public]
GO
GRANT INSERT ON  [dbo].[lgh_routesync] TO [public]
GO
GRANT REFERENCES ON  [dbo].[lgh_routesync] TO [public]
GO
GRANT SELECT ON  [dbo].[lgh_routesync] TO [public]
GO
GRANT UPDATE ON  [dbo].[lgh_routesync] TO [public]
GO
