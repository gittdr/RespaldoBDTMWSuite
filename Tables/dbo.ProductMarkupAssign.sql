CREATE TABLE [dbo].[ProductMarkupAssign]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[AssignType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssign_Value1] DEFAULT ('UNKNOWN'),
[Value2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssign_Value2] DEFAULT ('UNKNOWN'),
[Value3] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_ProductMarkupAssign_Value3] DEFAULT ('UNKNOWN'),
[CreatedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarkupAssign_CreatedDate] DEFAULT (getdate()),
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ModifiedDate] [datetime] NOT NULL CONSTRAINT [DF_ProductMarkupAssign_ModifiedDate] DEFAULT (getdate()),
[OverrideBillTo] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_ProductMarkupAssign_OverrideBillTo] DEFAULT ('UNKNOWN')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupAssign] ADD CONSTRAINT [PK_ProductMarkupAssign] PRIMARY KEY CLUSTERED ([ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProductMarkupAssign] ADD CONSTRAINT [IX_ProductMarkupAssign] UNIQUE NONCLUSTERED ([AssignType], [Value1], [Value2], [Value3]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ProductMarkupAssign] TO [public]
GO
GRANT INSERT ON  [dbo].[ProductMarkupAssign] TO [public]
GO
GRANT SELECT ON  [dbo].[ProductMarkupAssign] TO [public]
GO
GRANT UPDATE ON  [dbo].[ProductMarkupAssign] TO [public]
GO
