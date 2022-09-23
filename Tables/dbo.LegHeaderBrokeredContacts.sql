CREATE TABLE [dbo].[LegHeaderBrokeredContacts]
(
[lhbcid] [int] NOT NULL IDENTITY(1, 1),
[lghnumber] [int] NULL,
[carid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contactname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ceid] [int] NULL,
[bfax] [bit] NULL,
[bprint] [bit] NULL,
[bemail] [bit] NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LegHeaderBrokeredContacts] ADD CONSTRAINT [PK_LegHeaderBrokeredContacts] PRIMARY KEY CLUSTERED ([lhbcid]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[LegHeaderBrokeredContacts] TO [public]
GO
GRANT INSERT ON  [dbo].[LegHeaderBrokeredContacts] TO [public]
GO
GRANT REFERENCES ON  [dbo].[LegHeaderBrokeredContacts] TO [public]
GO
GRANT SELECT ON  [dbo].[LegHeaderBrokeredContacts] TO [public]
GO
GRANT UPDATE ON  [dbo].[LegHeaderBrokeredContacts] TO [public]
GO
