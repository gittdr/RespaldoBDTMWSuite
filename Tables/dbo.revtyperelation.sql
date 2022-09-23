CREATE TABLE [dbo].[revtyperelation]
(
[rtr_revtype1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtr_revtype2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtr_revtype3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rtr_revtype4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[revtyperelation] TO [public]
GO
GRANT INSERT ON  [dbo].[revtyperelation] TO [public]
GO
GRANT REFERENCES ON  [dbo].[revtyperelation] TO [public]
GO
GRANT SELECT ON  [dbo].[revtyperelation] TO [public]
GO
GRANT UPDATE ON  [dbo].[revtyperelation] TO [public]
GO
