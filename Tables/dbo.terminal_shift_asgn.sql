CREATE TABLE [dbo].[terminal_shift_asgn]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[terminal_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ee_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[effective_from] [datetime] NULL,
[effective_to] [datetime] NULL,
[sth_id] [int] NULL,
[active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminal_shift_asgn] TO [public]
GO
GRANT INSERT ON  [dbo].[terminal_shift_asgn] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminal_shift_asgn] TO [public]
GO
GRANT SELECT ON  [dbo].[terminal_shift_asgn] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminal_shift_asgn] TO [public]
GO
