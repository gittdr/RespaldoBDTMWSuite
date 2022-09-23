CREATE TABLE [dbo].[reports]
(
[rpt_index] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_dwname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rpt_menuname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_owner] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rpt_rdwname] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_rpt] ON [dbo].[reports] ([rpt_index]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[reports] TO [public]
GO
GRANT INSERT ON  [dbo].[reports] TO [public]
GO
GRANT REFERENCES ON  [dbo].[reports] TO [public]
GO
GRANT SELECT ON  [dbo].[reports] TO [public]
GO
GRANT UPDATE ON  [dbo].[reports] TO [public]
GO
