CREATE TABLE [dbo].[ImportError]
(
[ImportErrorId] [int] NOT NULL IDENTITY(1, 1),
[ImportErrorDefinitionId] [int] NOT NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedBy] [int] NOT NULL CONSTRAINT [DF_ImportError_CreatedBy] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportError] ADD CONSTRAINT [PK_ImportError] PRIMARY KEY CLUSTERED ([ImportErrorId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_ImportError_ImportErrorDefinitionId] ON [dbo].[ImportError] ([ImportErrorDefinitionId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImportError] ADD CONSTRAINT [FK_ImportError_CreatedBy] FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[TMWUsers] ([UserId])
GO
ALTER TABLE [dbo].[ImportError] ADD CONSTRAINT [FK_ImportError_ImportErrorDefinitionId] FOREIGN KEY ([ImportErrorDefinitionId]) REFERENCES [dbo].[ImportErrorDefinition] ([ImportErrorDefinitionId])
GO
GRANT DELETE ON  [dbo].[ImportError] TO [public]
GO
GRANT INSERT ON  [dbo].[ImportError] TO [public]
GO
GRANT SELECT ON  [dbo].[ImportError] TO [public]
GO
GRANT UPDATE ON  [dbo].[ImportError] TO [public]
GO
