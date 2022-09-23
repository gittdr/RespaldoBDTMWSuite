CREATE TABLE [dbo].[ConditionalValidity]
(
[UserOrGroup] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserOrGroupId] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectType] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sequence] [int] NOT NULL,
[Operand] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[JoinType] [tinyint] NOT NULL,
[EquationColumn] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EquationColumnValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL,
[ModifiedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsValueSeparatedList] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConditionalValidity] ADD CONSTRAINT [pk_namesAndSequenceConditionalValidity] PRIMARY KEY CLUSTERED ([UserOrGroup], [UserOrGroupId], [ObjectType], [Sequence]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [TypeIndex] ON [dbo].[ConditionalValidity] ([ObjectType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UserGroupLookupIndex] ON [dbo].[ConditionalValidity] ([UserOrGroup], [UserOrGroupId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [UserGroupTypeLookupIndex] ON [dbo].[ConditionalValidity] ([UserOrGroup], [UserOrGroupId], [ObjectType]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[ConditionalValidity] TO [public]
GO
GRANT INSERT ON  [dbo].[ConditionalValidity] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ConditionalValidity] TO [public]
GO
GRANT SELECT ON  [dbo].[ConditionalValidity] TO [public]
GO
GRANT UPDATE ON  [dbo].[ConditionalValidity] TO [public]
GO
