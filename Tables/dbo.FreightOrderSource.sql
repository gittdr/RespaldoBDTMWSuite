CREATE TABLE [dbo].[FreightOrderSource]
(
[FreightOrderSourceId] [bigint] NOT NULL IDENTITY(1, 1),
[Source] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BillToIsAltId] [bit] NULL,
[ShipperIsAltId] [bit] NULL,
[ConsigneeIsAltId] [bit] NULL,
[OrderByIsAltId] [bit] NULL,
[SubCompanyIsAltId] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FreightOrderSource] ADD CONSTRAINT [PK_FreightOrderSource] PRIMARY KEY CLUSTERED ([FreightOrderSourceId]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [ix_source] ON [dbo].[FreightOrderSource] ([Source]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FreightOrderSource] TO [public]
GO
GRANT INSERT ON  [dbo].[FreightOrderSource] TO [public]
GO
GRANT SELECT ON  [dbo].[FreightOrderSource] TO [public]
GO
GRANT UPDATE ON  [dbo].[FreightOrderSource] TO [public]
GO
