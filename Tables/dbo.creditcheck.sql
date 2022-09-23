CREATE TABLE [dbo].[creditcheck]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cmp_aging1] [money] NULL,
[cmp_aging2] [money] NULL,
[cmp_aging3] [money] NULL,
[cmp_aging4] [money] NULL,
[cmp_aging5] [money] NULL,
[cmp_aging6] [money] NULL,
[alt_id] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[creditcheck] ADD CONSTRAINT [pk_crecitcheck] PRIMARY KEY CLUSTERED ([cmp_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[creditcheck] TO [public]
GO
GRANT INSERT ON  [dbo].[creditcheck] TO [public]
GO
GRANT REFERENCES ON  [dbo].[creditcheck] TO [public]
GO
GRANT SELECT ON  [dbo].[creditcheck] TO [public]
GO
GRANT UPDATE ON  [dbo].[creditcheck] TO [public]
GO
