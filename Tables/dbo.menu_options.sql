CREATE TABLE [dbo].[menu_options]
(
[mo_id] [int] NOT NULL,
[cm_id] [int] NOT NULL,
[mo_option_seq] [int] NOT NULL,
[mo_option_key] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mo_option_value] [char] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mo_option_parm] [char] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[menu_options] TO [public]
GO
GRANT INSERT ON  [dbo].[menu_options] TO [public]
GO
GRANT REFERENCES ON  [dbo].[menu_options] TO [public]
GO
GRANT SELECT ON  [dbo].[menu_options] TO [public]
GO
GRANT UPDATE ON  [dbo].[menu_options] TO [public]
GO
