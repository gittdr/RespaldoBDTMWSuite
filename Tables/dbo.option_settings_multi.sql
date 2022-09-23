CREATE TABLE [dbo].[option_settings_multi]
(
[opmulti_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opmulti_contract] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opmulti_value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opmulti_expiration] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opmulti_check] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[opmulti_menulist] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[opmulti_comment] [text] COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[option_settings_multi] TO [public]
GO
GRANT INSERT ON  [dbo].[option_settings_multi] TO [public]
GO
GRANT SELECT ON  [dbo].[option_settings_multi] TO [public]
GO
GRANT UPDATE ON  [dbo].[option_settings_multi] TO [public]
GO
