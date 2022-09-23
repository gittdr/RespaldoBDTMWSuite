CREATE TABLE [dbo].[NoTouchBillingConfigurationReferenceNumber]
(
[ntbrn_id] [int] NOT NULL IDENTITY(1, 1),
[ntb_id] [int] NOT NULL,
[ntbrn_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntbrn_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingConfigurationReferenceNumber] ADD CONSTRAINT [PK_NoTouchBillingConfigurationReferenceNumber] PRIMARY KEY CLUSTERED ([ntbrn_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingConfigurationReferenceNumber] ADD CONSTRAINT [UX_ntb_id__ntbrn_ref_type] UNIQUE NONCLUSTERED ([ntb_id], [ntbrn_ref_type]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingConfigurationReferenceNumber] ADD CONSTRAINT [FK_NoTouchBillingConfigurationReferenceNumber_NoTouchBillingConfiguration] FOREIGN KEY ([ntb_id]) REFERENCES [dbo].[NoTouchBillingConfiguration] ([ntb_id])
GO
GRANT DELETE ON  [dbo].[NoTouchBillingConfigurationReferenceNumber] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchBillingConfigurationReferenceNumber] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchBillingConfigurationReferenceNumber] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchBillingConfigurationReferenceNumber] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchBillingConfigurationReferenceNumber] TO [public]
GO
