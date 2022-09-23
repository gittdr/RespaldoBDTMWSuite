CREATE TABLE [dbo].[runonce]
(
[pts] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ro_dt] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[runonce] TO [public]
GO
GRANT INSERT ON  [dbo].[runonce] TO [public]
GO
GRANT REFERENCES ON  [dbo].[runonce] TO [public]
GO
GRANT SELECT ON  [dbo].[runonce] TO [public]
GO
GRANT UPDATE ON  [dbo].[runonce] TO [public]
GO
