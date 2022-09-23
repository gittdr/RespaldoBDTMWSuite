CREATE TABLE [dbo].[estatIPLTETTREQCount]
(
[reqcmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[reqcurrent] [int] NULL,
[reqmax] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatIPLTETTREQCount] ADD CONSTRAINT [PK_estatIPLTETREQCount] PRIMARY KEY NONCLUSTERED ([reqcmp_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatIPLTETTREQCount] ADD CONSTRAINT [FK_estatIPLTETREQCount] FOREIGN KEY ([reqcmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
GRANT DELETE ON  [dbo].[estatIPLTETTREQCount] TO [public]
GO
GRANT INSERT ON  [dbo].[estatIPLTETTREQCount] TO [public]
GO
GRANT SELECT ON  [dbo].[estatIPLTETTREQCount] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatIPLTETTREQCount] TO [public]
GO
