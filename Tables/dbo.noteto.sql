CREATE TABLE [dbo].[noteto]
(
[not_number] [int] NOT NULL,
[nto_to] [varchar] (7) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[nto_read] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_not_number] ON [dbo].[noteto] ([not_number]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_usr_id] ON [dbo].[noteto] ([nto_to], [not_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[noteto] TO [public]
GO
GRANT INSERT ON  [dbo].[noteto] TO [public]
GO
GRANT REFERENCES ON  [dbo].[noteto] TO [public]
GO
GRANT SELECT ON  [dbo].[noteto] TO [public]
GO
GRANT UPDATE ON  [dbo].[noteto] TO [public]
GO
