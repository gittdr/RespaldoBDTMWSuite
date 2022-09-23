CREATE TABLE [dbo].[statecountry]
(
[stc_state_c] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stc_state_desc] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stc_country_c] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[stc_state_alt] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[statecountry] ADD CONSTRAINT [pk_sc] PRIMARY KEY CLUSTERED ([stc_country_c], [stc_state_c]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[statecountry] TO [public]
GO
GRANT INSERT ON  [dbo].[statecountry] TO [public]
GO
GRANT REFERENCES ON  [dbo].[statecountry] TO [public]
GO
GRANT SELECT ON  [dbo].[statecountry] TO [public]
GO
GRANT UPDATE ON  [dbo].[statecountry] TO [public]
GO
