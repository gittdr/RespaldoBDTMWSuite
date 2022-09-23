CREATE TABLE [dbo].[NoTouchBillingType]
(
[ntbTypeId] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Retired] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingType] ADD CONSTRAINT [PK_NoTouchBillingType] PRIMARY KEY CLUSTERED ([ntbTypeId]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[NoTouchBillingType] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchBillingType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchBillingType] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchBillingType] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchBillingType] TO [public]
GO
