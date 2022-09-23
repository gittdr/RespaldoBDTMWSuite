CREATE TABLE [dbo].[DedicatedRevenueAllocationType]
(
[DedicatedRevenueAllocationTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedRevenueAllocationType] ADD CONSTRAINT [PK_DedicatedRevenueAllocationType] PRIMARY KEY CLUSTERED ([DedicatedRevenueAllocationTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedRevenueAllocationType] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedRevenueAllocationType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedRevenueAllocationType] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedRevenueAllocationType] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedRevenueAllocationType] TO [public]
GO
