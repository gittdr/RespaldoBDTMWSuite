CREATE TABLE [dbo].[tariffrowcolumnstl]
(
[timestamp] [timestamp] NULL,
[trc_number] [int] NOT NULL,
[tar_number] [int] NOT NULL,
[trc_rowcolumn] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[trc_sequence] [int] NOT NULL,
[trc_matchvalue] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_rangevalue] [money] NULL,
[trc_multimatch] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trc_rateasflat] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_trc_rateasflatstl] DEFAULT ('N'),
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tariffrowcolumnstl] ADD CONSTRAINT [PK_tariffrowcolumnstl] PRIMARY KEY CLUSTERED ([trc_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_tar_number_rc] ON [dbo].[tariffrowcolumnstl] ([tar_number], [trc_rowcolumn]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tariffrowcolumnstl] TO [public]
GO
GRANT INSERT ON  [dbo].[tariffrowcolumnstl] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tariffrowcolumnstl] TO [public]
GO
GRANT SELECT ON  [dbo].[tariffrowcolumnstl] TO [public]
GO
GRANT UPDATE ON  [dbo].[tariffrowcolumnstl] TO [public]
GO
