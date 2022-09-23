CREATE TABLE [dbo].[ident_numbers]
(
[n] [bigint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [n] ON [dbo].[ident_numbers] ([n]) ON [PRIMARY]
GO
