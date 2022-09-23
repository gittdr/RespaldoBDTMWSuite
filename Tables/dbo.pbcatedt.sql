CREATE TABLE [dbo].[pbcatedt]
(
[pbe_name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pbe_edit] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pbe_type] [smallint] NOT NULL,
[pbe_cntr] [int] NULL,
[pbe_seqn] [smallint] NOT NULL,
[pbe_flag] [int] NULL,
[pbe_work] [char] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [pbcatedt_idx] ON [dbo].[pbcatedt] ([pbe_name], [pbe_seqn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pbcatedt] TO [public]
GO
GRANT INSERT ON  [dbo].[pbcatedt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pbcatedt] TO [public]
GO
GRANT SELECT ON  [dbo].[pbcatedt] TO [public]
GO
GRANT UPDATE ON  [dbo].[pbcatedt] TO [public]
GO
