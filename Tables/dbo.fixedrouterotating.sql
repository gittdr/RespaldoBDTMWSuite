CREATE TABLE [dbo].[fixedrouterotating]
(
[frr_id] [int] NOT NULL,
[frr_sequence] [int] NOT NULL,
[frr_enabled] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow6] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[frr_dow7] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[fixedrouterotating] ADD CONSTRAINT [pk_fixedrouterotating] PRIMARY KEY CLUSTERED ([frr_id], [frr_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[fixedrouterotating] TO [public]
GO
GRANT INSERT ON  [dbo].[fixedrouterotating] TO [public]
GO
GRANT REFERENCES ON  [dbo].[fixedrouterotating] TO [public]
GO
GRANT SELECT ON  [dbo].[fixedrouterotating] TO [public]
GO
GRANT UPDATE ON  [dbo].[fixedrouterotating] TO [public]
GO
