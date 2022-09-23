CREATE TABLE [dbo].[ltsl_referencenumber]
(
[ref_tablekey] [int] NOT NULL,
[ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_typedesc] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sequence] [int] NULL,
[ord_hdrnumber] [int] NULL,
[timestamp] [binary] (8) NULL,
[ref_table] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_sid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ref_pickup] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ltsl_referencenumber] TO [public]
GO
GRANT INSERT ON  [dbo].[ltsl_referencenumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ltsl_referencenumber] TO [public]
GO
GRANT SELECT ON  [dbo].[ltsl_referencenumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[ltsl_referencenumber] TO [public]
GO
