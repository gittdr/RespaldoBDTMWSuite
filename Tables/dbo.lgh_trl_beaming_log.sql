CREATE TABLE [dbo].[lgh_trl_beaming_log]
(
[ltb_id] [int] NOT NULL IDENTITY(1, 1),
[lgh_number] [int] NOT NULL,
[prior_lgh_number] [int] NOT NULL,
[lgh_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer1] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_trailer2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[prior_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_cty_id] [int] NULL,
[prior_cty_id] [int] NULL,
[ord_hdrnumber] [int] NULL,
[ltb_date_entered] [datetime] NOT NULL CONSTRAINT [DF__lgh_trl_b__ltb_d__064BA971] DEFAULT (getdate()),
[ltb_user_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ltb_password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[lgh_trl_beaming_log] ADD CONSTRAINT [PK__lgh_trl___AF424E86D728C3A3] PRIMARY KEY CLUSTERED ([ltb_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ltb_leg] ON [dbo].[lgh_trl_beaming_log] ([lgh_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_ltb_leg_prior] ON [dbo].[lgh_trl_beaming_log] ([prior_lgh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[lgh_trl_beaming_log] TO [public]
GO
GRANT INSERT ON  [dbo].[lgh_trl_beaming_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[lgh_trl_beaming_log] TO [public]
GO
GRANT SELECT ON  [dbo].[lgh_trl_beaming_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[lgh_trl_beaming_log] TO [public]
GO
