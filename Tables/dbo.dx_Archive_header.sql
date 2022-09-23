CREATE TABLE [dbo].[dx_Archive_header]
(
[dx_Archive_header_id] [bigint] NOT NULL IDENTITY(1, 1),
[dx_importid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcename] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[dx_sourcedate] [datetime] NOT NULL,
[dx_updated] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_accepted] [bit] NULL,
[dx_ordernumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_orderhdrnumber] [int] NULL,
[dx_movenumber] [int] NULL,
[dx_manifestnumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_batchref] [int] NULL,
[dx_doctype] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_docnumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_createdby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_createdate] [smalldatetime] NULL,
[dx_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_updatedate] [smalldatetime] NULL,
[dx_processed] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_trpid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dx_sourcedate_reference] [datetime] NULL,
[dx_billto] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[dx_Archive_header] ADD CONSTRAINT [pk_dx_Archive_header] PRIMARY KEY CLUSTERED ([dx_Archive_header_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [uk_dx_Archive_header] ON [dbo].[dx_Archive_header] ([dx_importid], [dx_sourcename], [dx_sourcedate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2Archive_headerOrderHeaderNumber] ON [dbo].[dx_Archive_header] ([dx_orderhdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_dx_orderhdrnumber_dx_sourcedate_header] ON [dbo].[dx_Archive_header] ([dx_orderhdrnumber], [dx_sourcedate]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2Archive_headerOrderNumber] ON [dbo].[dx_Archive_header] ([dx_ordernumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_archive_processed_header] ON [dbo].[dx_Archive_header] ([dx_processed], [dx_orderhdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_dx_archive_header_dx_processed_dx_ordernumber] ON [dbo].[dx_Archive_header] ([dx_processed], [dx_ordernumber]) INCLUDE ([dx_Archive_header_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxSl2Archive_headerSourceDate] ON [dbo].[dx_Archive_header] ([dx_sourcedate]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dx_Archive_header] TO [public]
GO
GRANT INSERT ON  [dbo].[dx_Archive_header] TO [public]
GO
GRANT SELECT ON  [dbo].[dx_Archive_header] TO [public]
GO
GRANT UPDATE ON  [dbo].[dx_Archive_header] TO [public]
GO
