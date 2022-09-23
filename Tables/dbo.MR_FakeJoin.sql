CREATE TABLE [dbo].[MR_FakeJoin]
(
[field1] [int] NULL,
[field2] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MR_FakeJoin] TO [public]
GO
GRANT INSERT ON  [dbo].[MR_FakeJoin] TO [public]
GO
GRANT REFERENCES ON  [dbo].[MR_FakeJoin] TO [public]
GO
GRANT SELECT ON  [dbo].[MR_FakeJoin] TO [public]
GO
GRANT UPDATE ON  [dbo].[MR_FakeJoin] TO [public]
GO
