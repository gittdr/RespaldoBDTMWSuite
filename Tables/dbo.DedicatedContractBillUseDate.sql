CREATE TABLE [dbo].[DedicatedContractBillUseDate]
(
[DedicatedContractBillUseDateId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DedicatedContractBillUseDate] ADD CONSTRAINT [PK_DedicatedContractBillUseDateId] PRIMARY KEY CLUSTERED ([DedicatedContractBillUseDateId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DedicatedContractBillUseDate] TO [public]
GO
GRANT INSERT ON  [dbo].[DedicatedContractBillUseDate] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DedicatedContractBillUseDate] TO [public]
GO
GRANT SELECT ON  [dbo].[DedicatedContractBillUseDate] TO [public]
GO
GRANT UPDATE ON  [dbo].[DedicatedContractBillUseDate] TO [public]
GO
