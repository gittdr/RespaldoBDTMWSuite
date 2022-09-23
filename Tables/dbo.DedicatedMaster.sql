CREATE TABLE [dbo].[DedicatedMaster]
(
[DedicatedMasterId] [int] NOT NULL IDENTITY(1, 1),
[ContractId] [int] NOT NULL,
[BillToId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BranchId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BillNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_DedicatedMaster_CreatedDate] DEFAULT (getdate()),
[CreatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_DedicatedMaster_CreatedBy] DEFAULT (user_name()),
[LastUpdatedDate] [datetime] NOT NULL,
[LastUpdatedBy] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedMaster] ADD CONSTRAINT [PK_DedicatedMaster] PRIMARY KEY CLUSTERED ([DedicatedMasterId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DedicatedMaster_ContractId] ON [dbo].[DedicatedMaster] ([ContractId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedMaster] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedMaster] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedMaster] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedMaster] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedMaster] TO [public]
GO
