CREATE TABLE [dbo].[Thirdpartyrelationship]
(
[tprel_number] [int] NOT NULL IDENTITY(1, 1),
[tprel_table] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tprel_tablekey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_type] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tprel_restriction] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tpr_split] [money] NULL,
[tpr_split_flag] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Thirdpartyrelationship] ADD CONSTRAINT [pk_tprel_number] PRIMARY KEY CLUSTERED ([tprel_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_thirdpartyrelationship_tprel_tablekey] ON [dbo].[Thirdpartyrelationship] ([tprel_table], [tprel_tablekey], [tpr_type]) INCLUDE ([tpr_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[Thirdpartyrelationship] TO [public]
GO
GRANT INSERT ON  [dbo].[Thirdpartyrelationship] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Thirdpartyrelationship] TO [public]
GO
GRANT SELECT ON  [dbo].[Thirdpartyrelationship] TO [public]
GO
GRANT UPDATE ON  [dbo].[Thirdpartyrelationship] TO [public]
GO
