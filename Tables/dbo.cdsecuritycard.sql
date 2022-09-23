CREATE TABLE [dbo].[cdsecuritycard]
(
[csc_cardnumber] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cac_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csc_generic] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdsecuritycard_csc_generic] DEFAULT ('N'),
[csc_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[csc_ecb] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [df_cdsecuritycard_csc_ecb] DEFAULT ('N'),
[csc_codeword] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csc_vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ccc_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csc_vendor_userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[csc_id] [int] NOT NULL IDENTITY(1, 1),
[csc_advancemax] [decimal] (11, 2) NULL,
[csc_asgntype] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdsecuritycard] ADD CONSTRAINT [pk_cdsecuritycard] PRIMARY KEY CLUSTERED ([csc_cardnumber], [csc_userid], [csc_vendor], [csc_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[cdsecuritycard] ADD CONSTRAINT [fk_cdsecuritycardtoacctcode] FOREIGN KEY ([cac_id]) REFERENCES [dbo].[cdacctcode] ([cac_id])
GO
GRANT DELETE ON  [dbo].[cdsecuritycard] TO [public]
GO
GRANT INSERT ON  [dbo].[cdsecuritycard] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cdsecuritycard] TO [public]
GO
GRANT SELECT ON  [dbo].[cdsecuritycard] TO [public]
GO
GRANT UPDATE ON  [dbo].[cdsecuritycard] TO [public]
GO
