CREATE TABLE [dbo].[trailer_autoload_log]
(
[ord_hdrnumber] [int] NOT NULL,
[autoload_id] [int] NOT NULL,
[compartment_cmd_seq1] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compartment_cmd_seq2] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compartment_cmd_seq3] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compartment_cmd_seq4] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compartment_cmd_seq5] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[compartment_cmd_seq6] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL,
[ech_id] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_autoload_log] ADD CONSTRAINT [pk_trailer_autoload_log] PRIMARY KEY CLUSTERED ([ord_hdrnumber]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_autoload_log] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_autoload_log] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailer_autoload_log] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_autoload_log] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_autoload_log] TO [public]
GO
