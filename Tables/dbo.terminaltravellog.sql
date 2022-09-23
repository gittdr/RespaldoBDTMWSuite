CREATE TABLE [dbo].[terminaltravellog]
(
[id] [int] NOT NULL IDENTITY(1, 1),
[service_id] [int] NOT NULL,
[ord_hdrnumber] [int] NOT NULL,
[sequence] [int] NOT NULL,
[type] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[origin] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[destination] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[comment] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[days] [float] NULL,
[hours] [int] NULL,
[newdate] [datetime] NULL,
[ref] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_int] [int] NULL,
[rowchgts] [timestamp] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[terminaltravellog] ADD CONSTRAINT [PK__terminal__3213E83F17BEB35D] PRIMARY KEY CLUSTERED ([id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [termtravellog_ord_hdrnumber] ON [dbo].[terminaltravellog] ([ord_hdrnumber], [sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [termtravellog_service_id] ON [dbo].[terminaltravellog] ([service_id], [sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[terminaltravellog] TO [public]
GO
GRANT INSERT ON  [dbo].[terminaltravellog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[terminaltravellog] TO [public]
GO
GRANT SELECT ON  [dbo].[terminaltravellog] TO [public]
GO
GRANT UPDATE ON  [dbo].[terminaltravellog] TO [public]
GO
