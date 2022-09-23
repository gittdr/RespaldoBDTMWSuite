CREATE TABLE [dbo].[TransferDestinationType]
(
[DestinationTypeId] [tinyint] NOT NULL IDENTITY(1, 1),
[DestinationType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransferDestinationType] ADD CONSTRAINT [PK_TransferDestinationType] PRIMARY KEY CLUSTERED ([DestinationTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[TransferDestinationType] TO [public]
GO
GRANT INSERT ON  [dbo].[TransferDestinationType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[TransferDestinationType] TO [public]
GO
GRANT SELECT ON  [dbo].[TransferDestinationType] TO [public]
GO
GRANT UPDATE ON  [dbo].[TransferDestinationType] TO [public]
GO
