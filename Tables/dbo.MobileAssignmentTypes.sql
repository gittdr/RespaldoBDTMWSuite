CREATE TABLE [dbo].[MobileAssignmentTypes]
(
[Id] [smallint] NOT NULL IDENTITY(1, 1),
[Type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MobileAssignmentTypes] ADD CONSTRAINT [PK_MobileAssignmentTypes] PRIMARY KEY CLUSTERED ([Id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[MobileAssignmentTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[MobileAssignmentTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[MobileAssignmentTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[MobileAssignmentTypes] TO [public]
GO
