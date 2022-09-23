CREATE TABLE [dbo].[tblAddressTypes]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[AddressType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAddressTypes] ADD CONSTRAINT [PK_tblAddressTypes_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddressTypesAddressType] ON [dbo].[tblAddressTypes] ([AddressType]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblAddressTypes] TO [public]
GO
GRANT INSERT ON  [dbo].[tblAddressTypes] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblAddressTypes] TO [public]
GO
GRANT SELECT ON  [dbo].[tblAddressTypes] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblAddressTypes] TO [public]
GO
