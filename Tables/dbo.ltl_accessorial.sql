CREATE TABLE [dbo].[ltl_accessorial]
(
[lac_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lac_group_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lac_display_order] [int] NULL,
[lac_description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[lac_chargetypes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lac_paytypes] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lac_retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__ltl_acces__lac_r__088EC127] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ltl_accessorial] ADD CONSTRAINT [PK__ltl_accessorial__079A9CEE] PRIMARY KEY CLUSTERED ([lac_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltl_accessorial] TO [public]
GO
GRANT INSERT ON  [dbo].[ltl_accessorial] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltl_accessorial] TO [public]
GO
GRANT SELECT ON  [dbo].[ltl_accessorial] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltl_accessorial] TO [public]
GO
