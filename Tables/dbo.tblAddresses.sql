CREATE TABLE [dbo].[tblAddresses]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[AddressBookSN] [int] NULL,
[AddressName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddressType] [int] NULL,
[InBox] [int] NULL,
[OutBox] [int] NULL,
[UseInResolve] [bit] NOT NULL,
[PositionsBox] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tmail_no_empty_addressnames] ON [dbo].[tblAddresses] FOR UPDATE, INSERT
AS
IF EXISTS (SELECT * FROM inserted WHERE ISNULL(addressname, '') = '')
  BEGIN
	ROLLBACK
	RAISERROR ('Attempt to create an addressee with no name. Please contact TMW support immediately.', 16, 1)
  END
GO
ALTER TABLE [dbo].[tblAddresses] ADD CONSTRAINT [PK_tblAddresses_SN] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idxAddressSN] ON [dbo].[tblAddresses] ([AddressBookSN]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [AddressName] ON [dbo].[tblAddresses] ([AddressName]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tblAddressTypestblAddresses] ON [dbo].[tblAddresses] ([AddressType]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [InBox] ON [dbo].[tblAddresses] ([InBox]) WITH (FILLFACTOR=100) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAddresses] ADD CONSTRAINT [FK__Temporary__Addre__0C65E2BC] FOREIGN KEY ([AddressType]) REFERENCES [dbo].[tblAddressTypes] ([SN])
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddresses].[AddressBookSN]'
GO
EXEC sp_bindefault N'[dbo].[tblAddresses_AddressName_D]', N'[dbo].[tblAddresses].[AddressName]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddresses].[AddressType]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddresses].[InBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddresses].[OutBox]'
GO
EXEC sp_bindefault N'[dbo].[UW_ZeroDefault]', N'[dbo].[tblAddresses].[UseInResolve]'
GO
GRANT DELETE ON  [dbo].[tblAddresses] TO [public]
GO
GRANT INSERT ON  [dbo].[tblAddresses] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblAddresses] TO [public]
GO
GRANT SELECT ON  [dbo].[tblAddresses] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblAddresses] TO [public]
GO
