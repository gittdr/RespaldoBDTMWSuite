CREATE TABLE [dbo].[comdatachaincodes]
(
[ccc_id] [int] NOT NULL IDENTITY(1, 1),
[ccc_chaincode] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_chainname] [nchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ccc_chain_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[comdatachaincodes] TO [public]
GO
GRANT INSERT ON  [dbo].[comdatachaincodes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[comdatachaincodes] TO [public]
GO
GRANT SELECT ON  [dbo].[comdatachaincodes] TO [public]
GO
GRANT UPDATE ON  [dbo].[comdatachaincodes] TO [public]
GO
