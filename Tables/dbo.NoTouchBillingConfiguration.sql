CREATE TABLE [dbo].[NoTouchBillingConfiguration]
(
[ntb_id] [int] NOT NULL IDENTITY(1, 1),
[ntbTypeId] [int] NOT NULL,
[AppliesToId] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NewInvoiceStatus] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ntb_datetype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__NoTouchBi__ntb_d__2ADAE675] DEFAULT ('NONE'),
[ntb_lagdays] [int] NOT NULL CONSTRAINT [DF__NoTouchBi__ntb_l__2BCF0AAE] DEFAULT ((0)),
[ntb_pbcid] [int] NULL,
[ntb_invhold_pbcid] [int] NULL,
[ntb_printinv_pbcid] [int] NULL,
[ntb_eligterms] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ntb_eligfuelsurcharge] [bit] NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingConfiguration] ADD CONSTRAINT [PK_NoTouchBillingConfiguration] PRIMARY KEY CLUSTERED ([ntb_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoTouchBillingConfiguration] ADD CONSTRAINT [FK_NoTouchBillingConfiguration_NoTouchBillingType] FOREIGN KEY ([ntbTypeId]) REFERENCES [dbo].[NoTouchBillingType] ([ntbTypeId])
GO
GRANT DELETE ON  [dbo].[NoTouchBillingConfiguration] TO [public]
GO
GRANT INSERT ON  [dbo].[NoTouchBillingConfiguration] TO [public]
GO
GRANT REFERENCES ON  [dbo].[NoTouchBillingConfiguration] TO [public]
GO
GRANT SELECT ON  [dbo].[NoTouchBillingConfiguration] TO [public]
GO
GRANT UPDATE ON  [dbo].[NoTouchBillingConfiguration] TO [public]
GO
