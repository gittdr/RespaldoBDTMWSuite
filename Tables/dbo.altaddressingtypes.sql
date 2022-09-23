CREATE TABLE [dbo].[altaddressingtypes]
(
[altt_number] [int] NOT NULL IDENTITY(1, 1),
[altt_type] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[altaddressingtypes] ADD CONSTRAINT [PK__altaddressingtyp__7FC5D5E0] PRIMARY KEY CLUSTERED ([altt_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[altaddressingtypes] TO [public]
GO
GRANT INSERT ON  [dbo].[altaddressingtypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[altaddressingtypes] TO [public]
GO
GRANT SELECT ON  [dbo].[altaddressingtypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[altaddressingtypes] TO [public]
GO
