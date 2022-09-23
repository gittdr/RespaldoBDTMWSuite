CREATE TABLE [dbo].[trailer_autoload]
(
[autoload_id] [int] NOT NULL IDENTITY(1, 1),
[trl_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ordered_volume1] [decimal] (10, 3) NOT NULL,
[ordered_volume2] [decimal] (10, 3) NOT NULL,
[ordered_volume3] [decimal] (10, 3) NOT NULL,
[ordered_volume4] [decimal] (10, 3) NOT NULL,
[ordered_volume5] [decimal] (10, 3) NOT NULL,
[ordered_volume6] [decimal] (10, 3) NULL,
[autoload_volume1] [decimal] (10, 3) NULL,
[autoload_volume2] [decimal] (10, 3) NULL,
[autoload_volume3] [decimal] (10, 3) NULL,
[autoload_volume4] [decimal] (10, 3) NULL,
[autoload_volume5] [decimal] (10, 3) NULL,
[autoload_volume6] [decimal] (10, 3) NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL,
[trl2_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[autoload_fgt_sequence1] [int] NULL,
[autoload_fgt_sequence2] [int] NULL,
[autoload_fgt_sequence3] [int] NULL,
[autoload_fgt_sequence4] [int] NULL,
[autoload_fgt_sequence5] [int] NULL,
[autoload_fgt_sequence6] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[trailer_autoload] ADD CONSTRAINT [pk_trailer_autoload] PRIMARY KEY CLUSTERED ([autoload_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trailer_autoload] TO [public]
GO
GRANT INSERT ON  [dbo].[trailer_autoload] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trailer_autoload] TO [public]
GO
GRANT SELECT ON  [dbo].[trailer_autoload] TO [public]
GO
GRANT UPDATE ON  [dbo].[trailer_autoload] TO [public]
GO
