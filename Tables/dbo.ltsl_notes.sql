CREATE TABLE [dbo].[ltsl_notes]
(
[not_number] [int] NOT NULL,
[not_text] [varchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_urgent] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_senton] [datetime] NULL,
[not_sentby] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_expires] [datetime] NULL,
[not_forwardedfrom] [int] NULL,
[timestamp] [binary] (8) NULL,
[ntb_table] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[nre_tablekey] [char] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[not_sequence] [smallint] NULL,
[last_updatedby] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedatetime] [datetime] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltsl_notes] TO [public]
GO
GRANT INSERT ON  [dbo].[ltsl_notes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltsl_notes] TO [public]
GO
GRANT SELECT ON  [dbo].[ltsl_notes] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltsl_notes] TO [public]
GO
