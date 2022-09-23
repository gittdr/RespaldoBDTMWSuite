CREATE TABLE [dbo].[eventcodechange]
(
[name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[code] [int] NULL,
[changedate] [datetime] NULL,
[old_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old_abbr] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[change_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[eventcodechange] TO [public]
GO
GRANT INSERT ON  [dbo].[eventcodechange] TO [public]
GO
GRANT REFERENCES ON  [dbo].[eventcodechange] TO [public]
GO
GRANT SELECT ON  [dbo].[eventcodechange] TO [public]
GO
GRANT UPDATE ON  [dbo].[eventcodechange] TO [public]
GO
