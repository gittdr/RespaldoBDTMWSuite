CREATE TABLE [dbo].[completion_referencenumber]
(
[ref_tablekey] [int] NOT NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_typedesc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sequence] [int] NULL,
[ord_hdrnumber] [int] NULL,
[timestamp] [timestamp] NULL,
[ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_pickup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_completion_referencenumber_ord_hdrnumber] ON [dbo].[completion_referencenumber] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_completion_referencenumber_ref_table_ref_tablekey] ON [dbo].[completion_referencenumber] ([ref_table], [ref_tablekey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_completion_referencenumber_ref_number] ON [dbo].[completion_referencenumber] ([ref_type], [ref_number], [ref_table]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[completion_referencenumber] TO [public]
GO
GRANT INSERT ON  [dbo].[completion_referencenumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[completion_referencenumber] TO [public]
GO
GRANT SELECT ON  [dbo].[completion_referencenumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[completion_referencenumber] TO [public]
GO
