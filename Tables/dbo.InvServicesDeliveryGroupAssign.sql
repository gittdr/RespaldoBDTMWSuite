CREATE TABLE [dbo].[InvServicesDeliveryGroupAssign]
(
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DelGroup] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CanShortLoad] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_InvServicesDeliveryGroupAssign_CanShortLoad] DEFAULT ('N')
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_InvServicesDeliveryGroupAssign_DelGroup] ON [dbo].[InvServicesDeliveryGroupAssign] ([DelGroup]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[InvServicesDeliveryGroupAssign] ADD CONSTRAINT [FK_InvServicesDeliveryGroupAssign_cmp_id] FOREIGN KEY ([cmp_id]) REFERENCES [dbo].[company] ([cmp_id])
GO
ALTER TABLE [dbo].[InvServicesDeliveryGroupAssign] ADD CONSTRAINT [FK_InvServicesDeliveryGroupAssign_DelGroup] FOREIGN KEY ([DelGroup]) REFERENCES [dbo].[InvServicesDeliveryGroup] ([DelGroup])
GO
GRANT DELETE ON  [dbo].[InvServicesDeliveryGroupAssign] TO [public]
GO
GRANT INSERT ON  [dbo].[InvServicesDeliveryGroupAssign] TO [public]
GO
GRANT SELECT ON  [dbo].[InvServicesDeliveryGroupAssign] TO [public]
GO
GRANT UPDATE ON  [dbo].[InvServicesDeliveryGroupAssign] TO [public]
GO
