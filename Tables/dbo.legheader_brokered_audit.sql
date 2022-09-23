CREATE TABLE [dbo].[legheader_brokered_audit]
(
[lgh_number] [int] NOT NULL,
[lgh_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_fax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_email] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_contact] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_carrier_truck] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver_name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_driver_phone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lgh_truck_mcnum] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_lh_brokered_ord_booked_revtype1_audit] DEFAULT ('UNKNOWN'),
[ord_booked_revtype1_amount] [money] NULL,
[ord_booked_revtype1_rate] [decimal] (8, 4) NULL,
[lgh_booked_revtype1] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_lh_brokered_lgh_booked_revtype1_audit] DEFAULT ('UNKNOWN'),
[lgh_booked_revtype1_amount] [money] NULL,
[lgh_booked_revtype1_rate] [decimal] (8, 4) NULL,
[ModifiedBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ModifiedDate] [datetime] NULL,
[processID] [int] NULL,
[lba_ident] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[legheader_brokered_audit] ADD CONSTRAINT [pk_legheader_brokered_audit] PRIMARY KEY CLUSTERED ([lba_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_lba_lgh_number] ON [dbo].[legheader_brokered_audit] ([lgh_number]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[legheader_brokered_audit] TO [public]
GO
GRANT INSERT ON  [dbo].[legheader_brokered_audit] TO [public]
GO
GRANT SELECT ON  [dbo].[legheader_brokered_audit] TO [public]
GO
GRANT UPDATE ON  [dbo].[legheader_brokered_audit] TO [public]
GO
