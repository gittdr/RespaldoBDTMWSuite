CREATE TABLE [dbo].[tblBusinessRules]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[ViewCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ViewFieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessRuleSN] [int] NOT NULL,
[TotalMailType] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBusinessRules] ADD CONSTRAINT [PK_tblBusinessRules] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblBusinessRules] TO [public]
GO
GRANT INSERT ON  [dbo].[tblBusinessRules] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblBusinessRules] TO [public]
GO
GRANT SELECT ON  [dbo].[tblBusinessRules] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblBusinessRules] TO [public]
GO
