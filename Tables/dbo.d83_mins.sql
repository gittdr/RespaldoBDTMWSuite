CREATE TABLE [dbo].[d83_mins]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[name] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[zero_twenty] [decimal] (12, 2) NULL,
[twentyfive_fifty] [decimal] (12, 2) NULL,
[fiftyfive_eightfive] [decimal] (12, 2) NULL,
[ninty_plus] [decimal] (12, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[d83_mins] ADD CONSTRAINT [PK__d83_mins__3213E83FDA97D1CC] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[d83_mins] TO [public]
GO
GRANT INSERT ON  [dbo].[d83_mins] TO [public]
GO
GRANT REFERENCES ON  [dbo].[d83_mins] TO [public]
GO
GRANT SELECT ON  [dbo].[d83_mins] TO [public]
GO
GRANT UPDATE ON  [dbo].[d83_mins] TO [public]
GO
